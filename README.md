# pydrlibs

Python bindings for the [dr_libs] audio file decoding libraries

**Note:** *This project is in very early stages of development and probably
not very useful yet and may even simply not work.*


## Installation

Make sure you have installed the requirements listed below.

```console
$ git clone https://github.com/SpotlightKid/pydrlibs
$ cd pydrlibs
$ git submodule update --init
$ python setup.py install --user  # or: sudo python setup.py install
```


## Usage examples:

### Reading a WAV file

```python
import dr_libs

wav = dr_libs.DrWav('/path/to/audio.wav')

print(wav.sample_rate)
print(wav.channels)
print(wav.bits_per_sample)
print(wav.nframes)

# Read sample data as single-precision floats.
# Returns array.array('f') instance.
# Channels are interleaved.
data = wav.read(fmt=dr_libs.sample_format.F32)
print(len(data))  # Should return (wav.nframes * wav.channels)
```


### Writing a WAV file

```python
import array
from random import randrange

import dr_libs

wav = dr_libs.DrWav(
    'sine.wav',
    mode='w',
    channels=1,
    sample_rate=48000,
    bits_per_sample=16,
    format_tag=dr_libs.PCM)

# default sample rate is 44100 Hz
# for channels, bits_per_sample and format_tag the values used above are the defaults

# generate 1 second of full-scale white noise at 48 kHz
data = array.array('h', (randrange(-32768, 32768) for i in range(48000)))

# write to file
wav.write(data)
wav.close()
```


## Requirements

To get the source code:

* Git

For building:

* [Python] 3.6+
* [setuptools]
* [Cython]

At run-time:

* [Python] 3.6+

For running the unit tests:

* [pytest] >= 3.0


## License

This software is released under the [MIT License](./LICENSE).


## Authors

This software was written by *Christopher Arndt*.


[cython]: https://cython.org/
[dr_libs]: https://github.com/mackron/dr_libs
[pytest]: https://pypi.org/project/pytest/
[python]: https://www.python.org/downloads/
[setuptools]: https://pypi.org/project/setuptools/
