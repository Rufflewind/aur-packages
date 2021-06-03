set -eux

sudo pacman -S --needed --noconfirm git gitit
gitit -p 5001 &
# The -4 flag is a workaround to ensure retry:
# https://github.com/appropriate/docker-curl/issues/5#issuecomment-461338326
curl -4 -LSfs --retry-connrefused --retry 5 localhost:5001
