{ callPackage, ... }: {
  nomadix = callPackage ./nomadix { };
  examples = callPackage ../example { };
  mkNomadJob = callPackage ./mk-nomad-job.nix { };
  mkNomadTaskSandbox = callPackage ./mk-nomad-task-sandbox.nix { };
}
