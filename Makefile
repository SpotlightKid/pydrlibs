DESTDIR ?= /
PACKAGE = dr_libs
PROJECT = pydrlibs
PREFIX ?= /usr/local
PYTHON ?= python3
TESTDIR ?= tests
TWINE ?= twine

PATCHES = \
	patches/dr_wav_data_pos.patch

.PHONY: all build clean dist examples install install-user lint patch sdist

all:
	@echo "build        - build extension module (and place it in the dr_libs package)"
	@echo "clean        - remove Python file artifacts"
	@echo "dist         - build distribution packages"
	@echo "install      - install $(PROJECT) to '$(PREFIX)' (needs root)"
	@echo "install-user - install $(PROJECT) as current user to '$(HOME)/.local'"
	@echo "lint         - check code-style with flake8"
	@echo "pypi-upload  - package a release and upload it to PyPI"
	@echo "sdist        - build source distribution archives"
	@echo "test         - run test in '$(TESTDIR)' via pytest using un-installed package"
	@echo "wheel        - build a binary wheel distribution"


clean:
	-rm -rf build/ $(PACKAGE)/*.so $(PROJECT).egg-info tests/__pycache__

examples:
	$(MAKE) -C examples

lint:
	$(PYTHON) -m flake8 $(PACKAGE) $(TESTDIR)

patch: $(PATCHES)
	@-for p in $(PATCHES); do \
		echo "Applying patch '$${p}'..."; \
		patch -d src/dr_libs -r - -p1 -N -i ../../$${p}; \
	done

build: patch
	$(PYTHON) setup.py build

test: patch
	$(PYTHON) setup.py build_ext --inplace && \
		$(PYTHON) -m pytest -v $(TESTDIR)

install: build
	$(PYTHON) setup.py install --skip-build --root=$(DESTDIR) --prefix=$(PREFIX) --optimize=1

install-user: build
	$(PYTHON) setup.py install --skip-build --optimize=1 --user

sdist: $(GENERATED_FILES)
	$(PYTHON) setup.py egg_info -Db "" sdist --formats=gztar,zip

wheel: $(GENERATED_FILES)
	$(PYTHON) setup.py egg_info -Db "" bdist_wheel

dist: sdist wheel

pypi-upload: sdist wheel
	$(TWINE) upload --skip-existing dist/$(PROJECT)-*.tar.gz dist/$(PROJECT)-*.whl
