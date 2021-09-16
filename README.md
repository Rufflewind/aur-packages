# AUR packages

To avoid forgetting to update `.SRCINFO`, be sure to add the pre-push hooks,
as shown in the commands below.

## Initial clone of `aur-packages`

On the first clone of `aur-packages`, run `./init` to initialize the
packages properly.

## Management

### Making quick commits

To make a quick commit within a package, do:

~~~sh
git commit -m `../../getpkgver`
~~~

### Staging changes for testing on GitHub Actions

~~~sh
../../buildpkg
~~~

### Cloning new or existing packages

~~~sh
./clone-aur ⟨pkgname⟩
~~~

This will automatically add the package to `packages.conf` and set up the
pre-push hooks.

### Updating dependency trees of Cabal packages

Install `$pkg` manually with the updated deps:

~~~sh
set -eux

pkg=my-package
ghc_ver=8.10
ghc_ver_full=8.10.4

yay -S --needed cabal-install "ghc$ghc_ver"
cabal update
boot_pkg_db=$(pacman -Ql ghc8.10 | grep /usr/lib/ghc | head -n 1 | cut -d " " -f 2)
echo --boot-pkg-db="$boot_pkg_db"

tmpdir=`mktemp -d`
(
    cd "$tmpdir"
    cabal get gitit
    echo "packages: */*.cabal
with-compiler: ghc-$ghc_ver" >cabal.project
    cabal freeze
)

# update the PKGBUILD
./upd-hs-src --boot-pkg-db=/usr/lib/ghc-$ghc_ver_full/package.conf.d "$pkg" "$tmpdir/cabal.project.freeze" "pkg/$pkg/PKGBUILD"
~~~

Finally, bump the `pkgver` and then run `updpkgsums`.

## Google Font packages

 1. If you want this package to be managed by `aur-packages`, first do a
    [clone](#Cloning repositories).  Otherwise, skip this step.

 2. Edit `google-font-pkgs.conf`, if necessary.

 3. Run `./pkg-google-font` in the top level directory of this repository.

 4. If you did step 1, now is the time to go into `ttf-⟨name⟩-gf` and commit
    the files.

### Updating

To do updates, just run `./pkg-google-font ⟨name⟩…`, then check if anything
needs to be committed:

~~~sh
for d in pkg/ttf-*; do ( cd "$d" && printf "\n=== %s ===\n\n" "$d" && git status ); done
~~~

## Meta packages

Use this template:

~~~sh
# Maintainer: none
pkgname=⟨pkgname⟩
pkgver=latest
pkgrel=1
pkgdesc='Meta package'
arch=(any)
url=about:blank
license=(custom:PublicDomain)
depends=(⟨packages⟩)
#provides=() #optional
~~~
