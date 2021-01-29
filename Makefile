DESTDIR ?= /
PACKAGE = dr_libs
PROJECT = pydrlibs
PREFIX ?= /usr/local
PYTHON ?= python3
TWINE ?= twine

PATCHES = \
	patches/dr_wav_data_pos.patch

.PHONY: all build clean examples flake8 install install-user patch

all:
	@echo 'make install: install $(PROJECT) to $(PREFIX) (needs root)'
	@echo 'make install-user: install $(PROJECT) as current user to $(HOME)/.local'

clean:
	-rm -rf build/ $(PACKAGE)*.so $(PROJECT).egg-info tests/__pycache__

examples:
	$(MAKE) -C examples

flake8:
	flake8 $(PACKAGE)

test: patch
	$(PYTHON) setup.py build_ext --inplace && \
		$(PYTHON) -m pytest -v tests/

patch: $(PATCHES)
	@-for p in $(PATCHES); do \
		echo "Applying patch '$${p}'..."; \
		patch -d src/dr_libs -r - -p1 -N -i ../../$${p}; \
	done

build: patch
	$(PYTHON) setup.py build

install: build
	$(PYTHON) setup.py install --skip-build --root=$(DESTDIR) --prefix=$(PREFIX) --optimize=1

install-user: build
	$(PYTHON) setup.py install --skip-build --optimize=1 --user

sdist: $(GENERATED_FILES)
	$(PYTHON) setup.py egg_info -Db "" sdist --formats=gztar,zip

wheel: $(GENERATED_FILES)
	$(PYTHON) setup.py egg_info -Db "" bdist_wheel

pypi-upload: sdist wheel
	$(TWINE) upload --skip-existing dist/$(PROJECT)-*.tar.gz dist/$(PROJECT)-*.whl
