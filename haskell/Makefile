# Dependencies:
#
#   * ghc-<version>: You can use ghcup for this. Make sure it's on PATH.
#   * makepkg (Arch only)
#   * updpkgsums (Arch only, from pacman-contrib)

GITIT_GHC_VERSION=9.0

all: dist/gitit/PKGBUILD dist/gitit/.SRCINFO

dist/cabal-update.ok:
	mkdir -p $(@D)
	cabal update
	touch $@

dist/gitit-build/cabal.project.freeze: dist/cabal-update.ok
	mkdir -p $(@D)
	printf 'name: self\nversion: 0\nbuild-type: Simple\nlibrary\n build-depends: gitit\n' >$(@D)/self.cabal
	cd $(@D) && cabal --with-compiler=ghc-$(GITIT_GHC_VERSION) v2-freeze

dist/gitit-build/PKGBUILD: ../upd-hs-src dist/gitit-build/cabal.project.freeze gitit/PKGBUILD.template.sh
	mkdir -p $(@D)
	sed "s/{{ ghc_version }}/$(GITIT_GHC_VERSION)/g" gitit/PKGBUILD.template.sh >$@.tmp
	../upd-hs-src --boot-pkg-db="$$(ghc-$(GITIT_GHC_VERSION) --print-global-package-db)" --metadata-cache=dist/gitit-build/metadata-cache gitit dist/gitit-build/cabal.project.freeze $@.tmp
	mv $@.tmp $@

dist/gitit/PKGBUILD: dist/gitit-build/PKGBUILD
	mkdir -p $(@D)
	cp $< $@.tmp
	updpkgsums $@.tmp
	mv $@.tmp $@

dist/gitit/.SRCINFO: dist/gitit/PKGBUILD
	(cd $(@D) && makepkg --printsrcinfo) > $@.tmp
	mv $@.tmp $@
