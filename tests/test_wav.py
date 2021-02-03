import array
import math
import os
from os.path import dirname, join

import pytest

from dr_libs import dr_wav


TEST_INPUT_DIR = join(dirname(__file__), "input")
TEST_OUTPUT_DIR = join(dirname(__file__), "output")
TEST_WAV_MONO_48_S16 = "sine-mono-48-s16.wav"
TEST_WAV_MONO_48_S32 = "sine-mono-48-s32.wav"
TEST_WAV_MONO_48_F32 = "sine-mono-48-f32.wav"
TEST_WAV_STEREO_48_S16 = "sine-stereo-48-s16.wav"
TEST_WAV_STEREO_48_S32 = "sine-stereo-48-s32.wav"
TEST_WAV_STEREO_48_F32 = "sine-stereo-48-f32.wav"


@pytest.fixture
def one_sec_sine(freq=440.0, fs=48000):
    p = freq / fs
    return (math.sin(2 * math.pi * x * p) for x in range(fs))


def test_wav_invalid_mode():
    with pytest.raises(ValueError, match="Invalid mode 'bogus'."):
        wav = dr_wav.DrWav("dummy", mode='bogus')


def test_wav_read():
    wav = dr_wav.DrWav(join(TEST_INPUT_DIR, TEST_WAV_MONO_48_S16))

    assert wav.avg_bytes_per_sec == 96000
    assert wav.bits_per_sample == 16
    assert wav.block_align == 2
    assert wav.channels == 1
    assert wav.container == dr_wav.container_format.RIFF
    assert wav.data_position == 44
    assert wav.data_size == 96000
    assert wav.extended_size == 0
    assert wav.format_tag == dr_wav.wave_format.PCM
    assert wav.nframes == 48000
    assert wav.sample_rate == 48000
    assert wav.sub_format == b''
    assert wav.translated_format_tag == dr_wav.wave_format.PCM
    assert wav.valid_bits_per_sample == 0

    data = wav.read()

    assert len(data) == 48000
    assert isinstance(data, array.array)
    assert data.typecode == 'i'
    assert data.itemsize == 4
    assert data[0] == 0


def test_wav_read_s16():
    wav = dr_wav.DrWav(join(TEST_INPUT_DIR, TEST_WAV_MONO_48_S16))

    data = wav.read(fmt=dr_wav.sample_format.S16)

    assert len(data) == 48000
    assert isinstance(data, array.array)
    assert data.typecode == 'h'
    assert data.itemsize == 2
    assert isinstance(data[0], int)

    assert min(data) >= -(2**16 / 2)


def test_wav_read_s32():
    wav = dr_wav.DrWav(join(TEST_INPUT_DIR, TEST_WAV_MONO_48_S16))

    data = wav.read(fmt=dr_wav.sample_format.S32)

    assert len(data) == 48000
    assert isinstance(data, array.array)
    assert data.typecode == 'i'
    assert data.itemsize == 4
    assert isinstance(data[0], int)

    assert min(data) >= -(2**32 / 2)


def test_wav_read_f32():
    wav = dr_wav.DrWav(join(TEST_INPUT_DIR, TEST_WAV_MONO_48_S16))

    data = wav.read(fmt=dr_wav.sample_format.F32)

    assert len(data) == 48000
    assert isinstance(data, array.array)
    assert data.typecode == 'f'
    assert data.itemsize == 4
    assert isinstance(data[0], float)

    assert pytest.approx(max(data), 0.0001) == 1.0
    assert pytest.approx(min(data), 0.0001) == -1.0


def test_wav_write_mono_s16(one_sec_sine):
    os.makedirs(TEST_OUTPUT_DIR, exist_ok=True)
    wav = dr_wav.DrWav(
        join(TEST_OUTPUT_DIR, TEST_WAV_MONO_48_S16),
        mode='w',
        channels=1,
        sample_rate=48000,
        bits_per_sample=16)

    assert wav.bits_per_sample == 16
    assert wav.block_align == 2
    assert wav.channels == 1
    assert wav.container == dr_wav.container_format.RIFF
    assert wav.format_tag == dr_wav.wave_format.PCM
    assert wav.translated_format_tag == dr_wav.wave_format.PCM
    assert wav.extended_size == 0
    assert wav.valid_bits_per_sample == 0
    assert wav.sub_format == b''
    assert wav.sample_rate == 48000

    data = array.array('h', (int(x*(2**16/2-1)) for x in one_sec_sine))
    wav.write(data)
    wav.close()

    assert wav.data_size == 96000
    assert wav.data_position == 44
    assert wav.nframes == 48000


def test_wav_write_mono_s32(one_sec_sine):
    os.makedirs(TEST_OUTPUT_DIR, exist_ok=True)
    wav = dr_wav.DrWav(
        join(TEST_OUTPUT_DIR, TEST_WAV_MONO_48_S32),
        mode='w',
        channels=1,
        sample_rate=48000,
        bits_per_sample=32)

    assert wav.bits_per_sample == 32
    assert wav.block_align == 4
    assert wav.channels == 1
    assert wav.container == dr_wav.container_format.RIFF
    assert wav.format_tag == dr_wav.wave_format.PCM
    assert wav.translated_format_tag == dr_wav.wave_format.PCM
    assert wav.extended_size == 0
    assert wav.valid_bits_per_sample == 0
    assert wav.sub_format == b''
    assert wav.sample_rate == 48000

    data = array.array('i', (int(x*(2**32/2-1)) for x in one_sec_sine))
    wav.write(data)
    wav.close()

    assert wav.data_size == 192000
    assert wav.data_position == 44
    assert wav.nframes == 48000


def test_wav_write_mono_f32(one_sec_sine):
    os.makedirs(TEST_OUTPUT_DIR, exist_ok=True)
    wav = dr_wav.DrWav(
        join(TEST_OUTPUT_DIR, TEST_WAV_MONO_48_F32),
        mode='w',
        channels=1,
        sample_rate=48000,
        bits_per_sample=32,
        format_tag=dr_wav.wave_format.IEEE_FLOAT)

    assert wav.bits_per_sample == 32
    assert wav.block_align == 4
    assert wav.channels == 1
    assert wav.container == dr_wav.container_format.RIFF
    assert wav.format_tag == dr_wav.wave_format.IEEE_FLOAT
    assert wav.translated_format_tag == dr_wav.wave_format.IEEE_FLOAT
    assert wav.extended_size == 0
    assert wav.valid_bits_per_sample == 0
    assert wav.sub_format == b''
    assert wav.sample_rate == 48000

    data = array.array('f', one_sec_sine)
    wav.write(data)
    wav.close()

    assert wav.data_size == 192000
    assert wav.data_position == 44
    assert wav.nframes == 48000
