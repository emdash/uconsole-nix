# Entry Point for this configuration.
#
# Configure your user account and network settings here:
#
#   ./secrets.nix.
#
# A sample `secrets.nix` is provided along-side this file.
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Here we import hardware- and user-specific configuration.
  #
  # Don't mess with this unless you know what you're doing.
  imports = [
    ./hardware-configuration.nix
    ./uConsole.nix
    ./secrets.nix
  ];

  # This block configures the nix package manager, the beating heart
  # of NixOS.
  # 
  # I have manually merged configuration options from `local.nix`,
  # but I do not totally understand why each option is configured the
  # way it is.
  nix = {
    # XXX: why?
    distributedBuilds = false;

    # XXX: Not sure who owns this binary cache. We'll leave it for now.
    settings = {
      substituters = ["https://cache-nix.project2.xyz/uconsole"];
      trusted-substituters = ["https://cache-nix.project2.xyz/uconsole"];
      trusted-public-keys = ["uconsole:t2pv3NWEtXCYY0fgv9BB8r9tRdK+Tz7HYhGq9bXIIck="];
      experimental-features = ["nix-command" "flakes"];
    };
  };

  # This block configures nixpkgs, the soul of NixOS.
  nixpkgs = {
    # Pragmatic default: Set to false if you're a purist.
    config.allowUnfree = true;

    # This is a hack I found on the community forums
    #
    # It doesn't seem to help much.
    # XXX: switch to fuzzel?
    overlays = [(final: prev: {
      rofi-calc = prev.rofi-calc.override {
        rofi-unwrapped = prev.rofi-wayland-unwrapped;
      };
    })];
  };

  # XXX: This configures some specific boot options.
  boot = {
    # XXX: to save space?
    supportedFilesystems.zfs = false;
  };

  # Minimal Networking Config, for manual network management.
  # Place all other network-related values in ./secrets.nix;
  networking.wireless.enable = true;

  # XXX: I should probably enable this.
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # This block configures all software installed as bare packages,
  # rather than as `programs`, `services`, or `applications`.
  environment.systemPackages = with pkgs; [
    wirelesstools
    iw
    gitMinimal
    cpulimit
    sysstat
    wlr-randr
    procps
    libinput
    libevdev
    python312Packages.numpy
    python312Packages.python
    helix
    emacs-nox
    neovim
    tree
    fzf
    qutebrowser
    surf # X11-only, currently broken? Are we missing XWayland?
    imv
    octave
    maxima
    bsdgames
  ];

  # This block configures all packages made available via NixOS
  # `programs` modules, but not as `services` or `app`lications.
  #
  # I take it on faith that higher-level options are preferred, when
  # available, verus simply adding the bare package.
  programs = {

    # This is my preference for a minimalist, keyboard-driven, tiling
    # graphical environment under wayland..
    #
    # Probably some of you will prefer hyprland, wafire, labwc, etc,
    # but switching between them requires explicit support. Right now
    # certain aspects of the configuration assume `sway` itself.
    #
    # Change this at your own risk, if you know what you're doing.
    sway = {
      enable = true;

      # XXX: is it better to declare these here, or above?
      #
      # I take it on faith that this enables extra integration, vs
      # simply adding the packages above.
      extraPackages = with pkgs; [
        brightnessctl
        foot
        grim
        swaybg
        swaylock
        waybar
        wl-clipboard
        rofi-wayland-unwrapped
        rofi-emoji-wayland
        rofi-calc
        rofi-rbw-wayland
        rofi-menugen
        rofi-power-menu
        wev
      ];
    };

    # I prefer this to `screen`.
    tmux.enable = true;

    # It takes a while to launch, but once launched, it runs fairly well.
    firefox.enable = true;
  };

  # This block configures all software available as a NixOS service.
  services = {
    openssh.enable = true;

    displayManager.ly.enable = true;

    logind = {
      # `qsleep.sh` handles short press on the power key
      powerKey = "ignore";

      # Long press to power-off, if your session gets wedged.
      powerKeyLongPress = "poweroff";
    };
  };

  # This block configures system-wide fonts, and default font choices.
  fonts = {
    # Add any additional font package here.
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      liberation_ttf
      fira-code
      fira-code-symbols
      symbola
    ];

    # Set your default font preferences here.
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Firacode" ];
    };
  };

  # Do not change unless you know what you are doing.
  system.stateVersion = "25.05"; # Did you read the comment?
}
