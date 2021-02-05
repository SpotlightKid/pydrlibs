# dr_wav.pxd
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

    cdef union chunk_id:
        drwav_uint8 fourcc[4]
        drwav_uint8 guid[16]

    ctypedef struct drwav_chunk_header:
        chunk_id id
        drwav_uint64 sizeInBytes
        unsigned int paddingSize

    ctypedef struct drwav_smpl_loop:
        drwav_uint32 cuePointId
        drwav_uint32 type
        drwav_uint32 start
        drwav_uint32 end
        drwav_uint32 fraction
        drwav_uint32 playCount

    cdef const int DRWAV_MAX_SMPL_LOOPS

    ctypedef struct drwav_smpl:
        drwav_uint32 manufacturer
        drwav_uint32 product
        drwav_uint32 samplePeriod
        drwav_uint32 midiUnityNotes
        drwav_uint32 midiPitchFraction
        drwav_uint32 smpteFormat
        drwav_uint32 smpteOffset
        drwav_uint32 numSampleLoops
        drwav_uint32 samplerData
        drwav_smpl_loop loops[DRWAV_MAX_SMPL_LOOPS];

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

    ctypedef struct drwav_data_format:
        drwav_container container  # RIFF, W64, RF64
        drwav_uint32 format        # DR_WAVE_FORMAT_*
        drwav_uint32 channels
        drwav_uint32 sampleRate
        drwav_uint32 bitsPerSample

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
        # smpl chunk
        drwav_smpl smpl
        drwav_uint32 sampleRate
        drwav_uint16 channels
        drwav_uint16 bitsPerSample
        drwav_uint16 translatedFormatTag
        drwav_uint64 totalPCMFrameCount
        drwav_uint64 dataChunkDataSize
        drwav_uint64 dataChunkDataPos

    ctypedef drwav_uint64 (* drwav_chunk_proc)(void* pChunkUserData, drwav_read_proc onRead,
                           drwav_seek_proc onSeek, void* pReadSeekUserData,
                           const drwav_chunk_header* pChunkHeader, drwav_container container,
                           const drwav_fmt* pFMT)

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
    drwav_bool32 drwav_init_file_ex(
        drwav* pWav,
        const char* filename,
        drwav_chunk_proc onChunk,
        void* pChunkUserData,
        drwav_uint32 flags,
        const drwav_allocation_callbacks* pAllocationCallbacks)
    drwav_bool32 drwav_init_write(
        drwav* pWav,
        const drwav_data_format* pFormat,
        drwav_write_proc onWrite,
        drwav_seek_proc onSeek,
        void* pUserData,
        const drwav_allocation_callbacks* pAllocationCallbacks)
    drwav_bool32 drwav_init_file_write(
        drwav* pWav,
        const char* filename,
        const drwav_data_format* pFormat,
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
    size_t drwav_write_raw(
        drwav* pWav,
        size_t bytesToWrite,
        const void* pData)
    drwav_uint64 drwav_write_pcm_frames(
        drwav* pWav,
        drwav_uint64 framesToWrite,
        const void* pData)
    drwav_result drwav_uninit(drwav* pWav)
