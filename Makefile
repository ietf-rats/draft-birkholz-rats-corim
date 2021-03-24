LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

CORIM_CDDL := corim-cddl/corim.cddl
CORIM_MAKEFILE := corim-cddl/Makefile

draft-birkholz-rats-corim.md: $(CORIM_CDDL)

$(CORIM_CDDL): $(CORIM_MAKEFILE) ; $(MAKE) -C corim-cddl

.PHONY: cddl-lint
cddl-lint: $(CORIM_MAKEFILE) ; $(MAKE) -C corim-cddl check

.PHONY: cddl-clean
cddl-clean: $(CORIM_MAKEFILE) ; $(MAKE) -C corim-cddl clean

$(CORIM_MAKEFILE):
	git submodule sync
	git submodule update --init --recursive
