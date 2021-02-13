# https://mesonbuild.com/Python-module.html

# Build and install the extension module
module = python.extension_module(
    'dr_wav',
    dr_wav_cy,
    install: true,
    dependencies: [
        python.dependency()
    ],
    include_directories: dr_libs_inc,
    c_args: ['-DDR_WAV_IMPLEMENTATION', '-DDRWAV_MAX_SMPL_LOOPS=10'],
    subdir: 'dr_libs', # Folder relative to site-packages to install to
)

# Pure Python sources
python_sources = [
    '__init__.py',
    '__main__.py',
]

# Install pure Python
python.install_sources(
    python_sources,
    pure: false, # Will be installed next to binaries
    subdir: 'dr_libs'
)
