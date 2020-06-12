{ writeText, lib, pkgs, callPackage }:
name: configuration:
let
  inherit (builtins) length mapAttrs attrNames typeOf;
  inherit (lib) flip const evalModules getAttrs remove pipe;

  ignoredAttrs = [ "_ref" "_module" ];
  pp = v: __trace (__toJSON v) v;

  sanitize = value:
    let
      type = typeOf value;
      sanitized = if type == "list" then
        map sanitize value
      else if type == null then
        null
      else if type == "set" then
        pipe (attrNames value) [
          (remove "_ref")
          (remove "_module")
          (flip getAttrs value)
          (mapAttrs (const sanitize))
        ]
      else
        value;
    in sanitized;

  evaluateConfiguration = configuration:
    evalModules {
      modules = [ { imports = [ ./modules/job.nix ]; } configuration ];
      specialArgs = { inherit pkgs; };
    };

  nomadix = configuration:
    let evaluated = evaluateConfiguration configuration;
    in sanitize evaluated.config;

  evaluated = nomadix configuration;

  json = writeText "${name}.json" (builtins.toJSON evaluated);

  run = callPackage ./run-nomad-job.nix { inherit json name; };
in {
  inherit json evaluated run;
}
