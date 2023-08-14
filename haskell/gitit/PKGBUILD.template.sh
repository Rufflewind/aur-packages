# Maintainer: Phil Ruffwind <rf@rufflewind.com>
pkgname=gitit
pkgver=0.15.1.1
pkgrel=1
pkgdesc="A wiki backed by a git, darcs, or mercurial filestore"
arch=(i686 x86_64)
url=https://hackage.haskell.org/package/gitit
license=(GPL)
depends=(gmp mailcap numactl zlib)
optdepends=("git: git support" "mercurial: mercurial support")
makedepends=(cabal-install ghc{{ ghc_version }})
source=()
sha512sums=('SKIP')

prepare() {
    unset GHC_PACKAGE_PATH
    mkdir -p .cabal
    cat >.cabal/config <<EOF
with-compiler: ghc-{{ ghc_version }}
jobs: \$ncpus
EOF
    echo 'packages: */*.cabal' >cabal.project
    for file in haskell-*-*-*.cabal; do (
        stem=${file%.cabal}
        name_ver_rev=${stem#haskell-}
        name_ver=${name_ver_rev%-*}
        name=${name_ver%-*}
        ln -fs "../$file" "$name_ver/$name.cabal"
    ) done
}

build() {
    unset GHC_PACKAGE_PATH
    HOME=$PWD cabal --config=.cabal/config v2-build --enable-relocatable -f-plugins --datadir='$prefix/share/gitit' --docdir='$prefix/share/doc/$abi/$pkgid' --ghc-options=-rtsopts gitit
}

package() {
    mkdir -p "$pkgdir/usr/share"
    cp -PR .cabal-sandbox/share/gitit "$pkgdir/usr/share/"
    rm -fr "$pkgdir/usr/share/gitit/man"
    install -Dm755 -t "$pkgdir/usr/bin" .cabal-sandbox/bin/{gitit,expireGititCache}
    install -Dm644 -t "$pkgdir/usr/share/licenses/gitit" "gitit-$pkgver/"*LICENSE
}
