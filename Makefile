EXERCISES := \
  01-registers/asm-01-mov

.PHONY: check-all clean-all

check-all:
	@pass=0; fail=0; \
	for ex in $(EXERCISES); do \
	  if $(MAKE) -C $$ex check -s 2>/dev/null; then \
	    echo "PASS  $$ex"; pass=$$((pass+1)); \
	  else \
	    echo "FAIL  $$ex"; fail=$$((fail+1)); \
	  fi; \
	done; \
	echo ""; echo "Results: $$pass passed, $$fail failed"

clean-all:
	@for ex in $(EXERCISES); do \
	  $(MAKE) -C $$ex clean -s 2>/dev/null || true; \
	done
	rm -f lib/print_uint64.o
