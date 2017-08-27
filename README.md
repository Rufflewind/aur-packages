# AUR packages

To avoid forgetting to update `.SRCINFO`, be sure to add the pre-commit hooks,
as shown in the commands below.

## Initial clone of `aur-packages`

On the first clone of `aur-packages`, run `./init` to initialize the
submodules properly.

## Management

### Making quick commits

To make a quick commit within a submodule, do:

~~~sh
git commit -m `../getpkgver`
~~~

### Cloning new or existing packages

 1. First run:

    ~~~sh
    ./clone-aur ⟨pkgname⟩
    ~~~

 2. If the package doesn’t yet exist, go make a commit in the subdirectory now
    and then go back to the parent directory for the next step.  If the
    package does already exist, skip this step.

 3. Run this to add the subdirectory as a submodule:

    ~~~sh
    git submodule add aur@aur.archlinux.org:⟨pkgname⟩
    ~~~

The reason for the second step is that if the package doesn’t exist, `git
submodule add` will only partially succeed.  It won’t add the magical gitlink
entry that anchors the submodule to a specific commit as there is no commit
yet.  If you called `git submodule add` too early, you make a commit in the
submodule as in step 2 and then run `git add ⟨pkgname⟩` in the parent
repository to add the missing gitlink entry.

## Google Font packages

 1. If you want this package to be managed by `aur-packages`, first do a
    [clone](#Cloning repositories).  Otherwise, skip this step.

 2. Edit `google-font-pkgs.conf`, if necessary.

 3. Run `./pkg-google-font` in the top level directory of this repository.

 4. If you did step 1, now is the time to go into `ttf-⟨name⟩-gf` and commit
    the files.  Then go back out and run `git add` on the submodule.

### Updating

To do updates, just run `./pkg-google-font ⟨name⟩…`, then check if anything
needs to be committed:

~~~sh
for d in ttf-*; do ( cd "$d" && echo "—— $d ——" && git status ); done
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
