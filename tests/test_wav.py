import array
from os.path import dirname, join

import dr_libs


TEST_WAV_MONO_48_F32 = join(dirname(__file__), 'sine-mono-48-s32.wav')


def test_wav_read():
    wav = dr_libs.DrWav(TEST_WAV_MONO_48_F32)

    assert wav.avg_bytes_per_sec == 96000
    assert wav.bits_per_sample == 16
    assert wav.block_align == 2
    assert wav.channels == 1
    assert wav.container == 0
    assert wav.data_position == 44
    assert wav.data_size == 96000
    assert wav.extended_size == 0
    assert wav.format_tag == 1
    assert wav.nframes == 48000
    assert wav.sample_rate == 48000
    assert wav.sub_format == b''
    assert wav.translated_format_tag == 1
    assert wav.valid_bits_per_sample == 0

    data = wav.read()

    assert len(data) == 48000
    assert isinstance(data, array.array)
    assert data.typecode == 'i'
    assert data.itemsize == 4
    assert data[0] == 0
