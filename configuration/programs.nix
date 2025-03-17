{ pkgs, ... }:

{
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  programs = {
    zsh.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      vim
      htop
      curl
      unzip
      eznetns
      usbutils
      wg-tools
    ];
  };
}
