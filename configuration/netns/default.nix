{ pkgs, ... }:

{
  imports = [ 
    # Include the results of the hardware scan.
    ./mullvad.nix
  ];

  users = {
    groups."proxy" = {};
    users."proxy" = {
      isSystemUser = true;
      group = "proxy";
    };
  };

  systemd.services."netns@" = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";  # Service runs once and exits
      ExecStart = "${pkgs.eznetns}/bin/eznetns %i setup";  # Command to run when starting
      ExecStop = "${pkgs.eznetns}/bin/eznetns %i remove";  # Command to run when stopping
      RemainAfterExit = true;  # Keeps the service in 'active' state after completion
    };
  };

  systemd.services."prettysocks@" = {
    enable = true;
    unitConfig = {
      Description="pretty vpn";
      Requires="netns@%i.service";
      After="netns@%i.service";
    };
    serviceConfig = {
      User="proxy";
      StandardError="null";
      ExecStart="${pkgs.prettysocks}/bin/prettysocks";
      NetworkNamespacePath="/run/netns/%i";
      BindReadOnlyPaths = [
        "/etc/eznetns/%i/resolv.conf:/etc/resolv.conf"
        "/etc/eznetns/%i/nsswitch.conf:/etc/nsswitch.conf"
        "/var/empty:/var/run/nscd"
      ];
    };
  };

}
