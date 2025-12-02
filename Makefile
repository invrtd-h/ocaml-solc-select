MAKEFLAGS += --silent

INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)

default: install

build:
	dune fmt || true
	time dune build
	echo "make: *** [build] Success 0"

install: build
	dune install $(INSTALL_ARGS)

uninstall:
	dune uninstall $(INSTALL_ARGS)
	
u: uninstall

reinstall: uninstall install

clean:
	dune clean
	
c: clean
	
doc:
	dune build @doc
	open _build/default/_doc/_html/index.html

fmt:
	dune fmt
	
f: fmt

.PHONY: default build install uninstall reinstall clean doc fmt