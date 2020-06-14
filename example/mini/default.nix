{ lib, makeWrapper, mkNomadTaskSandbox, mkNomadJob, runCommand, bash, coreutils
, hello, tree, bat }:
let
  mini = runCommand "mini" { buildInputs = [ makeWrapper bash ]; } ''
    install -D -m 0766 ${./mini.sh} $out/bin/mini
    wrapProgram $out/bin/mini --set PATH ${lib.makeBinPath [ coreutils hello ]}
    patchShebangs $out
  '';

  helloTask = mkNomadTaskSandbox {
    name = "hello";
    args = [ "--run" "${bat}/bin/bat" ];
    env = { TREE = "${tree}/bin/tree"; };
    command = "${mini}/bin/mini";
  };
in
  mkNomadJob "hello" {
    jobs.foo = {
      datacenters = [ "dc1" ];
      type = "service";
      taskGroups.testing = {
        count = 1;
        tasks.hello = helloTask;
      };
    };
  }
