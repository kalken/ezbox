{ pkgs, config, ... }:

{
  variables = {
    # use latest stable kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [];
    boot.initrd.availableKernelModules = [ "igc" ];
    # ssh keys for initrd
    boot.initrd.network.ssh.authorizedKeys = [ 
      "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    ];
    boot.initrd.network.ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];

    # hostname
    networking.hostName = "ezbox";
   
    networking = {
      # external interface
      wan = {
        Device = "enp7s0";
        #IPv6PrivacyExtensions = false;
      };

      # internal interfaces
      bridge = {
        Name = "switch";
        Devices = "enp1s0 enp2s0 enp3s0 enp4s0 enp5s0";
        Address = "192.168.0.2";
        Netmask = "24";
        SubnetId = 1;
      };

      # define as many as you need
      vlan = {
        iot = {
          Address = "192.168.2.1";
          Netmask = "24";
          Id = 2;
          SubnetId = 2;
        };
        tap = {
          Address = "192.168.3.1";
          Netmask = "24";
          Id = 3;
          SubnetId = 3;
        };
      };
      
      # interfaces to masquerade to internet
      nat.internalInterfaces = [ config.variables.networking.bridge.Name "tap" "iot" ];
      
      # interfaces to trust without firewall
      firewall.trustedInterfaces = [ config.variables.networking.bridge.Name "tap" ];
      
      # extra firewall rules
      firewall.extraInputRules = ''
        iifname ${config.variables.networking.wan.Device} tcp dport ssh ct state new meter ssh { ip saddr limit rate 5/hour } accept
        iifname ${config.variables.networking.wan.Device} tcp dport 2022 ct state new meter et { ip saddr limit rate 5/hour } accept
        iifname "iot" udp dport {53,67} ct state new accept
      '';
    };
  };
}
