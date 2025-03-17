# /etc/nixos/flake.nix
{
  description = "ezbox";
  
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable ={
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    eznetns = {
      url = "github:kalken/eznetns";
      flake = false;
    };
    prettysocks = {
      url = "github:twisteroidambassador/prettysocks";
      flake = false;
    };
    wg-tools = {
      url = "github:mullvad/wg-tools";
      flake = false;
    };
  };
  
  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      ezbox = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
