// Generated test pixels only: no screen capture, UI access, or phone required.
import Foundation
import VideoToolbox
import CoreMedia
import CoreVideo

struct Frame: Codable {
    let width: Int
    let height: Int
    let sps: Data
    let pps: Data
    let avcc: Data
}
final class Collector {
    var frames: [Frame] = []
    var decoded: [[String: Int]] = []
    var errors: [Int32] = []
    let lock = NSLock()
}
func check(_ status: OSStatus, _ operation: String) {
    if status != noErr { fatalError("\(operation): OSStatus \(status)") }
}
let encodeCallback: VTCompressionOutputCallback = { opaque, _, status, _, sample in
    let result = Unmanaged<Collector>.fromOpaque(opaque!).takeUnretainedValue()
    result.lock.lock(); defer { result.lock.unlock() }
    guard status == noErr, let sample, let format = CMSampleBufferGetFormatDescription(sample),
          let block = CMSampleBufferGetDataBuffer(sample) else {
        result.errors.append(status == noErr ? -1 : status); return
    }
    var sets: [Data] = []
    for i in 0..<2 {
        var pointer: UnsafePointer<UInt8>?
        var size = 0
        var header: Int32 = 0
        check(CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, parameterSetIndex: i,
              parameterSetPointerOut: &pointer, parameterSetSizeOut: &size,
              parameterSetCountOut: nil, nalUnitHeaderLengthOut: &header), "parameter set")
        precondition(header == 4)
        sets.append(Data(bytes: pointer!, count: size))
    }
    var data = Data(count: CMBlockBufferGetDataLength(block))
    let count = data.count
    data.withUnsafeMutableBytes { ptr in
        check(CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: count, destination: ptr.baseAddress!), "copy encoded")
    }
    let size = CMVideoFormatDescriptionGetDimensions(format)
    result.frames.append(Frame(width: Int(size.width), height: Int(size.height), sps: sets[0], pps: sets[1], avcc: data))
}
let decodeCallback: VTDecompressionOutputCallback = { opaque, _, status, _, image, _, _ in
    let result = Unmanaged<Collector>.fromOpaque(opaque!).takeUnretainedValue()
    result.lock.lock(); defer { result.lock.unlock() }
    guard status == noErr, let image else { result.errors.append(status == noErr ? -1 : status); return }
    check(CVPixelBufferLockBaseAddress(image, .readOnly), "lock decoded")
    defer { CVPixelBufferUnlockBaseAddress(image, .readOnly) }
    let w = CVPixelBufferGetWidth(image), h = CVPixelBufferGetHeight(image)
    let row = CVPixelBufferGetBytesPerRow(image)
    let bytes = CVPixelBufferGetBaseAddress(image)!.assumingMemoryBound(to: UInt8.self)
    var sum = 0
    for y in stride(from: 0, to: h, by: 47) {
        for x in stride(from: 0, to: w, by: 43) {
            sum += Int(bytes[y * row + x * 4]) + Int(bytes[y * row + x * 4 + 1]) + Int(bytes[y * row + x * 4 + 2])
        }
    }
    result.decoded.append(["width": w, "height": h, "pixel_sum": sum])
}

func generate() -> [Frame] {
    let collector = Collector()
    let opaque = Unmanaged.passUnretained(collector).toOpaque()
    for (width, height) in [(800, 480), (480, 800), (800, 480)] {
        var session: VTCompressionSession?
        check(VTCompressionSessionCreate(allocator: nil, width: Int32(width), height: Int32(height),
              codecType: kCMVideoCodecType_H264, encoderSpecification: nil, imageBufferAttributes: nil,
              compressedDataAllocator: nil, outputCallback: encodeCallback, refcon: opaque, compressionSessionOut: &session), "encoder")
        let encoder = session!
        check(VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue), "realtime")
        check(VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse), "reordering")
        check(VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_Main_AutoLevel), "profile")
        check(VTCompressionSessionPrepareToEncodeFrames(encoder), "prepare")
        for frame in 0..<24 {
            var image: CVPixelBuffer?
            check(CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA,
                  [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary, &image), "pixels")
            let buffer = image!
            check(CVPixelBufferLockBaseAddress(buffer, []), "lock")
            let bytes = CVPixelBufferGetBaseAddress(buffer)!.assumingMemoryBound(to: UInt8.self)
            let row = CVPixelBufferGetBytesPerRow(buffer)
            for y in 0..<height { for x in 0..<width {
                let offset = y * row + x * 4
                bytes[offset] = UInt8((frame * 23) % 256)
                bytes[offset + 1] = UInt8((y + frame * 7) % 256)
                bytes[offset + 2] = UInt8((x + frame * 17) % 256)
                bytes[offset + 3] = 255
            } }
            CVPixelBufferUnlockBaseAddress(buffer, [])
            check(VTCompressionSessionEncodeFrame(encoder, imageBuffer: buffer,
                  presentationTimeStamp: CMTime(value: Int64(frame), timescale: 30),
                  duration: CMTime(value: 1, timescale: 30), frameProperties: nil,
                  sourceFrameRefcon: nil, infoFlagsOut: nil), "encode")
        }
        check(VTCompressionSessionCompleteFrames(encoder, untilPresentationTimeStamp: .invalid), "finish encoding")
        VTCompressionSessionInvalidate(encoder)
    }
    precondition(collector.errors.isEmpty && collector.frames.count == 72)
    return collector.frames
}

func decode(_ frames: [Frame]) -> Collector {
    let collector = Collector()
    var session: VTDecompressionSession?
    var format: CMVideoFormatDescription?
    var previous: Data?
    for (index, frame) in frames.enumerated() {
        if previous != frame.sps + frame.pps {
            if let session {
                check(VTDecompressionSessionWaitForAsynchronousFrames(session), "wait")
                VTDecompressionSessionInvalidate(session)
            }
            check(frame.sps.withUnsafeBytes { sps in frame.pps.withUnsafeBytes { pps in
                var pointers = [sps.baseAddress!.assumingMemoryBound(to: UInt8.self), pps.baseAddress!.assumingMemoryBound(to: UInt8.self)]
                var sizes = [frame.sps.count, frame.pps.count]
                return CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: nil, parameterSetCount: 2,
                    parameterSetPointers: &pointers, parameterSetSizes: &sizes, nalUnitHeaderLength: 4, formatDescriptionOut: &format)
            } }, "decode format")
            var callback = VTDecompressionOutputCallbackRecord(decompressionOutputCallback: decodeCallback,
                        decompressionOutputRefCon: Unmanaged.passUnretained(collector).toOpaque())
            check(VTDecompressionSessionCreate(allocator: nil, formatDescription: format!, decoderSpecification: nil,
                  imageBufferAttributes: [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as CFDictionary,
                  outputCallback: &callback, decompressionSessionOut: &session), "decoder")
            previous = frame.sps + frame.pps
        }
        var block: CMBlockBuffer?
        check(CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: frame.avcc.count,
              blockAllocator: nil, customBlockSource: nil, offsetToData: 0, dataLength: frame.avcc.count,
              flags: 0, blockBufferOut: &block), "decode buffer")
        frame.avcc.withUnsafeBytes { ptr in
            check(CMBlockBufferReplaceDataBytes(with: ptr.baseAddress!, blockBuffer: block!, offsetIntoDestination: 0,
                  dataLength: frame.avcc.count), "decode copy")
        }
        var sample: CMSampleBuffer?
        var size = frame.avcc.count
        var timing = CMSampleTimingInfo(duration: CMTime(value: 1, timescale: 30),
                    presentationTimeStamp: CMTime(value: Int64(index), timescale: 30), decodeTimeStamp: .invalid)
        check(CMSampleBufferCreateReady(allocator: nil, dataBuffer: block, formatDescription: format,
              sampleCount: 1, sampleTimingEntryCount: 1, sampleTimingArray: &timing,
              sampleSizeEntryCount: 1, sampleSizeArray: &size, sampleBufferOut: &sample), "decode sample")
        check(VTDecompressionSessionDecodeFrame(session!, sampleBuffer: sample!, flags: [], frameRefcon: nil,
              infoFlagsOut: nil), "decode")
    }
    if let session {
        check(VTDecompressionSessionWaitForAsynchronousFrames(session), "finish decoding")
        VTDecompressionSessionInvalidate(session)
    }
    return collector
}

precondition(CommandLine.arguments.count == 3, "video-fixture generate|decode FILE")
let path = URL(fileURLWithPath: CommandLine.arguments[2])
if CommandLine.arguments[1] == "generate" {
    try JSONEncoder().encode(generate()).write(to: path)
} else {
    let frames = try JSONDecoder().decode([Frame].self, from: Data(contentsOf: path))
    let result = decode(frames)
    let json = try JSONSerialization.data(withJSONObject: ["decoded": result.decoded, "errors": result.errors], options: [.sortedKeys])
    print(String(data: json, encoding: .utf8)!)
    precondition(result.errors.isEmpty && result.decoded.count == frames.count)
}
