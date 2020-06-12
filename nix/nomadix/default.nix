{ crystal, inclusive }: crystal.buildCrystalPackage {
  pname = "nomadix";
  version = "0.1.0";
  format = "crystal";

  src = inclusive ../../. [ ../../src ];

  shardsFile = ../../shards.nix;

  crystalBinaries.nomadix.src = "src/nomadix.cr";
}
