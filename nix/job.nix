{ config, lib, ... }:
let
  cfg = config.job;
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) submodule str enum ints listOf attrsOf attrs;

  taskGroupType = submodule ({ name, ... }: {
    options = {
      count = mkOption {
        type = ints.positive;
        default = 1;
        description = ''
          Specifies the number of the task groups that should be running under
          this group.
        '';
      };

      name = mkOption {
        type = str;
        default = name;
      };

      tasks = mkOption {
        type = attrsOf taskType;
        default = { };
        description = "";
        apply = lib.mapAttrsToList (_: value: value);
      };
    };
  });

  taskType = submodule ({ name, ... }: {
    options = {
      config = mkOption {
        type = attrs;
        default = { };
        description = ''
          Specifies the driver configuration, which is passed directly to the
          driver to start the task.
          The details of configurations are specific to each driver, so please
          see specific driver documentation for more information.
          https://www.nomadproject.io/docs/drivers
        '';
      };

      driver = mkOption {
        type = str;
        description = ''
          Specifies the task driver that should be used to run the task.
          See the driver documentation for what is available.
          Examples include docker, qemu, java and exec.
          https://www.nomadproject.io/docs/drivers
        '';
      };

      name = mkOption {
        type = str;
        default = name;
      };

      env = mkOption {
        type = attrsOf str;
        default = { };
        description = ''
          Specifies environment variables that will be passed to the running process.
        '';
      };
    };
  });

  jobType = submodule ({ name, ... }: {
    options = {
      allAtOnce = mkEnableOption ''
        Controls whether the scheduler can make partial placements if
        optimistic scheduling resulted in an oversubscribed node.
        This does not control whether all allocations for the job, where all
        would be the desired count for each task group, must be placed
        atomically.
        This should only be used for special circumstances.
      '';

      datacenters = mkOption {
        type = listOf str;
        description = ''
          A list of datacenters in the region which are eligible for task placement.
          This must be provided, and does not have a default.
        '';
      };

      taskGroups = mkOption {
        type = attrsOf taskGroupType;
        default = { };
        apply = lib.mapAttrsToList (_: value: value);
        description = ''
          Specifies the start of a group of tasks.
          This can be provided multiple times to define additional groups.
          Group names must be unique within the job file.
        '';
      };

      id = mkOption {
        type = str;
        default = name;
      };

      name = mkOption {
        type = str;
        default = name;
      };

      type = mkOption {
        type = enum [ "service" "system" "batch" ];
        default = "service";
        description = ''
          Specifies the Nomad scheduler to use.
          Nomad provides the service, system and batch schedulers.
          https://www.nomadproject.io/docs/schedulers/
        '';
      };
    };
  });
in {
  options.jobs = mkOption {
    type = attrsOf jobType;
    default = { };
    apply = lib.mapAttrsToList (_: value: value);
    description = ''
      Specifies the start of a group of tasks.
      This can be provided multiple times to define additional groups.
      Group names must be unique within the job file.
    '';
  };
}
