.PHONY: init clean test

ifndef RPM_BUILD_ROOT
RPM_BUILD_ROOT := $(HOME)/rpmbuild
$(warning RPM_BUILD_ROOT unset, using $(RPM_BUILD_ROOT))
endif

SRC_DIR := src
DIST_DIR := dist

# the properties.mk file is project specific and needs to include the NAME, VERSION and RELEASE variables
include properties.mk

SPEC := $(NAME).spec
SOURCE := $(NAME)-$(VERSION)-$(RELEASE).tar.gz
ARCH := noarch
OS := linux
VENDOR := redhat
RPM := $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm

.DEFAULT_GOAL := $(DIST_DIR)/$(RPM)

RPMDIR := $(shell rpm --eval "%{_rpmdir}")
SRCDIR := $(shell rpm --eval "%{_sourcedir}")
SPECDIR := $(shell rpm --eval "%{_specdir}")
SRPMDIR := $(shell rpm --eval "%{_srcrpmdir}")
BUILDDIR := $(shell rpm --eval "%{_builddir}")

init: 
	$(shell [ ! -f "${HOME}/.rpmmacros" ] && echo "%_topdir $(RPM_BUILD_ROOT)" > ${HOME}/.rpmmacros )	
	$(shell for i in $(RPMDIR) $(SRCDIR) $(SPECDIR) $(SRPMDIR) $(BUILDDIR) ; do [ ! -d $$i ] && mkdir -p $$i; done)
	tar -cvzf $(RPM_BUILD_ROOT)/SOURCES/$(SOURCE) --exclude-backups -C $(SRC_DIR) .
	cp $(SPEC) $(RPM_BUILD_ROOT)/SPECS/

$(DIST_DIR)/$(RPM): init
	rpmbuild -vv -ba --target $(ARCH)-$(VENDOR)-$(OS) --define "proj_name $(NAME)" --define "proj_version $(VERSION)" --define "proj_release $(RELEASE)" $(SPEC)
	mkdir -p $(DIST_DIR)
	cp -f $(RPM_BUILD_ROOT)/RPMS/noarch/$(RPM) $(DIST_DIR)

clean: 
	rm -rf $(DIST_DIR)

test:
	tests/run_tests.sh