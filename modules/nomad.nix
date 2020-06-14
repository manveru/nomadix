{ config, lib, pkgs, ... }:
let
  cfg = config.services.nomad;

  inherit (lib) mkOption mkEnableOption mkIf;
  inherit (lib.types) attrs nullOr attrsOf path package str;
in {
  options.services.nomad = {
    enable = mkEnableOption { };

    package = mkOption {
      type = package;
      default = pkgs.nomad;
      defaultText = "pkgs.nomad";
      description = "The nomad package to use.";
    };

    extraConfig = mkOption {
      type = attrs;
      default = { };
      description = ''
        Configuration options that are passed to Nomad;
      '';
    };

    pluginDir = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Path to a directory with plugins to load at runtime.
      '';
    };

    configDir = mkOption {
      type = nullOr path;
      default = /etc/nomad.d;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."/nomad.d/nomad.json".source =
      builtins.toFile "nomad.json" (builtins.toJSON cfg.extraConfig);

    systemd.services.nomad = {
      enable = true;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ iproute ];

      serviceConfig = {
        ExecReload = "${pkgs.busybox}/bin/kill -HUP $MAINPID";
        ExecStart = let
          args = [ "${cfg.package}/bin/nomad" "agent" ]
            ++ (lib.optionals (cfg.configDir != null) [
              "-config"
              (toString cfg.configDir)
            ]) ++ (lib.optionals (cfg.pluginDir != null) [
              "-plugin-dir"
              (toString cfg.pluginDir)
            ]);
        in lib.concatStringsSep " " args;
        KillMode = "process";
        LimitNOFILE = "infinity";
        LimitNPROC = "infinity";
        TasksMax = "infinity";
        Restart = "on-failure";
        RestartSec = 2;
        StartLimitBurst = 3;
        StartLimitIntervalSec = 10;
      };
    };
  };
}
