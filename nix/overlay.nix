{ flake-inputs, ... }:
final: prev: rec {
  packages = final.callPackage ./packages.nix { };
  inclusive = flake-inputs.inclusive.lib.inclusive;
  inherit (packages) mkNomadJob mkNomadTaskSandbox;
  terranix = prev.callPackage flake-inputs.terranix { };
  nomadix-terraform = prev.terraform.withPlugins (plugins: [
    plugins.hcloud
    plugins.null
    plugins.nixos
    plugins.gandi
    plugins.local
  ]);
}
