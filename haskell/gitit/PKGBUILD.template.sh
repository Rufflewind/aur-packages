# Maintainer: Phil Ruffwind <rf@rufflewind.com>
pkgname=gitit
pkgver=0.13.0.0
pkgrel=1
pkgdesc="A wiki backed by a git, darcs, or mercurial filestore"
arch=(i686 x86_64)
url=https://hackage.haskell.org/package/gitit
license=(GPL)
depends=(gmp mailcap numactl zlib)
optdepends=("git: git support" "mercurial: mercurial support")
makedepends=(cabal-install libffi ncurses5-compat-libs)
source=()
sha512sums=()
sha512sums_i686=()
sha512sums_x86_64=()
noextract=("${source[@]%%::*}")
source_i686=("https://downloads.haskell.org/~ghc/{{ ghc_version }}/ghc-{{ ghc_version }}-i386-deb9-linux.tar.xz")
source_x86_64=("https://downloads.haskell.org/~ghc/{{ ghc_version }}/ghc-{{ ghc_version }}-x86_64-deb9-linux.tar.xz")

prepare() {
    unset CABAL_SANDBOX_CONFIG CABAL_SANDBOX_PACKAGE_PATH GHC_PACKAGE_PATH
    (
        cd ghc-{{ ghc_version }}
        ./configure --prefix="$srcdir/.local"
        make install
    )
    mkdir -p .cabal
    cat >.cabal/config <<EOF
with-compiler: $srcdir/.local/bin/ghc
jobs: \$ncpus
EOF
    cabal --config=.cabal/config v1-sandbox init
    rm -f .cabal-sandbox/packages/00-index.tar
    for tar in haskell-*.tar.gz; do (
        cd .cabal-sandbox/packages
        tar_stem=${tar%.tar.gz}
        name=${tar_stem%-*}
        name=${name#haskell-}
        ver=${tar_stem##*-}
        mkdir -p "$name/$ver"
        ln -fs "../../../../$tar" "$name/$ver/$name-$ver.tar.gz"
        for f in "../../haskell-$name-$ver-"*.cabal; do
            if [ -f "$f" ]; then
                cp -p "$f" "$name/$ver/$name.cabal"
            fi
        done
        [ -f "$name/$ver/$name.cabal" ] || {
            tar -xzf "$name/$ver/$name-$ver.tar.gz" "$name-$ver/$name.cabal"
            mv "$name-$ver/$name.cabal" "$name/$ver/$name.cabal"
        }
        tar -uf 00-index.tar "$name/$ver/$name.cabal"
    ) done
    tar -xzf "haskell-gitit-$pkgver.tar.gz" "gitit-$pkgver/LICENSE"
}

build() {
    unset CABAL_SANDBOX_CONFIG CABAL_SANDBOX_PACKAGE_PATH GHC_PACKAGE_PATH
    cabal --config=.cabal/config v1-install --enable-relocatable --force-reinstalls -f-plugins --datadir='$prefix/share/gitit' --docdir='$prefix/share/doc/$abi/$pkgid' --ghc-options=-rtsopts gitit
}

package() {
    mkdir -p "$pkgdir/usr/share"
    cp -PR .cabal-sandbox/share/gitit "$pkgdir/usr/share/"
    rm -fr "$pkgdir/usr/share/gitit/man"
    install -Dm755 .cabal-sandbox/bin/gitit "$pkgdir/usr/bin/gitit"
    install -Dm644 "gitit-$pkgver/LICENSE" "$pkgdir/usr/share/licenses/gitit/LICENSE"
}
