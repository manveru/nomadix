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

  tests.actual = let
    inherit (prev) lib fetchFromGitHub runCommand jq nodejs nomad;
    inherit (lib) mapAttrs' removeSuffix;
    inherit (prev.haskellPackages) aeson-diff;
    expectedDir = __readDir ../tests/compare/expected;
    normalize = "${jq}/bin/jq 'fromstream(tostream | select(length == 1 or .[1] != null))'";
  in mapAttrs' (hclName: type:
    let base = removeSuffix ".hcl" (baseNameOf hclName);
    in {
      name = base;
      value = let
        # This converts the HCL file to a JSON job that is accepted by the Nomad API.
        # Unfortunately the Go JSON serializer includes all fields on the Job
        # struct, and that includes a bunch of things that are only needed when
        # you try to query the Job status from the API, but aren't actually
        # used for creating jobs.
        # So here we try to clean that mess up a bit.
        expected = runCommand "${hclName}.expected.json" { } ''
          ${nomad}/bin/nomad job run -output ${
            ../tests/compare/expected + "/${hclName}"
          } | \
          ${normalize} | \
          ${jq}/bin/jq 'del(
            .Job.Dispatched,
            .Job.TaskGroups[].Tasks[].Leader,
            .Job.TaskGroups[].Tasks[].Kind
          )' \
          > $out
        '';
        base = removeSuffix ".hcl" (baseNameOf hclName);
        case = ../tests/compare/actual + "/${base}.nix";
        actual = runCommand "${hclName}.actual.json" { } ''
          cat ${(final.callPackage case { }).json} | \
          ${normalize} \
          > $out
        '';
      in runCommand "${base}-equals" { } ''
        echo 'diff ${actual} -> ${expected}'
        ${aeson-diff}/bin/json-diff ${actual} ${expected} | ${jq}/bin/jq . | tee $out
      '';
    }) (lib.filterAttrs (name: type: type == "regular") expectedDir);
}
