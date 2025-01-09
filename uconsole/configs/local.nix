{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
in {
  nix.distributedBuilds = false;
  nix.settings = {
    substituters = ["https://cache-nix.project2.xyz/uconsole"];
    trusted-substituters = ["https://cache-nix.project2.xyz/uconsole"];
    trusted-public-keys = ["uconsole:t2pv3NWEtXCYY0fgv9BB8r9tRdK+Tz7HYhGq9bXIIck="];
    experimental-features = ["nix-command" "flakes"];
  };
  services.openssh.enable = true;
  boot.supportedFilesystems.zfs = false;

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
  ];
}
