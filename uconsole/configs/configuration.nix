# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include uConsole settings
      ./uConsole.nix
    ]
    ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  nixpkgs.overlays = [(final: prev: {
    rofi-calc = prev.rofi-calc.override {
      rofi-unwrapped = prev.rofi-wayland-unwrapped;
    };
  })];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "uConsole";
  # Pick only one of the below networking options.
  networking.wireless.enable = true;
  
  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brandon = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "audio"
      "video"
      "plugdev"
      "input"
      "evdev"
    ];

    packages = with pkgs; [
      helix
      emacs-nox
      tree
      fzf
      netsurf.browser
      imv
      octave
      maxima
      wxmaxima
      bsdgames
    ];
  };

  programs.sway = {
    enable = true;
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

  programs.tmux.enable = true;
  programs.firefox.enable = true;

  services = {
    openssh.enable = true;
    displayManager.ly.enable = true;
    logind = {
      powerKey = "ignore";
      powerKeyLongPress = "poweroff";
    };
  };

  fonts = {
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

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Firacode" ];
    };
  };
  system.stateVersion = "25.05"; # Did you read the comment?
}
