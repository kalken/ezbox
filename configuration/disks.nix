{ ... }:

{
  boot.initrd.luks.devices."rootfs" = {
    device = "/dev/disk/by-label/rootfs_luks";
    allowDiscards = true;
  };
  
  # disks
  fileSystems."/" = {
    device = "/dev/mapper/rootfs";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/bootfs";
    fsType = "vfat";
  };

  #environment.etc."crypttab".text = ''
  #    mydrive LABEL="mydrive_luks" /root/.keys/mydrive.key luks,nofail
  #  '';
  #
  #fileSystems."/media/mydrive" = {
  #  device = "/dev/mapper/mydrive";
  #  options = [ "nofail" ];
  #};
}
