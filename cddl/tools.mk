cddl ?= $(shell command -v cddl)
ifeq ($(strip $(cddl)),)
  $(error cddl tool not found. To install cddl, run: 'gem install cddl')
endif
