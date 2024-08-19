#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash curl cacert mdbook mdbook-toc mdbook-admonish
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/tarball/nixos-24.05

# Please also check $MDBOOK_CATPPUCCIN_VERSION in book.sh when searching for
# versions.

exec sh ./book.sh "$@"
