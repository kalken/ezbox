# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ variables, ... }:

{
  # boot
  boot.kernelPackages = variables.boot.kernelPackages;
  boot.kernelParams = variables.boot.kernelParams;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.initrd.availableKernelModules = variables.boot.initrd.availableKernelModules;
  boot.initrd.network.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;

  # configure network for remote unlocking
  boot.initrd.systemd.network.networks."20-wlan" = {
    matchConfig.Name = variables.networking.wan.Device;
    networkConfig.DHCP = true;
  };
  
  # enable ssh access for unlocking drive
  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = variables.boot.initrd.network.ssh.authorizedKeys;
    hostKeys = variables.boot.initrd.network.ssh.hostKeys;
    port = 22;
  };

  # system
  system.stateVersion = "24.11"; 
}
