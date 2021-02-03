#!/usr/bin/env python

import array
import math
import sys
from random import randrange

from dr_libs import dr_wav


def one_sec_sine(freq=440.0, fs=48000, amp=1.0):
    p = freq / fs
    return (math.sin(2 * math.pi * x * p) * amp for x in range(fs))


def main():
    if len(sys.argv) < 2:
        return "usage: dr_wav_simple_write.py <output file>"

    wav = dr_wav.DrWav(
        sys.argv[1],
        mode='w',
        channels=1,
        sample_rate=48000,
        bits_per_sample=16,
        format_tag=dr_wav.PCM
    )

    # The default sample rate is 44100 Hz.
    # For channels, bits_per_sample and format_tag the values used above are the defaults.

    with wav:
        # Generate a 1 second sine wave at a frequency of 440 Hz and a sample rate of 48 kHz
        data = array.array('h', (int(x*(2**16/2-1)) for x in one_sec_sine(amp=0.4)))

        # write to file
        wav.write(data)

    # Exiting the context calls wav.close() implicitly.


if __name__ == '__main__':
    sys.exit(main() or 0)
