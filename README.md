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

Hint: You can use arch-chroot.sh in Rufflewind/config to do this.

~~~sh
yay -S --needed cabal-install
yay -S --needed --mflags=--nocheck "ghc9.0"
make -C haskell
cp haskell/dist/gitit/{PKGBUILD,.SRCINFO} pkg/gitit
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
