# Ezbox instructions
This is a stand alone setup that could cover a "home" setup. If you buy hardware that has several network ports the setup can act as router, server and switch. The setup should run x86 hardware with atleast two lan ports (one for Wan and one for Lan is recommended).

    My complete home setup is:
    Brand: CWWK 
    Model: CW-ADLN-6L
    Wifi: Unifi 7 pro (external access point)

Look a [topton](https://www.toptonpc.com/product-category/industrial-mini-pc/) for inspiration. Some places to buy are either amazon or aliexpress.

## Main features
* Disk encryption (luks encrypted disk that can be remotely unlocked)
* Firewall (nftables)
* Dhcp (ipv6/ipv4)
* Dns (dns on each vlan)
* Switch (if your hardware has several lan ports)
* Server (supports services and packages from nixos)
* Vlans (with ipv6 subnetting)

## Other functionality
* Isolated netns (as many as you want, with wireguard and nftables firewall support)
* Put any Service or process in a specified netns
* [eznetns](https://github.com/kalken/eznetns) - simplify netns setup
* [prettysocks](https://github.com/twisteroidambassador/prettysocks) -  small proxy with happy eyeballs support.
* [wg-tools](https://github.com/mullvad/wg-tools) - easily generate and update mullvad vpn configurations. can be used in combination with eznetns. 

Supports basically anything nixos/linux is capable of doing. Can be extended with about 120 000 packages through nixpkgs. 


## Download Installation media
get an iso from https://nixos.org/download/
Minimal iso recommended for a text based install. Write it to usb and boot. Follow the installation guide but use this repository as a replacement for the nixos folder.

## Disk
if drive is **/dev/nvme0n1**
    
    # create partitions   
    parted -s /dev/nvme0n1 -- mklabel gpt
    parted -s /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
    parted -s /dev/nvme0n1 -- mkpart root ext4 512MB 100%
    
    # format
    mkfs.fat -F 32 -n bootfs /dev/nvme0n1p1
    parted /dev/nvme0n1 -- set 1 esp on
    cryptsetup luksFormat /dev/nvme0n1p2 --label rootfs_luks
    cryptsetup luksOpen /dev/nvme0n1p2 rootfs
    mkfs.ext4 -L rootfs /dev/mapper/rootfs
    
    # mount
    mount /dev/mapper/rootfs /mnt/
    mkdir -p /mnt/boot/
    mount /dev/disk/by-label/bootfs /mnt/boot
    
    # create keys
    mkdir -p /mnt/etc/secrets/initrd
    ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

    # generate stub files
    
    cd /mnt/etc/nixos
    nixos-generate-config --no-filesystems --root /mnt
    
    # move ezbox files to /mnt/etc/nixos
    cp -r path/to/folder /mnt/etc/nixos
    
    # edit the files to make it your system
    # you should edit the files in /mnt/etc/nixos/configuration folder.
    
    # install
    nixos-install --flake /mnt/etc/nixos/.#ezbox

    # reboot and enjoy!
    


## Preparation

**Edit** or at least check all files in /etc/nixos.
Anything in **configuration** folder can be changed. The **router** folder contains system setup and should not have to be changed.

## Cofiguration
* default.nix - Decides which other nix-files are included in the setup.
* disks.nix - disks and mounts
* overlays.nix - can be used to change versions of packages etc.
* programs.nix - programs to install globally
* services.nix - services to run globally
* users.nix - users of the system (another alternative is to use homemanager)
* variables.nix - control general variables that needs to be set for the router configuration
* netns (folder). Setup netns configuration

If more files are created they need to be added to default.nix

To get networking in initrd: add the module(s) result of this command to **boot.initrd.availableKernelModules** in **variables.nix**: 
    
    basename "$(readlink -f /sys/class/net/enp*/device/driver/module)"

## Handling the system

### Update package definitions
    cd /etc/nixos
    nix flake update 
### Build system
    nixos-rebuild switch --flake /etc/nixos/.#ezbox
### System clean (remove old boot entries):
    nix-collect-garbage -d
### Remote password prompt at boot
    systemctl default
