# dr_libs.pxd
#
# cython: language_level=3

from cpython cimport array
import array


cdef extern from "dr_libs/dr_wav.h":
    # custom types
    ctypedef unsigned char drwav_uint8
    ctypedef unsigned short drwav_uint16
    ctypedef int drwav_int32
    ctypedef unsigned int drwav_uint32
    ctypedef int drwav_result
    ctypedef unsigned int drwav_bool32
    ctypedef unsigned long long drwav_uint64

    # callbacks
    ctypedef size_t (* drwav_read_proc)(void* pUserData, void* pBufferOut, size_t bytesToRead)
    ctypedef size_t (* drwav_write_proc)(void* pUserData, const void* pData, size_t bytesToWrite);
    ctypedef drwav_bool32 (* drwav_seek_proc)(void* pUserData, int offset, drwav_seek_origin origin)

    # Enums
    ctypedef enum drwav_container:
        drwav_container_riff,
        drwav_container_w64,
        drwav_container_rf64

    ctypedef enum drwav_seek_origin:
        drwav_seek_origin_start,
        drwav_seek_origin_current

    ctypedef struct drwav_allocation_callbacks:
        void* pUserData;
        void* (* onMalloc)(size_t sz, void* pUserData)
        void* (* onRealloc)(void* p, size_t sz, void* pUserData)
        void  (* onFree)(void* p, void* pUserData)

    # Struct types
    ctypedef struct drwav_fmt:
        # The format tag exactly as specified in the wave file's "fmt" chunk.
        # This can be used by applications that require support for data formats not natively
        # supported by dr_wav.
        drwav_uint16 formatTag
        # The number of channels making up the audio data. When this is set to 1 it is mono,
        # 2 is stereo, etc.
        drwav_uint16 channels
        # The sample rate. Usually set to something like 44100.
        drwav_uint32 sampleRate
        # Average bytes per second. You probably don't need this, but it's left here for
        # informational purposes.
        drwav_uint32 avgBytesPerSec
        # Block align. This is equal to the number of channels * bytes per sample.
        drwav_uint16 blockAlign
        # Bits per sample.
        drwav_uint16 bitsPerSample
        # The size of the extended data. Only used internally for validation, but left here for
        # informational purposes.
        drwav_uint16 extendedSize
        # The number of valid bits per sample. When <formatTag> is equal to WAVE_FORMAT_EXTENSIBLE,
        # <bitsPerSample> is always rounded up to the nearest multiple of 8. This variable contains
        # information about exactly how many bits are valid per sample.
        # Mainly used for informational purposes.
        drwav_uint16 validBitsPerSample
        # The channel mask. Not used at the moment.
        drwav_uint32 channelMask
        # The sub-format, exactly as specified by the wave file.
        drwav_uint8 subFormat[16]

    ctypedef struct drwav:
        # A pointer to the function to call when more data is needed.
        drwav_read_proc onRead
        # A pointer to the function to call when data needs to be written. Only used when the drwav
        # object is opened in write mode.
        drwav_write_proc onWrite
        # A pointer to the function to call when the wav file needs to be seeked.
        drwav_seek_proc onSeek
        # The user data to pass to callbacks.
        void* pUserData
        # Allocation callbacks.
        drwav_allocation_callbacks allocationCallbacks
        # Whether or not the WAV file is formatted as a standard RIFF file or W64.
        drwav_container container
        # Structure containing format information exactly as specified by the wav file.
        drwav_fmt fmt
        # The sample rate. Will be set to something like 44100.
        drwav_uint32 sampleRate
        # The number of channels. This will be set to 1 for monaural streams, 2 for stereo, etc.
        drwav_uint16 channels
        # The bits per sample. Will be set to something like 16, 24, etc.
        drwav_uint16 bitsPerSample
        # Equal to fmt.formatTag, or the value specified by fmt.subFormat if fmt.formatTag is equal
        # to 65534 (WAVE_FORMAT_EXTENSIBLE).
        drwav_uint16 translatedFormatTag
        # The total number of PCM frames making up the audio data.
        drwav_uint64 totalPCMFrameCount
        # The size in bytes of the data chunk.
        drwav_uint64 dataChunkDataSize
        # The position in the stream of the first byte of the data chunk. This is used for seeking.
        drwav_uint64 dataChunkDataPos
        # The number of bytes remaining in the data chunk.
        drwav_uint64 bytesRemaining
        # Only used in sequential write mode. Keeps track of the desired size of the "data" chunk
        # at the point of initialization time. Always set to 0 for non-sequential writes and when
        # the drwav object is opened in read mode. Used for validation.
        drwav_uint64 dataChunkDataSizeTargetWrite
        # Keeps track of whether or not the wav writer was initialized in sequential mode.
        drwav_bool32 isSequentialWrite;

    # Functions from the API we want to call using the types declared above
    drwav_bool32 drwav_init(
        drwav* pWav,
        drwav_read_proc onRead,
        drwav_seek_proc onSeek,
        void* pUserData,
        const drwav_allocation_callbacks* pAllocationCallbacks)
    drwav_bool32 drwav_init_file(
        drwav* pWav,
        const char* filename,
        const drwav_allocation_callbacks* pAllocationCallbacks)
    drwav_uint64 drwav_read_pcm_frames_s32(
        drwav* pWav,
        drwav_uint64 framesToRead,
        drwav_int32* pBufferOut)
    drwav_uint64 drwav_read_pcm_frames_f32(
        drwav* pWav,
        drwav_uint64 framesToRead,
        float* pBufferOut)
    drwav_result drwav_uninit(drwav* pWav)


cpdef enum sample_format:
    SAMPLE_FORMAT_S32, SAMPLE_FORMAT_F32


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
