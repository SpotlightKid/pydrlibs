# dr_libs.pyx
#
# cython: language_level=3

from cpython cimport array
import array



cdef class DrWav:
    cdef drwav _wav

    def __cinit__(self, filename):
        ret = drwav_init_file(&self._wav, filename.encode("utf-8"), NULL)
        if not ret:
            raise IOError("Could not open %s." % filename)

    def __dealloc__(self):
        drwav_uninit(&self._wav)

    @property
    def bits_per_sample(self):
        return self._wav.bitsPerSample

    @property
    def channels(self):
        return self._wav.channels

    @property
    def nframes(self):
        return self._wav.totalPCMFrameCount

    @property
    def sample_rate(self):
        return self._wav.sampleRate

    def read(self, drwav_uint64 nframes=0, sample_format fmt=SAMPLE_FORMAT_S32):
        cdef drwav_uint64 frames_read = 0
        cdef array.array frames

        if nframes == 0:
            nframes = self._wav.totalPCMFrameCount

        if fmt == SAMPLE_FORMAT_S32:
            frames = array.array('i')
        elif fmt == SAMPLE_FORMAT_F32:
            frames = array.array('f')
        else:
            raise ValueError("Sample format %d not supported" % fmt)

        array.resize(frames, nframes * self._wav.channels)

        if fmt == SAMPLE_FORMAT_S32:
            frames_read = drwav_read_pcm_frames_s32(&self._wav, nframes, frames.data.as_ints)
        elif fmt == SAMPLE_FORMAT_F32:
            frames_read = drwav_read_pcm_frames_f32(&self._wav, nframes, frames.data.as_floats)

        if frames_read < nframes:
            array.resize(frames, frames_read * self._wav.channels)

        return frames
