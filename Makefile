ELISP_C=emacs
ELC_TARGETS=$(patsubst ./%.el,./%.elc,$(wildcard ./*.el))

default: clean all

.PHONY: clean
clean:
	rm -rf *.elc

all: $(ELC_TARGETS)

%.elc: %.el
	$(ELISP_C) --batch --eval "(byte-compile-file \"$<\")"
