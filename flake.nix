{
  description = "A flake for Nomadix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixpkgs-unstable";
    inclusive.url = "github:manveru/nix-inclusive";
    utils.url = "github:numtide/flake-utils";
    terranix = {
      url = "github:mrVanDalo/terranix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }@flake-inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./nix/overlay.nix { inherit flake-inputs; }) ];
        };
      in rec {
        packages = { inherit pkgs; } // pkgs.packages;
        apps = { inherit (packages) nomadix; };
        defaultApp = apps.nomadix;
        defaultPackage = apps.nomadix;
        devShell = import ./shell.nix { inherit pkgs; };
      });
}
