{ lib, variables, ... }:

let
  vlanConfig = variables.networking.vlan;

  # Function to generate netdev configuration for a VLAN
  mkVlanNetdev = name: vlan: {
    "40-${name}" = {
      netdevConfig = {
        Name = name;
        Kind = "vlan";
      };
      vlanConfig = {
        Id = vlan.Id;
      };
    };
  };

  # Function to generate network configuration for a VLAN
  mkVlanNetwork = name: vlan: {
    "50-${name}" = {
      matchConfig = {
        Name = name;
      };
      networkConfig = {
        Address = [ "${vlan.Address}/${vlan.Netmask}" ];
        IPv4Forwarding = true;
        IPv6Forwarding = true;
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
        SubnetId = vlan.SubnetId;
      };
      dhcpServerConfig = {
        PoolOffset = 10;
        DNS = "_server_address";
      };
    };
  };

  # Generate all VLAN netdevs and networks dynamically using concatMapAttrs
  vlanNetdevs = lib.attrsets.concatMapAttrs mkVlanNetdev vlanConfig;
  vlanNetworks = lib.attrsets.concatMapAttrs mkVlanNetwork vlanConfig;

  generateExtraConfig = vlan:
    let
      # Map over vlan attributes, creating a line for each Address
      lines = builtins.attrValues (builtins.mapAttrs (name: value: 
        "DNSStubListenerExtra=${value.Address}"
      ) vlan);
    in
      # Join lines with newlines
      builtins.concatStringsSep "\n" lines;

in
{
  # Merge the generated configurations into systemd.network
  systemd.network.netdevs = vlanNetdevs;
  systemd.network.networks = vlanNetworks;
  services.resolved.extraConfig = ''
    ${generateExtraConfig variables.networking.vlan}
  '';
}
