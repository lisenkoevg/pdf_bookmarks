
SOURCES := $(wildcard *.sh awk/*.awk)
CONFS := $(shell find ./conf -regextype awk -regex ".*(awk|sed)$$" | sed "s/ /\?/g")
SOURCES_CONFS := $(SOURCES) $(CONFS)

tags: $(SOURCES_CONFS)
	ctags -R

.PHONY: clean
clean:
	find ./test -type f \( -name *.in -o -name *.out \) -print0 | xargs --no-run-if-empty --null -n10 rm
	find ./tmp -mindepth 1 -maxdepth 1 -type d -print0 | xargs --no-run-if-empty --null rm -rf

.PHONY: pretty
pretty:
	@for f in Makefile $(SOURCES_CONFS) ; \
    do \
	  sed -E 's/\s+$$//' -i "$$f" ; \
    done

.PHONY: check
check:
	@for f in Makefile $(SOURCES_CONFS) ; \
    do \
      sed -n '1F; /\s$$/{=;p}; $$a ___' "$$f" | cat -A ; \
    done
