#!/usr/bin/env python

import sys
import dr_libs


def main():
    if len(sys.argv) < 2:
        return "usage: dr_wav_simple.py <WAV file>"

    wav = dr_libs.DrWav(sys.argv[1])

    print("'%s' has %d sample frames." % (sys.argv[1], wav.nframes))
    print("Each using %d channel(s)." % wav.channels)
    print("The sample rate is %d Hz." % wav.sample_rate)

    samples = wav.read()

    # At this point samples is an array.array('i') instance,
    # which contains wav.channels * wav.nframes samples as signed 32-bit PCM.
    # Channels are interleaved.

    wav.close()  # also automatically called when 'wav' is garbage-collected


if __name__ == '__main__':
    sys.exit(main() or 0)
