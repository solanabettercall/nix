let
  rootDomain = "bettercallsolana.chickenkiller.com";
  mkDomain = subdomain: "${subdomain}.${rootDomain}";
in
{
  inherit rootDomain;
  acmeEmail = "admin@${rootDomain}";
  records = {
    ares = {
      fqdn = mkDomain "ares";
      target = {
        machineId = "ares";
      };
    };
    media = {
      fqdn = mkDomain "media";
      target = {
        machineId = "ares";
      };
    };
  };
}
