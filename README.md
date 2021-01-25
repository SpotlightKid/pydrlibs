# pydrlibs

Python bindings for the [dr_libs] audio decoding libraries

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


## Usage example:

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
data = wav.read(fmt=dr_libs.SAMPLE_FORMAT_F32)
print(len(data))  # Should return (wav.nframes * wav.channels)
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


## License

This software is released under the [MIT License](./LICENSE).


## Authors

This software was written by *Christopher Arndt*.


[python]: https://www.python.org/downloads/
[cython]: https://cython.org/
[setuptools]: https://pypi.org/project/setuptools/
[dr_libs]: https://github.com/mackron/dr_libs
