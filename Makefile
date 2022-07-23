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

CORIM_CDDL := cddl/corim-autogen.cddl

draft-birkholz-rats-corim.md: $(CORIM_CDDL)

$(CORIM_CDDL): ; $(MAKE) -C cddl

.PHONY: cddl-lint
cddl-lint: ; $(MAKE) -C cddl check

.PHONY: cddl-clean
cddl-clean: ; $(MAKE) -C cddl clean
