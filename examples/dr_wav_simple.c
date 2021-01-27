#define DR_WAV_IMPLEMENTATION
#include <stdio.h>
#include "dr_wav.h"


int main(int argc, char* argv[]) {
    drwav wav;
    drwav_fmt fmt;

    if(argc < 2){
        printf("usage: dr_wav_simple <WAV file>\n");
        return 1;
    }

    if (!drwav_init_file(&wav, argv[1], NULL)) {
        return -1;
    }

    printf("'%s' has %d sample frames.\n", argv[1], wav.totalPCMFrameCount);
    printf("Each using %d channel(s).\n", wav.channels);
    printf("The sample rate is %d Hz.\n", wav.sampleRate);

    int32_t* pSampleData = (int32_t*)malloc((size_t)wav.totalPCMFrameCount * wav.channels * sizeof(int32_t));
    size_t num_samples = drwav_read_pcm_frames_s32(&wav, wav.totalPCMFrameCount, pSampleData);

    // At this point pSampleData contains every decoded sample as signed 32-bit PCM.
    // Channels are interleaved.

    drwav_uninit(&wav);
    return 0;
}