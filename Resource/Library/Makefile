#
# Makefile
#

srcs	= window.ts

dsts	= $(srcs:.ts=.js)
decls	= $(srcs:.ts=.d.ts)

srcdecl	= ./types/KiwiLibrary.d.ts
dstdecl	= ./types/KiwiComponent.d.ts

tsc	= npx tsc
tsc_opt	= -t ES2017 --lib "es2017" --declaration --declarationDir types \
	  --typeRoots types \
	  --alwaysStrict --strict --pretty


%.js: %.ts
	$(tsc) $(tsc_opt) $<

all: $(srcdecl) $(dsts) $(dstdecl)

$(srcdecl): dummy
	if [ -f ~/Development/Library/KiwiLibrary.d.ts ] ; then \
		cp  ~/Development/Library/KiwiLibrary.d.ts $@ ; \
	fi

$(dstdecl): dummy
	(cd types && cat Builtin.d.ts $(decls)) > $@

clean:
	rm -f $(dsts)

dummy:

