# dr_libs.pxd
#
# cython: language_level=3

cdef extern from "dr_libs/dr_wav.h":
    # custom types
    ctypedef unsigned char drwav_uint8
    ctypedef signed short drwav_int16
    ctypedef unsigned short drwav_uint16
    ctypedef int drwav_int32
    ctypedef unsigned int drwav_uint32
    ctypedef int drwav_result
    ctypedef unsigned int drwav_bool32
    ctypedef unsigned long long drwav_uint64

    # callbacks
    ctypedef size_t (* drwav_read_proc)(void* pUserData, void* pBufferOut, size_t bytesToRead)
    ctypedef size_t (* drwav_write_proc)(void* pUserData, const void* pData, size_t bytesToWrite)
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
        void* pUserData
        void* (* onMalloc)(size_t sz, void* pUserData)
        void* (* onRealloc)(void* p, size_t sz, void* pUserData)
        void  (* onFree)(void* p, void* pUserData)

    # Struct types

    # Note: some fields not actually used in Cython are left un-declared.

    # Structure containing format information exactly as specified by the wav file.
    ctypedef struct drwav_fmt:
        drwav_uint16 formatTag
        drwav_uint16 channels
        drwav_uint32 sampleRate
        drwav_uint32 avgBytesPerSec
        drwav_uint16 blockAlign
        drwav_uint16 bitsPerSample
        drwav_uint16 extendedSize
        drwav_uint16 validBitsPerSample
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
        drwav_container container
        drwav_fmt fmt
        drwav_uint32 sampleRate
        drwav_uint16 channels
        drwav_uint16 bitsPerSample
        drwav_uint16 translatedFormatTag
        drwav_uint64 totalPCMFrameCount
        drwav_uint64 dataChunkDataSize
        drwav_uint64 dataChunkDataPos

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
    drwav_uint64 drwav_read_pcm_frames_s16(
        drwav* pWav,
        drwav_uint64 framesToRead,
        drwav_int16* pBufferOut)
    drwav_uint64 drwav_read_pcm_frames_s32(
        drwav* pWav,
        drwav_uint64 framesToRead,
        drwav_int32* pBufferOut)
    drwav_uint64 drwav_read_pcm_frames_f32(
        drwav* pWav,
        drwav_uint64 framesToRead,
        float* pBufferOut)
    drwav_bool32 drwav_seek_to_pcm_frame(
        drwav* pWav,
        drwav_uint64 targetFrameIndex)
    drwav_result drwav_uninit(drwav* pWav)


cpdef enum sample_format:
    SAMPLE_FORMAT_S16, SAMPLE_FORMAT_S32, SAMPLE_FORMAT_F32
