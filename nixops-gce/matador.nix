let
  # NixOS description for Tahoe storage nodes.
  storage = nodeName: { config, pkgs, ... }:
  let
    tahoeWebPort = 3456;
    tahoeStoragePort = 3457;
    ipAddress = config.deployment.gce.ipAddress.publicIPv4;
  in
  {
    # The NixOS release to be compatible with for stateful data such as databases.
    system.stateVersion = "15.09";

    # Anti-bufferbloat.
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq_codel";
    };

    environment.systemPackages = with pkgs; [
      # Essential shell tools
      vimNox
      tmux
      # Administration
      eventstat
      htop
      iftop
      iotop
      iptables
      # Development
      # git
      # nix-repl
    ];

    networking.firewall = {
      allowPing = true;
      allowedTCPPorts = [ tahoeWebPort tahoeStoragePort ];
    };
  
    # System services.
    services = {
      # Stop annoying SSH attempts, part one. This is pretty much essential
      # for GCE, as otherwise your machines will spend lots of precious CPU
      # time and network traffic responding to SSH attempts from scanners.
      fail2ban.enable = true;

      # Stop annoying SSH attempts, part two. The attackers seem to almost
      # always use password-interactive authentication, but nixops uses keys;
      # we can cut them off easily.
      openssh.passwordAuthentication = false;

      # Main Tahoe node configuration.
      tahoe.nodes."storage-${nodeName}" = {
        nickname = "storage-${nodeName}";
        tub.port = tahoeStoragePort;
        tub.location = "${ipAddress}:${toString tahoeStoragePort}";
        web.port = tahoeWebPort;
        client = {
          introducer = "<your introducer here>";
        };
        storage = {
          enable = true;
          reservedSpace = "256M";
        };
      };
    };
  };
in
{
  network = {
    description = "Matador Tahoe grid";
    enableRollback = true;
  };

  # Eight servers, with 3/7/10 shares, for N+1 write availability and 3N+1
  # read availability.
  alpha = storage "alpha";
  bravo = storage "bravo";
  charlie = storage "charlie";
  delta = storage "delta";
  echo = storage "echo";
  foxtrot = storage "foxtrot";
  golf = storage "golf";
  hotel = storage "hotel";
}
