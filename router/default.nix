# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, ... }:

{
  imports = [ 
    ./overlays.nix
    ./boot.nix
    ./system.nix
    ./vlans.nix
  ];
  
  options.variables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };
  config._module.args.variables = config.variables;
}
