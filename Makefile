DESTDIR ?= /
PACKAGE = dr_libs
PROJECT = pydrlibs
PREFIX ?= /usr/local
PYTHON ?= python3
TWINE ?= twine

.PHONY: all build flake8 install install-user

all:
	@echo 'make install: install $(PROJECT) to $(PREFIX) (needs root)'
	@echo 'make install-user: install $(PROJECT) as current user to $(HOME)/.local'

clean:
	-rm -rf build/ $(PACKAGE)*.so $(PROJECT).egg-info tests/__pycache__

flake8:
	flake8 $(PACKAGE)

test:
	$(PYTHON) setup.py build_ext --inplace && \
		$(PYTHON) -m pytest -v tests/

build:
	$(PYTHON) setup.py build

install: build
	$(PYTHON) setup.py install --skip-build --root=$(DESTDIR) --prefix=$(PREFIX) --optimize=1

install-user: build
	$(PYTHON) setup.py install --skip-build --optimize=1 --user

sdist: $(GENERATED_FILES)
	$(PYTHON) setup.py sdist --formats=gztar,zip

wheel: $(GENERATED_FILES)
	$(PYTHON) setup.py bdist_wheel

pypi-upload: sdist wheel
	$(TWINE) upload --skip-existing dist/$(PROJECT)-*.tar.gz dist/$(PROJECT)-*.whl
