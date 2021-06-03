set -eux

sudo pacman -S --needed --noconfirm ghc-pristine
/usr/share/ghc-pristine/bin/ghc --version
