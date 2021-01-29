# dr_libs.pyx
#
# cython: language_level=3

from cpython cimport array
import array


cpdef enum container_format:
    RIFF = drwav_container_riff,
    W64 = drwav_container_w64,
    RF64 = drwav_container_rf64


cpdef enum sample_format:
    S16,
    S16LE,
    S16BE,
    S32,
    S32LE,
    S32BE,
    F32,
    F64


cpdef enum seek_origin:
    START = drwav_seek_origin_start,
    CURRENT = drwav_seek_origin_current


cpdef enum wave_format:
    PCM = 0x1,
    ADPCM = 0x2,
    IEEE_FLOAT = 0x3,
    ALAW = 0x6,
    MULAW = 0x7,
    DVI_ADPCM = 0x11,
    EXTENSIBLE = 0xFFFE


cdef class DrWav:
    # C-level instance attributes
    cdef:
        # private
        drwav _wav
        drwav_data_format _fmt
        bint _closed
        wave_format _format_tag

    def __cinit__(self,
        filename,
        mode='r',
        drwav_uint32 channels=1,
        drwav_uint32 sample_rate=44100,
        drwav_uint32 bits_per_sample=16,
        wave_format format_tag=wave_format.PCM
    ):
        if mode == 'r':
            ret = drwav_init_file(&self._wav, filename.encode("utf-8"), NULL)
        elif mode == 'w':
            self._fmt.container = <drwav_container> container_format.RIFF
            self._fmt.format = format_tag
            self._fmt.channels = channels
            self._fmt.sampleRate = sample_rate
            self._fmt.bitsPerSample = bits_per_sample
            ret = drwav_init_file_write(&self._wav, filename.encode("utf-8"), &self._fmt, NULL)
        else:
            raise ValueError("Invalid mode '%s'." % mode)

        if not ret:
            raise IOError("Could not open %s." % filename)

        self._closed = False

    def __dealloc__(self):
        if not self._closed:
            drwav_uninit(&self._wav)

    def close(self):
        if not self._closed:
            drwav_uninit(&self._wav)
            self._closed = True

    @property
    def avg_bytes_per_sec(self):
        """Average bytes per second.

        Approx. sample_rate * block_align. Only for informational purposes.

        """
        return self._wav.fmt.avgBytesPerSec

    @property
    def bits_per_sample(self):
        """The bits per sample.

        Will be set to something like 8, 16, 24, etc.

        When ``bits_per_sample / 8`` < ``block_align / channels``, the bits in
        each sample will be left-justified and zero-padded on the right up to a
        size of ``block_align`` bytes.

        """
        return self._wav.bitsPerSample

    @property
    def block_align(self):
        """The number of *bytes* per sample *frame*.

        This is equal to the number of channels * bytes per sample.

        """
        return self._wav.fmt.blockAlign

    @property
    def channels(self):
        """The number of channels making up the audio data.

        When this is set to 1 it is mono, 2 is stereo, etc.

        """
        return self._wav.channels

    @property
    def container(self):
        """The container format.

        Holds information whether or the WAV file is formatted as a standard
        RIFF file or W64.

        """
        return self._wav.container

    @property
    def data_position(self):
        """The position in the stream of the first byte of the data chunk.

        This is only for informational purposes, see the ``read()`` method
        on how to get the sample data.

        """
        return self._wav.dataChunkDataPos

    @property
    def data_size(self):
        """The size in bytes of the data chunk.

        This is only for informational purposes, see the ``read()`` method
        on how to get the sample data.

        """
        return self._wav.dataChunkDataSize

    @property
    def extended_size(self):
        """The size of the extended data in the header.

        Only for informational purposes and 0 unless ``format_tag`` is
        ``WAVE_FORMAT_EXTENSIBLE``.

        """
        return self._wav.fmt.extendedSize

    @property
    def format_tag(self):
        """The format tag exactly as specified in the wave file's "fmt" chunk.

        For uncompressed PCM data, the most common variant, this equals 1.

        This information can be used by applications that require support for
        data formats not natively supported by dr_wav.

        """
        return self._wav.fmt.formatTag

    @property
    def nframes(self):
        """The total number of PCM frames making up the audio data."""
        return self._wav.totalPCMFrameCount

    @property
    def sample_rate(self):
        """The sample rate.

        Usually set to something like 44100 or 48000.

        """
        return self._wav.sampleRate

    @property
    def sub_format(self):
        """The sub-format, exactly as specified by the wave file.

        This is a ``bytes`` object holding a binary GUID (or nothing).

        """
        return self._wav.fmt.subFormat

    @property
    def translated_format_tag(self):
        """Sample format information.

        Equal either to ``format_tag`` or ``sub_format``, if ``format_tag`` is
        ``WAVE_FORMAT_EXTENSIBLE``.

        """
        return self._wav.translatedFormatTag

    @property
    def valid_bits_per_sample(self):
        """The number of valid bits per sample.

        When ``format_tag`` is equal to ``WAVE_FORMAT_EXTENSIBLE``,
        ``bits_per_sample`` is always rounded up to the nearest multiple of 8.
        This property then contains information about exactly how many bits are
        valid per sample. Otherwise it is zero. Mainly used for informational
        purposes.

        """
        return self._wav.fmt.validBitsPerSample

    def read(self, drwav_uint64 nframes=0, sample_format fmt=sample_format.S32):
        """Read at most nframes sample frames from the input stream.

        If ``nframes`` is 0 (default), read until the end of the stream. If
        the end of the stream is reached before ``nframes`` can be read, the
        number of frames returned will be less than requested, but never more.
        If the end of the stream is reached immediately, return ``None``.

        Returns an ``array.array`` instance, which contains the samples
        sequentially. Channels are interleaved, i.e. if ``channels == 2``,
        index 0 will have the first sample of the first (left) channel, index 1
        the first sample of the second (right) channel, index 2 the second
        sample of the first channel and so on.

        The array element data type is determined by the ``fmt`` option and
        defaults to ``sample_format.S32``, which is signed 32-bit integer,
        correlating to the ``l`` type code used by the ``array`` modules.
        Currently, the opther options are ``sample_format.S32`` (signed 16-bit
        integer, type code ``h``)  and ``sample_format.F32`` (single precision
        float, type code ``f``). If the input stream uses a different sample
        format, the data will be automatically converted into the requested
        format and the sample values scaled accordingly.

        Raises ``IOError`` when the underlying instance is closed, i.e.
        the ``close()`` method was already called on it.

        """
        cdef drwav_uint64 frames_read = 0
        cdef array.array frames

        if self._closed:
            raise IOError("Cannot read from closed file.")

        if nframes == 0:
            nframes = self._wav.totalPCMFrameCount

        if fmt == sample_format.S16:
            frames = array.array('h')
        elif fmt == sample_format.S32:
            frames = array.array('i')
        elif fmt == sample_format.F32:
            frames = array.array('f')
        else:
            raise ValueError("Sample format %d not supported" % fmt)

        array.resize(frames, nframes * self._wav.channels)

        if fmt == sample_format.S16:
            assert frames.itemsize == 2
            frames_read = drwav_read_pcm_frames_s16(&self._wav, nframes,
                                                     <drwav_int16 *>frames.data.as_shorts)
        elif fmt == sample_format.S32:
            assert frames.itemsize == sizeof(drwav_int32)
            frames_read = drwav_read_pcm_frames_s32(&self._wav, nframes, frames.data.as_ints)
        elif fmt == sample_format.F32:
            assert frames.itemsize == 4
            frames_read = drwav_read_pcm_frames_f32(&self._wav, nframes, frames.data.as_floats)

        if frames_read < nframes:
            array.resize(frames, frames_read * self._wav.channels)

        return frames or None

    def write(self, array.array frames):
        cdef drwav_uint64 nframes = len(frames), frames_written
        cdef wave_format tag = <wave_format>self._wav.fmt.formatTag

        if frames.typecode in 'hi' and tag != wave_format.PCM:
            raise TypeError("Invalid sample format for WAV format PCM.")

        if frames.typecode == 'h':
            frames_written = drwav_write_pcm_frames(&self._wav, nframes,
                                                    <const void*>frames.data.as_shorts)
        elif frames.typecode == 'i':
            frames_written = drwav_write_pcm_frames(&self._wav, nframes,
                                                    <const void*>frames.data.as_ints)
        elif frames.typecode == 'f':
            if tag != wave_format.IEEE_FLOAT:
                raise TypeError("Invalid sample format for WAV format IEEE_FLOAT.")

            frames_written = drwav_write_pcm_frames(&self._wav, nframes,
                                                    <const void*>frames.data.as_floats)
        else:
            raise TypeError("Unsupported sample data format (typecode: %s)." % frames.typecode)

        if frames_written != nframes:
            raise IOError("Truncated write, frames written: %d, expected: %d." %
                          (frames_written, nframes))

        self._wav.totalPCMFrameCount += frames_written
        return frames_written

    def seek(self, drwav_uint64 frame):
        """Seek to the given PCM frame in the stream.

        Returns ``True`` if successful; ``False`` otherwise.

        Raises ``IOError`` when the underlying instance is closed, i.e.
        the ``close()`` was already called on it.

        """
        if self._closed:
            raise IOError("Cannot seek in closed file.")

        return bool(drwav_seek_to_pcm_frame(&self._wav, frame))