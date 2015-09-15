# AUR packages

## Cloning

Clone using the script to avoid forgetting to update `.SRCINFO`.

    ./clone <pkgname>

However, if the package doesn't exist, this will fail as submodules don't
support empty repos.  To work around this, clone normally first:

    ./clone -n <pkgname>

Make one commit, push, and then delete the repo.  Afterwards, you can clone
using submodules as usual.
