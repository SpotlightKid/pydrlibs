cython = find_program('cython')

dr_wav_pyx = 'dr_wav.pyx'
dr_wav_pxd = 'dr_wav.pxd'
dr_wav_c = 'dr_wav.c'
dr_wav_h = 'dr_libs/dr_wav.h'
dr_libs_dir = 'dr_libs'
dr_libs_inc = include_directories(dr_libs_dir)

dr_wav_cy = custom_target(
    'dr_wav_cython',
    output: dr_wav_c,
    input: dr_wav_pyx,
    depend_files: [dr_wav_pxd, dr_wav_h],
    command: [cython, '-I', dr_libs_dir, '-o', '@OUTPUT@', '@INPUT@'],
)
