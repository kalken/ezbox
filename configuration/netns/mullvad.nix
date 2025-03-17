{ pkgs, ... }:

let
  netns = "mullvad";
  proxyd = {
    source = {
      interface = "lo";
      port = "1081";
    };
    target = "127.0.0.1:1080";
  };
  netnsService = {
    unitConfig = {
      Requires = [ "netns@${netns}.service" ];
      After=[ "netns@${netns}.service" ];
    };
    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${netns}";
      BindReadOnlyPaths = [
        "/etc/eznetns/${netns}/resolv.conf:/etc/resolv.conf"
        "/etc/eznetns/${netns}/nsswitch.conf:/etc/nsswitch.conf"
        "/var/empty:/var/run/nscd"
      ];
    };
  };
in

{
  # netns configuration
  environment.etc = {
    "eznetns/${netns}/nsswitch.conf" = {
      text = ''
        passwd:         files
        group:          files
        shadow:         files
        gshadow:        files
        hosts:          files dns myhostname
        networks:       files
        protocols:      db files
        services:       db files
        ethers:         db files
        rpc:            db files
        netgroup:       nis
      '';
    };
    "eznetns/${netns}/nftables.conf" = {
      text = ''
        #!/usr/sbin/nft -f
        define wan = wg0-${netns}
        flush ruleset
        table inet filter {
          chain input {
            type filter hook input priority filter; policy drop
            # allow established/related connections
            ct state {established, related} accept
            # early drop of invalid connections
            ct state invalid drop
            # allow icmp ping etc
            icmp type echo-request accept
            icmpv6 type != { nd-redirect, 139 } accept
            # allow from loopback
            iifname lo accept
            # example open port 443
            #iifname $wan tcp dport 443 accept
            #iifname $wan udp dport 443 accept
            # count packages
            # counter comment "count dropped packets"
            # everything else
            reject with icmp type port-unreachable
            reject with icmpv6 type port-unreachable
          }
          chain forward {
            type filter hook forward priority filter; policy drop
            # allow response on open ports
            ct state established,related accept
          }  
          chain output {
            type filter hook output priority filter; policy accept
          }
        }
      '';
    };
  };

  # targets 
  systemd.targets."${netns}" = {
    enable = true;
    unitConfig =  {
      Requires = [ 
        "prettysocks@${netns}.service"
      ];
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  # port forward
  systemd.services."${netns}" = {
    unitConfig = {
      Requires = [
        "netns@${netns}.service"
        "${netns}.socket"
      ];
      After = [
        "netns@${netns}.service"
        "${netns}.socket"
      ];
    };
    serviceConfig =  {
      NetworkNamespacePath="/run/netns/${netns}";
      #ExecStartPre = "${pkgs.eznetns}/bin/ezwgen --netns ${netns} --dev  wg0-${netns} --pattern got";
      ExecStart="${pkgs.systemd.out}/lib/systemd/systemd-socket-proxyd ${proxyd.target}";
    };
  };
  systemd.sockets."${netns}" =  {
    socketConfig = {
      ListenStream="${proxyd.source.port}";
      BindToDevice="${proxyd.source.interface}";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
