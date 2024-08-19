#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash mdbook mdbook-toc mdbook-admonish
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/tarball/nixos-24.05

exec ./book.sh "$@"
