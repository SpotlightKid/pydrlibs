#!/usr/bin/env python

from os.path import exists, join
from setuptools import Extension, setup

try:
    from Cython.Build import cythonize
except ImportError:
    cythonize = None

SRC_DIR = "src"
PACKAGE = "dr_libs"
MODULE = "dr_wav"

# Set up options for compiling the Extension
if cythonize:
    sources = [join(SRC_DIR, MODULE + ".pyx")]
elif exists(join(SRC_DIR, MODULE + ".c")):
    cythonize = lambda x: x  # noqa
    sources = [join(SRC_DIR, MODULE + ".c")]
else:
    raise RuntimeError("Could not import Cython. Cython is required to compile "
                       "the Cython source into the C extension source.")

extensions = [
    Extension(
        PACKAGE + '.' + MODULE,
        sources=sources,
        language="c",
        define_macros=[
            ('DR_WAV_IMPLEMENTATION', None),
            ('DRWAV_MAX_SMPL_LOOPS', 10),
        ],
        include_dirs=[join(SRC_DIR, "dr_libs")]
    )
]

setup(
    packages=[PACKAGE],
    ext_modules=cythonize(extensions)
)
