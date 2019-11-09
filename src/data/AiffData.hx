package data;
import haxe.io.BytesData;
import lime.media.AudioSource;
import lime.media.AudioBuffer;
import sys.io.FileInput;
import haxe.ds.Vector;
import haxe.io.Input;
import haxe.io.Bytes;
import format.tools.BitsInput;
import lime.utils.UInt8Array;
import lime.utils.Assets;
class AiffData
{
    var buffer:AudioBuffer;
    var source:AudioSource;
    public function new(bytes:Bytes)
    {
        buffer = new AudioBuffer();
        buffer.data = UInt8Array.fromBytes(bytes,54,bytes.length - 54);//readMono16AIFFData(new BytesData(bytes,bytes.length));
        buffer.channels = 1;
        buffer.bitsPerSample = buffer.data.length;
        buffer.sampleRate = 16;
        trace("bits per " + buffer.bitsPerSample);
        source = new AudioSource(/*AudioBuffer.fromFile("sound.wav")*/buffer,0,null,20);
        //source.gain = 1;
        source.play();
    }
    public function readMono16AIFFData(data:BytesData):UInt8Array
    {
        trace("data " + data + " length " + data.length + " bit");
        if (data.length < 34)
        {
            trace("Not long enough for header");
            return null;
        }
        //num channels
        if (data[20] != 0 || data[21] != 1)
        {
            trace("AIFF not mono");
            return null;
        }
        if (data[26] != 0 || data[27] != 16)
        {
            trace("AIFF not 16-bit");
            return null;
        }
        var numSamples = data[22] << 24 | data[23] << 16 | data[24] << 8 | data[25];
        var sampleRate = data[30] << 8 | data[31];

        var sampleStartByte = 54;
        var numBytes = numSamples * 2;
        if (data.length < sampleStartByte + numBytes)
        {
            trace("AIFF not long enought for Data");
            return null;
        }
        var samples = new UInt8Array(numSamples);
        var b = sampleStartByte;
        for (i in 0... numSamples)
        {
            //samples[i] = data.bytes.getUI8(i + sampleStartByte);
            samples[i] = (data[b] << 8) | data[b + 1];
            b += 2;
        }
        return samples;
    }
}