# https://mesonbuild.com/
# Project name, type and version.
# We need a C compiler.
project(
    'pydrlibs',
    'c',
    version: '0.1.0',
    license: 'MIT License'
)

# https://mesonbuild.com/Python-module.html
pymod = import('python')
python = pymod.find_installation(
    required: true,
)

# Process Cython sources
subdir('src')

# Evaluate meson.build in dr_libs/ Python package dir
subdir('dr_libs')
