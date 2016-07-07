let
  tahoeStoragePort = 3457;
  creds = {
    project = "bold-taurus-123456";
    serviceAccount = "879530986753-compute@developer.gserviceaccount.com";
    accessKey = "/home/you/matador/pkey.pem";
  };
  gce = { staticIP, region }: { resources, ... }: {
    deployment.targetEnv = "gce";
    deployment.gce = creds // {
      inherit region;
      tags = [ "public-tahoe" ];
      network = resources.gceNetworks.net-tahoe;
      ipAddress = resources.gceStaticIPs."ip-${staticIP}";
    };
  };

  gce-hydra = { staticIP, region }: { resources, ... }: {
    deployment.targetEnv = "gce";
    deployment.gce = creds // {
      inherit region;
      tags = [ "public-hydra" ];
      network = resources.gceNetworks.net-hydra;
      ipAddress = resources.gceStaticIPs."ip-${staticIP}";
    };
  };
in
{
  resources.gceNetworks.net-tahoe = creds // {
    addressRange = "192.168.42.0/24";
    firewall = {
      allow-tahoe = {
        targetTags = [ "public-tahoe" ];
        allowed.tcp = [ tahoeStoragePort ];
      };
      allow-ping.allowed.icmp = null;
    };
  };

  resources.gceNetworks.net-hydra = creds // {
    addressRange = "192.168.42.0/24";
    firewall = {
      allow-tahoe = {
        targetTags = [ "public-hydra" ];
        allowed.tcp = [ 80 3000 ];
      };
      allow-ping.allowed.icmp = null;
    };
  };

  resources.gceStaticIPs.ip-alpha = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-bravo = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-charlie = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-delta = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-echo = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-foxtrot = creds // { region = "us-central1"; };
  resources.gceStaticIPs.ip-golf = creds // { region = "us-central1"; };

  resources.gceStaticIPs.ip-hotel = creds // { region = "us-east1"; };
  resources.gceStaticIPs.ip-india = creds // { region = "us-east1"; };

  resources.gceStaticIPs.ip-zulu = creds // { region = "us-east1"; };

  alpha = gce { staticIP = "alpha"; region = "us-central1-a"; };
  bravo = gce { staticIP = "bravo"; region = "us-central1-a"; };
  charlie = gce { staticIP = "charlie"; region = "us-central1-a"; };
  delta = gce { staticIP = "delta"; region = "us-central1-a"; };
  echo = gce { staticIP = "echo"; region = "us-central1-a"; };
  foxtrot = gce { staticIP = "foxtrot"; region = "us-central1-a"; };
  golf = gce { staticIP = "golf"; region = "us-central1-a"; };

  hotel = gce { staticIP = "hotel"; region = "us-east1-b"; };
  india = gce { staticIP = "india"; region = "us-east1-b"; };

  zulu = gce-hydra { staticIP = "zulu"; region = "us-east1-b"; };
}
