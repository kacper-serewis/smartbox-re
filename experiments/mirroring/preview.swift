// Decode framed H.264 supplied by the local Python preview. No screen capture.
import Foundation
import VideoToolbox
import CoreMedia
import CoreVideo
import CoreImage

struct Packet: Decodable { let sps: Data; let pps: Data; let avcc: Data }
func check(_ status: OSStatus, _ operation: String) throws {
    if status != noErr { throw NSError(domain: operation, code: Int(status)) }
}
final class Preview {
    let directory: URL
    let exportFrames: Bool
    var exported: [[String: Any]] = []
    let context = CIContext(options: [.useSoftwareRenderer: false])
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let lock = NSLock()
    var session: VTDecompressionSession?
    var format: CMVideoFormatDescription?
    var previous = Data()
    var count = 0
    var decoded = 0
    var lastImage = 0.0
    var errors = 0
    var width = 0
    var height = 0
    init(_ path: String, exportFrames: Bool) { directory = URL(fileURLWithPath: path); self.exportFrames = exportFrames }
    func writeState() throws {
        let state: [String: Any] = ["frames_decoded": decoded, "width": width,
                "height": height, "decode_errors": errors]
        try JSONSerialization.data(withJSONObject: state).write(to: directory.appendingPathComponent("decoder.json"), options: .atomic)
    }
    func output(_ image: CVImageBuffer?, _ status: OSStatus, _ index: Int) {
        lock.lock(); defer { lock.unlock() }
        guard status == noErr, let image else { errors += 1; return }
        decoded += 1
        width = CVPixelBufferGetWidth(image)
        height = CVPixelBufferGetHeight(image)
        let now = ProcessInfo.processInfo.systemUptime
        if exportFrames ? index % 3 != 0 : now - lastImage < 0.1 { return }
        lastImage = now
        do {
            let pixels = CIImage(cvPixelBuffer: image)
            guard let jpeg = context.jpegRepresentation(of: pixels, colorSpace: colorSpace,
                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.8]) else { return }
            let file = exportFrames ? String(format: "frame-%06d.jpg", index) : "frame.jpg"
            try jpeg.write(to: directory.appendingPathComponent(file), options: .atomic)
            if exportFrames { exported.append(["index": index, "file": file, "width": width, "height": height]) }
            try writeState()
        } catch { fputs("Preview output: \(error)\n", stderr) }
    }
    func finish() {
        if let session {
            VTDecompressionSessionWaitForAsynchronousFrames(session)
            VTDecompressionSessionInvalidate(session)
        }
        session = nil
        lock.lock(); defer { lock.unlock() }
        // Live JPEG updates are throttled; always persist the final counters.
        if decoded > 0 || errors > 0 {
            do { try writeState() }
            catch { fputs("Preview final status: \(error)\n", stderr) }
        }
    }
    func feed(_ packet: Packet) throws {
        if previous != packet.sps + packet.pps {
            finish()
            guard !packet.sps.isEmpty, !packet.pps.isEmpty else { return }
            try check(packet.sps.withUnsafeBytes { sps in packet.pps.withUnsafeBytes { pps in
                var pointers = [sps.baseAddress!.assumingMemoryBound(to: UInt8.self), pps.baseAddress!.assumingMemoryBound(to: UInt8.self)]
                var sizes = [packet.sps.count, packet.pps.count]
                return CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: nil, parameterSetCount: 2,
                    parameterSetPointers: &pointers, parameterSetSizes: &sizes, nalUnitHeaderLength: 4, formatDescriptionOut: &format)
            } }, "H264 format")
            var callback = VTDecompressionOutputCallbackRecord(decompressionOutputCallback: { opaque, ref, status, _, image, _, _ in
                Unmanaged<Preview>.fromOpaque(opaque!).takeUnretainedValue().output(image, status, Int(bitPattern: ref) - 1)
            }, decompressionOutputRefCon: Unmanaged.passUnretained(self).toOpaque())
            try check(VTDecompressionSessionCreate(allocator: nil, formatDescription: format!, decoderSpecification: nil,
                imageBufferAttributes: [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as CFDictionary,
                outputCallback: &callback, decompressionSessionOut: &session), "H264 decoder")
            previous = packet.sps + packet.pps
        }
        guard !packet.avcc.isEmpty, let session else { return }
        var block: CMBlockBuffer?
        try check(CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: packet.avcc.count,
            blockAllocator: nil, customBlockSource: nil, offsetToData: 0, dataLength: packet.avcc.count,
            flags: 0, blockBufferOut: &block), "H264 block")
        try packet.avcc.withUnsafeBytes { pointer in
            try check(CMBlockBufferReplaceDataBytes(with: pointer.baseAddress!, blockBuffer: block!, offsetIntoDestination: 0,
                dataLength: packet.avcc.count), "H264 copy")
        }
        var sample: CMSampleBuffer?
        var size = packet.avcc.count
        var timing = CMSampleTimingInfo(duration: CMTime(value: 1, timescale: 30),
            presentationTimeStamp: CMTime(value: Int64(count), timescale: 30), decodeTimeStamp: .invalid)
        try check(CMSampleBufferCreateReady(allocator: nil, dataBuffer: block, formatDescription: format,
            sampleCount: 1, sampleTimingEntryCount: 1, sampleTimingArray: &timing,
            sampleSizeEntryCount: 1, sampleSizeArray: &size, sampleBufferOut: &sample), "H264 sample")
        count += 1
        try check(VTDecompressionSessionDecodeFrame(session, sampleBuffer: sample!, flags: [], frameRefcon: UnsafeMutableRawPointer(bitPattern: count),
            infoFlagsOut: nil), "H264 decode")
    }
}
guard CommandLine.arguments.count == 2 || (CommandLine.arguments.count == 3 && CommandLine.arguments[2] == "--export") else { fatalError("preview OUTPUT_DIRECTORY [--export]") }
let preview = Preview(CommandLine.arguments[1], exportFrames: CommandLine.arguments.count == 3)
while let line = readLine() {
    do { try preview.feed(JSONDecoder().decode(Packet.self, from: Data(line.utf8))) }
    catch { fputs("Decode error: \(error)\n", stderr); preview.errors += 1 }
}
preview.finish()
if preview.exportFrames {
    do { try JSONSerialization.data(withJSONObject: preview.exported).write(to: preview.directory.appendingPathComponent("frames.json"), options: .atomic) }
    catch { fputs("Frame export: \(error)\n", stderr); exit(1) }
}
print("Decoded \(preview.decoded) frames; errors \(preview.errors)")
if preview.errors != 0 { exit(1) }
