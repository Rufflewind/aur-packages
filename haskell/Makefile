GITIT_GHC_VERSION=8.8

all: dist/gitit/PKGBUILD dist/gitit/.SRCINFO

dist/cabal-update.ok:
	mkdir -p $(@D)
	cabal update
	touch $@

dist/gitit-build/cabal.project.freeze: dist/cabal-update.ok
	mkdir -p $(@D)
	printf 'name: self\nversion: 0\nbuild-type: Simple\nlibrary\n build-depends: gitit\n' >$(@D)/self.cabal
	cd $(@D) && cabal --with-compiler=ghc-$(GITIT_GHC_VERSION) v2-freeze

dist/gitit/PKGBUILD: dist/gitit-build/cabal.project.freeze gitit/PKGBUILD.template.sh
	mkdir -p $(@D)
	sed "s/{{ ghc_version }}/$(GITIT_GHC_VERSION)/g" gitit/PKGBUILD.template.sh >$@.tmp
	../upd-hs-src --boot-pkg-db="$$(ghc-$(GITIT_GHC_VERSION) --print-global-package-db)" --metadata-cache=dist/gitit-build/metadata-cache gitit dist/gitit-build/cabal.project.freeze $@.tmp
	grep "(" $@.tmp
	updpkgsums $@.tmp
	mv $@.tmp $@

dist/gitit/.SRCINFO: dist/gitit/PKGBUILD
	(cd $(@D) && makepkg --printsrcinfo) > $@.tmp
	mv $@.tmp $@
