{ pkgs ? (getFlake (toString ./.)).packages.${builtins.currentSystem}.pkgs }:
with pkgs;
mkShell {
  buildInputs = [
    nomad json2hcl crystal crystal2nix
    terranix
    nomadix-terraform
  ];
}
