# This module configures hardware-specific to the uConsole.
{pkgs, ...}: {
  imports = [
    # XXX: Impurities
    #
    # I think this serves a purpose: so that the sd-card configuration
    # isn't broken, since it won't have these files along-side.
    #
    # But I should probably change these to point to the corresponding
    # files within this very repo, once I understand the consequences
    # for sdcard image builds.
    "${builtins.fetchGit {url = "https://github.com/NixOS/nixos-hardware.git";}}/raspberry-pi/4"
    "${builtins.fetchGit {url = "https://github.com/robertjakub/oom-hardware.git";}}/uconsole/kernel"
    "${builtins.fetchGit {url = "https://github.com/robertjakub/oom-hardware.git";}}/raspberry-pi/overlays"
    "${builtins.fetchGit {url = "https://github.com/robertjakub/oom-hardware.git";}}/raspberry-pi/apply-overlays"
  ];

  # XXX: Can I move this to `configuration.nix`?, or does this need to live here?
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];

  # This block configures the pre-graphical console environment.
  #
  # You can get thrown back to this environment for any number of
  # reasons, so it makes sense to have a functional configuration.
  console = {
    earlySetup = true;
    font = "ter-v32n";
    packages = with pkgs; [terminus_font];

    # Feel free to change the keyboard layout, but keep in mind that
    # the uConsole is a qwerty-first device.
    # keyMap = "us";

    # XXX: point this at the actual xkb file that we have here. Then,
    # sticky modifiers work even without a specific X11 or wayland
    # environment.
    useXkbConfig = true;
  };

  # This block configures kernel boot parameters.
  boot = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by
    # default)
    #
    # XXX: above appears untrue as of 24.11, UEFI is preferred
    # now (though on RPI hardware, this is moot).
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # uConsole-specific.
    #
    # Don't mess with this unless you know what you're doing.
    kernelParams = [
      "8250.nr_uarts=1"
      "vc_mem.mem_base=0x3ec00000"
      "vc_mem.mem_size=0x20000000"
      "console=ttyS0,115200"
      "console=tty1"
      "plymouth.ignore-serial-consoles"
      "snd_bcm2835.enable_hdmi=1"
      "snd_bcm2835.enable_headphones=1"
      "psi=1"
      "iommu=force"
      "iomem=relaxed"
      "swiotlb=131072"
    ];
  };

  # uConsole-specific.
  #
  # Don't mess with this unless you know what you're doing.
  hardware = {
    raspberry-pi."4" = {
      xhci.enable = false;
      dwc2.enable = true;
      dwc2.dr_mode = "host";
      overlays = {
        cpu-revision.enable = true;
        audremap.enable = true;
        vc4-kms-v3d.enable = true;
        cpi-disable-pcie.enable = true;
        cpi-disable-genet.enable = true;
        cpi-uconsole.enable = true;
        cpi-i2c1.enable = false;
        cpi-spi4.enable = false;
        cpi-bluetooth.enable = true;
      };
    };
    
    # uConsole-specific.
    #
    # Don't mess with this unless you know what you're doing.
    deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-cm4.dtb";
      overlaysParams = [
        {
          name = "bcm2711-rpi-cm4";
          params = {
            ant2 = "on";
            audio = "on";
            spi = "off";
            i2c_arm = "on";
          };
        }
        {
          name = "cpu-revision";
          params = {cm4-8 = "on";};
        }
        {
          name = "audremap";
          params = {pins_12_13 = "on";};
        }
        {
          name = "vc4-kms-v3d";
          params = {
            cma-384 = "on";
            nohdmi1 = "on";
          };
        }
      ];
    };
  };
}
