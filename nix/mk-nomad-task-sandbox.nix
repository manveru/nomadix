{ writeShellScriptBin, writeReferencesToFile, writeText, lib, systemd }:
{ name, command, args ? [ ], env ? { }, extraSystemdProperties ? { } }:
let
  inherit (builtins) foldl' typeOf attrNames attrValues;
  inherit (lib) flatten pathHasContext isDerivation;
  pp = lib.traceShowVal;

  onlyStringsWithContext = sum: input:
    let type = typeOf input;
    in sum ++ {
      string = if pathHasContext input then [ input ] else [ ];
      list =
        (foldl' (s: v: s ++ (onlyStringsWithContext [ ] v)) [ ] input);
      set = if isDerivation input then
        [ input ]
      else
        (onlyStringsWithContext [ ] (attrNames input))
        ++ (onlyStringsWithContext [ ] (attrValues input));
    }.${typeOf input} or [ ];

  closure = writeText "${name}-closure" (lib.concatStringsSep "\n"
    (onlyStringsWithContext [ ] [ command args env ]));

  references = writeReferencesToFile closure;

  lines = (lib.splitString "\n" (lib.fileContents references));
  cleanLines = lib.remove closure.outPath lines;

  paths = map (line: "${line}:${line}") cleanLines;

  transformAttrs = transformer:
    lib.mapAttrsToList (name: value: "${name}=${transformer value}");

  toSystemd = value:
    if value == true then
      "yes"
    else if value == false then
      "no"
    else
      toString value;

  toSystemdProperties = transformAttrs toSystemd;

  systemdRunFlags = lib.cli.toGNUCommandLineShell { } {
    # unit = "figure-out-a-way-to-name-it-nicely";
    service-type = "exec";
    collect = true;
    wait = true;
    setenv = transformAttrs toString env;
    property = transformAttrs toSystemd ({
      MemoryMax = "100M";
      CPUWeight = "50";
      CPUQuota = "20%";
      DynamicUser = true;
      PrivateDevices = true;
      ProtectSystem = true;
      PrivateMounts = true;
      PrivateUsers = true;
      PrivateTmp = true;
      MountAPIVFS = true;
      RootDirectory = "/tmp/run";
      TemporaryFileSystem = "/nix/store:ro";
      BindReadOnlyPaths = paths;
      ProtectHome = true;
      MemoryDenyWriteExecute = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
    } // extraSystemdProperties);
  };

  runner = writeShellScriptBin "systemd-runner" ''
    echo entering ${placeholder "out"}/bin/runner
    echo dependencies are:
    for i in ${toString cleanLines}; do
      echo $i
    done

    set -exuo pipefail

    PATH=${lib.makeBinPath [ systemd ]}

    exec systemd-run ${systemdRunFlags} -- "$@"
  '';
in {
  inherit name env;
  driver = "raw_exec";
  config = {
    command = "${runner}/bin/systemd-runner";
    args = [ command ] ++ args;
  };
}
