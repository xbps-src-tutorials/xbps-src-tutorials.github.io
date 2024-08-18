let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs {};
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    bash
    mdbook
    mdbook-toc
    mdbook-admonish
  ];
}
