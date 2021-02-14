#!/usr/bin/env python

import sys

from dr_libs import dr_wav


def main():
    if len(sys.argv) < 2:
        return "usage: dr_wav_simple.py <WAV file>"

    with dr_wav.DrWav(sys.argv[1]) as wav:
        print("'%s' has %d sample frames." % (sys.argv[1], wav.nframes))
        print("Each using %d channel(s)." % wav.channels)
        print("The sample rate is %d Hz." % wav.sample_rate)

        samples = wav.read()  # noqa:F841

        # At this point samples is an array.array('i') instance,
        # which contains wav.channels * wav.nframes samples as signed 32-bit PCM.
        # Channels are interleaved.

    # Exiting the context calls wav.close() implicitly.
    # It is also automatically called when 'wav' is garbage-collected


if __name__ == "__main__":
    sys.exit(main() or 0)
