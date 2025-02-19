{ pkgs, host, options, ... }:
{
  networking = {
    hostName = host;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager.enable = true;
    # timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    # firewall = {
      # enable = true;
      # allowedTCPPorts = [
        # 22
        # 80
        # 443
        # 59010
        # 59011
      # ];
      # allowedUDPPorts = [
        # 59010
        # 59011
      # ];
    # };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
