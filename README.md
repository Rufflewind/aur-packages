# AUR packages

To avoid forgetting to update `.SRCINFO`, be sure to add the pre-commit hooks, as shown in the commands below.

## Initializing the submodules

Run this the first time you clone `aur-packages`.

~~~sh
git submodule update --init --recursive &&
git config -f .gitmodules --path --get-regexp path | cut -f 2 -d " " |
    while read -r dir; do
        git_dir=`git -C "${dir}" rev-parse --git-dir`
        cp -i -p pre-commit "${git_dir}/hooks/pre-commit"
    done
~~~

## Cloning repositories

Run this to clone new or existing packages:

~~~sh
pkgname=<pkgname>

git clone "aur@aur.archlinux.org:${pkgname}" &&
(
    cd "${pkgname}" &&
    cp -p ../pre-commit "`git rev-parse --git-dir`/hooks/pre-commit" &&
    git-config-user-aur
)
~~~

Then add it as a submodule of `aur-packages`:

~~~sh
git submodule add "aur@aur.archlinux.org:${pkgname}" &&
~~~

If the package doesn't exist, the previous command will succeed but it won't add the magical gitlink entry that anchors the submodule to a specific commit as there is no commit yet.  To remedy this, make a commit in the submodule, then run `git add <pkgname>` in the parent repository to add the gitlink entry.
