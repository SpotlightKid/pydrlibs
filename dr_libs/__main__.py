# /usr/bin/env python

import argparse

from .dr_wav import DrWav


def main(args=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("wavfile", metavar="WAV", help="WAV file to examine")
    args = ap.parse_args(args)

    with DrWav(args.wavfile) as wav:
        print("'%s' has %d sample frames." % (args.wavfile, wav.nframes))
        print("Each using %d channel(s)." % wav.channels)
        print("The sample rate is %d Hz." % wav.sample_rate)


if __name__ == "__main__":
    import sys

    sys.exit(main() or 0)
