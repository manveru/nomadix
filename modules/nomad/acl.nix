{ lib, ... }:
let
  inherit (lib) submodule mkOption mkEnableOption;
  inherit (lib.types) str;
in mkOption {
  description = ''
    The acl stanza configures the Nomad agent to enable ACLs and tunes various
    ACL parameters.
    Learn more about configuring Nomad's ACL system in the Secure Nomad with
    Access Control guide.
    https://learn.hashicorp.com/nomad/acls/fundamentals
  '';

  type = submodule ({ ... }: {
    options = {
      enabled = mkEnableOption ''
        Specifies if ACL enforcement is enabled.
        All other client configuration options depend on this value.
      '';

      token_ttl = mkOption {
        type = str;
        default = "30s";
        description = ''
          Specifies the maximum time-to-live (TTL) for cached ACL tokens.
          This does not affect servers, since they do not cache tokens.
          Setting this value lower reduces how stale a token can be, but
          increases the request load against servers.
          If a client cannot reach a server, for example because of an outage,
          the TTL will be ignored and the cached value used.
        '';
      };

      policy_ttl = mkOption {
        type = str;
        default = "30s";
        description = ''
          Specifies the maximum time-to-live (TTL) for cached ACL policies.
          This does not affect servers, since they do not cache policies.
          Setting this value lower reduces how stale a policy can be, but
          increases the request load against servers.
          If a client cannot reach a server, for example because of an outage,
          the TTL will be ignored and the cached value used.
        '';
      };

      replication_token = mkOption {
        type = str;
        default = "";
        description = ''
          Specifies the Secret ID of the ACL token to use for replicating
          policies and tokens.
          This is used by servers in non-authoritative region to mirror the
          policies and tokens into the local region.
        '';
      };
    };
  });
}
