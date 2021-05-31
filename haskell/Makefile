GITIT_GHC_VERSION=8.8.4

all: dist/gitit/PKGBUILD

ghc-%-x86_64-deb9-linux.tar.xz:
	mkdir -p $(@D)
	curl -LSfs -o $@ https://downloads.haskell.org/~ghc/$(*F)/$(@F)

ghc-%-src.ok: ghc-%-x86_64-deb9-linux.tar.xz
	cd $(<D) && tar -xJf $(<F)
	touch $@

ghc-%-bin.ok: ghc-%-src.ok
	cd $(<D)/ghc-$(*F) && ./configure --prefix=$${PWD}/.local && make install
	touch $@

dist/cabal-update.ok:
	cabal update
	touch $@

dist/gitit-build/cabal.project.freeze: dist/ghc-$(GITIT_GHC_VERSION)-bin.ok dist/cabal-update.ok
	mkdir -p $(@D)
	printf 'name: self\nversion: 0\nbuild-type: Simple\nlibrary\n build-depends: gitit\n' >$(@D)/self.cabal
	cd $(@D) && cabal --with-compiler=../ghc-$(GITIT_GHC_VERSION)/.local/bin/ghc v2-freeze

dist/gitit/PKGBUILD: dist/gitit-build/cabal.project.freeze gitit/PKGBUILD.template.sh
	mkdir -p $(@D)
	sed "s/{{ ghc_version }}/$(GITIT_GHC_VERSION)/g" gitit/PKGBUILD.template.sh >$@.tmp
	../upd-hs-src --boot-pkg-db=dist/ghc-$(GITIT_GHC_VERSION)/.local/lib/ghc-$(GITIT_GHC_VERSION)/package.conf.d --metadata-cache=dist/gitit-build/metadata-cache gitit dist/gitit-build/cabal.project.freeze $@.tmp
	grep "(" $@.tmp
	updpkgsums $@.tmp
	mv $@.tmp $@
