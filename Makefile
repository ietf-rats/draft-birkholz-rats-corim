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

include cddl/vars.mk
include cddl/tools.mk

CDDL_FRAGS := $(addprefix cddl/,$(CDDL_FRAGS))
CDDL_FULL := $(addprefix cddl/,$(CDDL_FULL))

draft-birkholz-rats-corim.xml: $(CDDL_FULL)

.PHONY: cddl-check
cddl-check: $(CDDL_FULL) ; $(cddl) $< generate 10 &> /dev/null

$(CDDL_FULL): $(CDDL_FRAGS)
	for f in $^ ; do \
		( cat $$f ; echo ) ; \
	done > $@

cddl-clean: ; $(RM) $(CDDL_FULL)
