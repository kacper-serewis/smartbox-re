"""Check update protocol guards without contacting or modifying an adapter."""
import base64
import unittest
from unittest.mock import patch
import update_device


class FakeDevice:
    def __init__(self, hw=501, bad_ack=False):
        self.hw, self.bad_ack = hw, bad_ack
        self.packets = []
        self.flash_requested = False

    def request(self, endpoint, payload=None):
        if endpoint=='getboxinfos': return {'hwtype':self.hw}
        if endpoint=='getupdatestatus':
            return {'version':131,'pos':1,'count':2} if self.packets else {}
        if endpoint=='uploadappdatas':
            self.packets.append(payload)
            return {'version':131,'pos':payload['pos']+(1 if self.bad_ack else 0),'count':2,'result':1}
        if endpoint=='requestupdate':
            self.flash_requested=True
            return {'version':131,'percent':100}
        raise AssertionError(endpoint)


class UpdateTests(unittest.TestCase):
    metadata={'version':131,'chunk_metadata':{'itemsize':4,'count':2,'filesize':6,'version':131}}

    def test_chunks_and_commit_order(self):
        device=FakeDevice()
        update_device.stage(device,self.metadata,b'abcdef')
        self.assertFalse(device.flash_requested)
        self.assertEqual([base64.b64decode(p['data']) for p in device.packets],[b'abcd',b'ef'])
        self.assertEqual([p['datasize'] for p in device.packets],[4,2])
        update_device.apply(device,131)
        self.assertTrue(device.flash_requested)

    def test_wrong_hardware_never_uploads(self):
        device=FakeDevice(hw=502)
        with self.assertRaises(ValueError): update_device.stage(device,self.metadata,b'abcdef')
        self.assertEqual(device.packets,[])
        self.assertFalse(device.flash_requested)

    def test_bad_ack_never_commits(self):
        device=FakeDevice(bad_ack=True)
        with self.assertRaises(ValueError): update_device.stage(device,self.metadata,b'abcdef')
        self.assertEqual(len(device.packets),1)
        self.assertFalse(device.flash_requested)

    def test_invalid_flash_status_not_reported_successful(self):
        device=FakeDevice()
        with patch.object(device,'request',return_value={'version':128,'percent':100}):
            with self.assertRaises(ValueError): update_device.apply(device,131)


if __name__=='__main__': unittest.main()
