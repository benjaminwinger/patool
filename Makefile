# This Makefile is only used by developers.
VERSION:=$(shell python setup.py --version)
ARCHIVE:=patool-$(VERSION).tar.gz
ARCHIVE_WIN32:=patool-$(VERSION).win32.exe
PY_FILES_DIRS := patool setup.py patoolib tests
NUMCPUS := $(shell grep -c '^process' /proc/cpuinfo)
# which test modules to run
TESTS ?= tests/
# set test options, eg. to "--nologcapture"
TESTOPTS=
# test for nose achievements plugin and use it if available
NOSE_ACHIEVEMENTS:=$(shell nosetests --plugins | grep achievements)
ifeq ($(strip $(NOSE_ACHIEVEMENTS)),Plugin achievements)
TESTOPTS += --with-achievements
endif

all:


.PHONY: chmod
chmod:
	-chmod -R a+rX,u+w,go-w -- *
	find . -type d -exec chmod 755 {} \;

.PHONY: dist
dist:
	git archive --format=tar --prefix=patool-$(VERSION)/ HEAD | gzip -9 > ../$(ARCHIVE)
	[ -f ../$(ARCHIVE).sha1 ] || sha1sum ../$(ARCHIVE) > ../$(ARCHIVE).sha1
	[ -f ../$(ARCHIVE).asc ] || gpg --detach-sign --armor ../$(ARCHIVE)
	[ -f ../$(ARCHIVE_WIN32).sha1 ] || sha1sum ../$(ARCHIVE_WIN32) > ../$(ARCHIVE_WIN32).sha1
	[ -f ../$(ARCHIVE_WIN32).asc ] || gpg --detach-sign --armor ../$(ARCHIVE_WIN32)
#	cd .. && zip -r - patool-git -x "**/.git/**" > $(HOME)/temp/share/patool-devel.zip

.PHONY: upload
upload:
	rsync -avP -e ssh ../$(ARCHIVE)* ../$(ARCHIVE_WIN32)* calvin,patool@frs.sourceforge.net:/home/frs/project/p/pa/patool/$(VERSION)/


.PHONY: release
release: clean releasecheck dist upload
	@echo "Register at Python Package Index..."
	python setup.py register
	freshmeat-submit < patool.freshmeat


.PHONY: releasecheck
releasecheck: check test
	@if egrep -i "xx\.|xxxx|\.xx" doc/changelog.txt > /dev/null; then \
	  echo "Could not release: edit doc/changelog.txt release date"; false; \
	fi
	@if [ ! -f ../$(ARCHIVE_WIN32) ]; then \
	  echo "Missing WIN32 distribution archive at ../$(ARCHIVE_WIN32)"; \
	  false; \
	fi
	@if ! grep "Version: $(VERSION)" patool.freshmeat > /dev/null; then \
	  echo "Could not release: edit patool.freshmeat version"; false; \
	fi

# The check programs used here are mostly local scripts on my private system.
# So for other developers there is no need to execute this target.
.PHONY: check
check:
	[ ! -d .svn ] || check-nosvneolstyle -v
	check-copyright
	check-pofiles -v
	py-tabdaddy
	py-unittest2-compat tests/
	$(MAKE) pyflakes

.PHONY: pyflakes
pyflakes:
	pyflakes $(PY_FILES_DIRS)

.PHONY: count
count:
	@sloccount patool patoolib | grep "Total Physical Source Lines of Code"

.PHONY: clean
clean:
	find . -name \*.pyc -delete
	find . -name \*.pyo -delete
	rm -rf build dist

.PHONY: test
test:
	nosetests -v --processes=$(NUMCPUS) -m "^test_.*" $(TESTOPTS) $(TESTS)

doc/patool.txt: doc/patool.1
	cols=`stty size | cut -d" " -f2`; stty cols 72; man -l doc/patool.1 | perl -pe 's/.\cH//g' > doc/patool.txt; stty cols $$cols

.PHONY: deb
deb:
	git-buildpackage --git-export-dir=../build-area/ --git-upstream-branch=master --git-debian-branch=debian  --git-ignore-new
