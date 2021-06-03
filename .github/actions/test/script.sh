#!/bin/bash
shopt -s nullglob

# Reads the values of a srcinfo attribute, returning every value as a line.
#
#     read_srcinfo <attribute_name_regex> <srcinfo_file>
#
read_srcinfo() {
    sed -n -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" "$2"
}

# Builds and installs yay.
#
#     install_yay <git-dir>
#
# yay is preferred over aurutils because it can resolve packages named by
# "provides" aliases and also packages with version constraints, both of which
# can sometimes appear in the "depends"
install_yay() (
    work_dir=$1

    git clone -q https://aur.archlinux.org/yay.git "$work_dir"
    cd "$work_dir"
    makepkg -si --noconfirm
)

# Builds and installs the package from PKGBUILD.
#
# Runs a test script.
#
#     docker_run ... build_and_install <build_dir> <out_dir>
#
# Inputs:
#
#   - <build_dir>: contains the PKGBUILD and associated files
#
# Outputs:
#
#   - <out_dir>/.SRCINFO: expected .SRCINFO file
#   - <out_dir>/dependpkgs: repo of built AUR dependencies
#   - <out_dir>/mainpkgs: repo of the main built package(s)
#
build_and_install() {
    build_dir=$1
    out_dir=$2

    echo ::group::"Install build tools"
    sudo tee -a /etc/pacman.conf <<EOF > /dev/null
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    sudo pacman -Sqyu --needed --noconfirm git namcap
    install_yay yay
    echo ::endgroup::

    # install the dependencies, followed by the package
    cp -RTp "/mnt/workspace/$build_dir" build
    (
        cd build
        makepkg --printsrcinfo >.SRCINFO

        echo ::group::"Install dependencies"
        read_srcinfo "(check|make)?depends" .SRCINFO | xargs yay -S --needed --noconfirm
        echo ::endgroup::

        echo ::group::"Build and install"
        makepkg -i --noconfirm
        echo ::endgroup::

        # workaround for https://bugs.archlinux.org/task/65042
        source=$(read_srcinfo '^source[_[:alnum:]]*' .SRCINFO)
        if [ -n "$source" ]; then
            namcap PKGBUILD
        fi
    )

    # write out the expected .SRCINFO and create the pacman repos
    sudo mkdir -p "/mnt/workspace/$out_dir/"{dependpkgs,mainpkgs}
    sudo cp -Tp build/.SRCINFO "/mnt/workspace/$out_dir/.SRCINFO"
    dependpkgs=(~/.cache/yay/*/*.pkg.tar.*)
    if [ "${#dependpkgs[@]}" -gt 0 ]; then
        sudo cp -p -t "/mnt/workspace/$out_dir/dependpkgs" "${dependpkgs[@]}"
    fi
    sudo cp -p -t "/mnt/workspace/$out_dir/mainpkgs" build/*.pkg.tar.*
    sudo repo-add -q "/mnt/workspace/$out_dir/dependpkgs/"{dependpkgs.db.tar.gz,*.pkg.tar.*}
    sudo repo-add -q "/mnt/workspace/$out_dir/mainpkgs/"{mainpkgs.db.tar.gz,*.pkg.tar.*}
}

# Initial setup for the container. Internal helper for docker_entrypoint.
docker_init() (
    echo ::group::"Docker initialization"
    useradd -m worker
    pacman -Sqyu --needed --noconfirm sudo
    echo "worker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00_worker
    echo ::endgroup::
)

# Container entrypoint for executing under a non-root, sudo-able account.
#
#     docker_entrypoint <function> [<args>...]
#
# This is an internal helper for docker_run.
docker_entrypoint() {
    docker_init
    exec sudo -Hi -u worker -- "$0" "$@"
}

# Executes a function from this script in a container.
#
#     docker_run <workspace> <image> <function> [<args>...]
#
# Mount points:
#
#   - /mnt/workspace: directory specified by <workspace>
#   - /mnt/script: directory of this script
#
docker_run() {
    workspace=$1
    image=$2
    script_dir=$(dirname $0)
    script_name=$(basename $0)
    shift 2

    docker run --rm -v "$workspace":/mnt/workspace -v "$script_dir":/mnt/script "$image" "/mnt/script/$script_name" docker_entrypoint "$@"
}

# Runs a test script.
#
#     docker_run ... run_test <out_dir> <test_script> [<args>...]
#
# Inputs:
#
#   - <out_dir>/dependpkgs: repo of built AUR dependencies, which will be made
#     available to pacman for the test script
#   - <out_dir>/mainpkgs: repo of the main built package(s), which will be made
#     available to pacman for the test script
#   - <test_script>: test script, which must be relative to the current script
#     directory
run_test() {
    out_dir=$1
    shift

    echo ::group::"Refresh Pacman"
    sudo tee -a /etc/pacman.conf <<EOF > /dev/null
[dependpkgs]
SigLevel = Optional TrustAll
Server = file:///mnt/workspace/$out_dir/\$repo

[mainpkgs]
SigLevel = Optional TrustAll
Server = file:///mnt/workspace/$out_dir/\$repo
EOF
    sudo pacman -Sqyu --needed --noconfirm
    echo ::end_group::

    echo ::group::"Test: $*"
    "/mnt/script/$@"
    echo ::end_group::
}

# Entrypoint for the GitHub action, invoked by action.yml.
#
#     main <build_dir> <out_dir>
#
# Inputs:
#
#   - <build_dir>: contains the PKGBUILD and associated files
#
# Outputs:
#
#   - <out_dir>/.SRCINFO: expected .SRCINFO file
#   - <out_dir>/dependpkgs: repo of built AUR dependencies
#   - <out_dir>/mainpkgs: repo of the main built package(s)
#
main() (
    build_dir=$1
    out_dir=$2
    workspace=$PWD
    script_dir=$(dirname "$0")

    # pre-pull with --quiet to reduce noise in logs
    docker pull -q archlinux
    docker pull -q archlinux:base-devel

    docker_run "$workspace" archlinux:base-devel build_and_install "$build_dir" "$out_dir"

    # run all tests in .github/actions/test/pkg/<pkgbase>/*.sh
    pkgbase=$(read_srcinfo pkgbase "$out_dir/.SRCINFO")
    echo ::set-output name=pkgbase::"$pkgbase"
    cd "$script_dir"
    for test_script in "pkg/$pkgbase/"*.sh; do
        docker_run "$workspace" archlinux run_test "$out_dir" "$test_script"
    done
)

set -eu
"$@"
