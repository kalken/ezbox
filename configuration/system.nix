{ pkgs, ... }:

{
  # experimental tools
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "06:00";
  system.autoUpgrade.randomizedDelaySec = "45min";
  system.autoUpgrade.flake = "/etc/nixos/.#ezbox";
  systemd.services.nixos-upgrade.serviceConfig ={
    ExecStartPre="${pkgs.nix}/bin/nix flake update --flake /etc/nixos";
  };

  # automatic cleaning
  nix.optimise.automatic = true;
  nix.optimise.dates = ["03:45"];
  
  # garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  # console
  console = {
    font = "Lat2-Terminus16"; 
    keyMap = "sv-latin1";
  };

  # timezone and regional settings
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
}
