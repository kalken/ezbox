{ config, variables, ... }:

{
  # hostname
  networking.hostName = variables.networking.hostName;
  
  ### networking ###
  networking.useDHCP = false;
  systemd.network.enable = true;

  # bridge
  systemd.network.netdevs."10-${variables.networking.bridge.Name}" = {
    netdevConfig = {
      Name = variables.networking.bridge.Name;
      Kind = "bridge";
    };
  };

  # bridge members
  systemd.network.networks."20-${variables.networking.bridge.Name}" = {
    matchConfig = {
      Name = variables.networking.bridge.Devices;
    };
    networkConfig = {
      Bridge = variables.networking.bridge.Name;
    };
  };

  # configure wan
  systemd.network.networks."20-wan" = {
    matchConfig = {
      Name = variables.networking.wan.Device;
    };
    networkConfig = {
      DHCP = true;
      DHCPPrefixDelegation = true;
      #IPv6PrivacyExtensions = variables.networking.wan.IPv6PrivacyExtensions;
    };
    dhcpV6Config = {
      PrefixDelegationHint = "::/56";
    };
    dhcpPrefixDelegationConfig = {
      UplinkInterface = ":self";
      SubnetId = 0;
      Announce = false;
    };
  };

  # configure bridge
  systemd.network.networks."30-${variables.networking.bridge.Name}" = {
    matchConfig = {
      Name = variables.networking.bridge.Name;
    };
    networkConfig = {
      Address = [ "${variables.networking.bridge.Address}/${variables.networking.bridge.Netmask}" ];
      IPv4Forwarding = true;
      IPv6Forwarding = true;
      VLAN = builtins.attrNames variables.networking.vlan;
      DHCPServer = true;
      DHCPPrefixDelegation = true;
      IPv6SendRA = true;
      IPv6AcceptRA = false;
      ConfigureWithoutCarrier=true;
    };
    linkConfig = {
      RequiredForOnline = "routable";    
    };
    dhcpPrefixDelegationConfig = {
      UplinkInterface = variables.networking.wan.Device;
      SubnetId= variables.networking.bridge.SubnetId;
    };
    dhcpServerConfig = {
      PoolOffset = 10;
      DNS = "_server_address";
    };
  };

  # enable ipv6 forwarding globally
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  ### firewall ###
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.firewall.filterForward = true;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = variables.networking.nat.internalInterfaces;
  networking.firewall.trustedInterfaces = variables.networking.firewall.trustedInterfaces;
  networking.firewall.extraInputRules = variables.networking.firewall.extraInputRules; 

  # enable internal dns server
  services.resolved.extraConfig = ''
    DNSStubListenerExtra=${variables.networking.bridge.Address}
  '';
}

