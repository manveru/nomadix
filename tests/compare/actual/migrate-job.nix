{ mkNomadJob }:
mkNomadJob "hello" {
  name = "foo";
  datacenters = [ "dc1" ];

  type = "batch";

  migrate = {
    maxParallel = 2;
    healthCheck = "task_states";
    minHealthyTime = "11s";
    healthyDeadline = "11m";
  };

  taskGroups.bar = {
    count = 3;

    tasks.bar = {
      driver = "raw_exec";

      config = {
        command = "bash";
        args = [ "-c" "echo hi" ];
      };
    };

    migrate = {
      maxParallel = 3;
      healthCheck = "checks";
      minHealthyTime = "1s";
      healthyDeadline = "1m";
    };
  };
}
