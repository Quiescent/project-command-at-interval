ELISP_C=emacs
SRCS=$(wildcard ./*.el)
ELC_TARGETS=$(patsubst ./%.el,./%.elc,$(wildcard ./*.el))
TAGS_C=ctags
TAGS_C_FLAGS=-eR
TAGS_TARGETS=TAGS

default: clean all

.PHONY: clean
clean:
	rm -rf *.elc

# TODO avoid remaking tags when files haven't changed...
tags: $(SRCS) Makefile
	$(TAGS_C) $(TAGS_C_FLAGS)

all: $(ELC_TARGETS)

%.elc: %.el
	$(ELISP_C) --batch --eval "(byte-compile-file \"$<\")"
