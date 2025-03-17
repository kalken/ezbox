{ pkgs, variables, ... }:

let
  netatalk = {
    path = "/path/to/timemachine";
  };
  samba = {
    guest = "myuser";
    share = {
      name = "myshare";
      path = "/path/to/myshare";
    };
  };
in

{

  # enable ssh
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  services.openssh.settings.PasswordAuthentication = false;

  # enable eternal terminal service
  services.eternal-terminal.enable = true;

  # enable fstrim (TRIM for ssds)
  services.fstrim.enable = true;

  # unifi
  services.unifi.enable = true;
  # newest version of unifi controller
  services.unifi.unifiPackage = pkgs.unstable.unifi8;
  #services.unifi.unifiPackage = pkgs.unifi8;
  # mongodb-ce because it does not need to be compiled from source
  services.unifi.mongodbPackage = pkgs.mongodb-ce;

  # prettysocks
  systemd.services."prettysocks" = {
    enable = true;
    serviceConfig = {
      User="proxy";
      StandardError="null";
      ExecStart="${pkgs.prettysocks}/bin/prettysocks";
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  # nettalk (time machine backups)
  services.netatalk.enable = true;
  services.netatalk.settings = {
    "Global" = {
      "afp interfaces" = variables.networking.bridge.Name;
    };
    "Time Machine" = {
      "hosts allow" = "192.168.3.0/24";
      "path" = netatalk.path;
      "time machine" = "yes";
      "invalid users" = "root";
      "vol size limit"="1000000";
    };
  };

  # samba (public share)
  services.samba = {
    enable = true;
    settings = {
      global = {
        "min protocol" = "SMB3";
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "server role" = "standalone server";
        "bind interfaces only" = "Yes";
        "interfaces" = "lo ${variables.networking.bridge.Name}";
        "wins support" = "Yes";
	"dns proxy" = "Yes";
        "security" = "user";
        "domain master" = "Yes";
        "guest account" = samba.guest;
        "map to guest" = "Bad User";
        "hosts allow" = "192.168.0. 192.168.3. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        ## mac optimizations
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      "${samba.share.name}" = {
        "path" = samba.share.path;
        "read only" = "No";
        "guest ok" = "Yes";
        "guest only" = "Yes";
      };
    };
  };
}
