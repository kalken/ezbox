{ pkgs, ... }:

{
  users = {
    users."default" = {
      isNormalUser = true;
      # extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ];
      packages = with pkgs; [
        zsh
        git
      ];
    };
  };
}
