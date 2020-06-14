{ mkNomadJob }:
mkNomadJob "foo" {
  datacenters = ["dc1"];
  periodic = {
    cron             = "*/5 * * *";
    prohibitOverlap = true;
    timeZone        = "Europe/Minsk";
  };
}
