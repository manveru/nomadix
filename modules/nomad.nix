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

    dataDir = mkOption {
      type = path;
      default = /var/lib/monad;
      description = ''
        Specifies a local directory used to store agent state.
        Client nodes use this directory by default to store temporary
        allocation data as well as cluster information.
        Server nodes use this directory to store cluster state, including the
        replicated log and snapshot data.
        This must be specified as an absolute path.
      '';
    };

    datacenter = mkOption {
      type = str;
      default = "dc1";
      description = ''
        Specifies the data center of the local agent.
        All members of a datacenter should share a local LAN connection.
      '';
    };

    disableAnonymousSignature = mkEnableOption ''
      Specifies if Nomad should provide an anonymous signature for
      de-duplication with the update check.
    '';

    disableUpdateCheck = mkEnableOption ''
      Specifies if Nomad should not check for updates and security bulletins.
    '';

    enableDebug = mkEnableOption ''
      Specifies if the debugging HTTP endpoints should be enabled.
      These endpoints can be used with profiling tools to dump diagnostic information about Nomad's internals.
    '';

    enableSyslog = mkEnableOption ''
      Specifies if the agent should log to syslog.
      This option only works on Unix based systems.
    '';

    httpApiResponseHeaders = mkOption {
      type = nullOr ( attrsOf str );
      default = null;
      description = ''
        Specifies user-defined headers to add to the HTTP API responses.
      '';
    };

    pluginDir = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Path to a directory with plugins to load at runtime.
      '';
    };

    acl = pkgs.callPackage ./nomad/acl.nix { };
    client = pkgs.callPackage ./nomad/client.nix { };
  };

  config = mkIf cfg.enable {
    environment.etc."/nomad.d/nomad.json".source =
      pkgs.runCommand "nomad.json" { } ''
        ${pkgs.jq}/bin/jq . < ${
          builtins.toFile "nomad.json" (builtins.toJSON cfg.extraConfig)
        } | tee $out
      '';

    systemd.services.nomad = {
      enable = true;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ iproute ];

      serviceConfig = {
        ExecReload = "${pkgs.busybox}/bin/kill -HUP $MAINPID";
        ExecStart = if cfg.pluginDir == null then
          "${cfg.package}/bin/nomad agent -config /etc/nomad.d"
        else
          "${cfg.package}/bin/nomad agent -config /etc/nomad.d -plugin-dir ${cfg.pluginDir}";
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
