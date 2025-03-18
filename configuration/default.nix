{ ... }:

{
  imports = [ 
    ./variables.nix
    ./disks.nix
    ./overlays.nix
    ./system.nix
    ./services.nix
    ./programs.nix
    ./users.nix
    ./netns
  ];
}
