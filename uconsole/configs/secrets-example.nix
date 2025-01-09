# This file is for user-specific and possibly-sensitive information.
#
# Copy this file to `./secrets.nix`, and edit to suit.
#
# Do NOT check `./secrets.nix` into version control.
{
  config,
  lib,
  pkgs,
  ...
} : {
  # Configure your time-zone here.
  time.timeZone = "America/Los_Angeles";

  # Configure WiFi etc in whatever manner you see fit.
  networking = {
    # Give your pet uConsole a loving name that speaks to its character.
    hostName = "cheeky";
   
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Add a block for each wifi network that you want to auto-connect
    # to.
    #
    # The key is the SSID, and the psk is the un-hashed password.
    #
    # If you are mobile, you may need to restart the `wpa_supplicant.service`.
    #
    # XXX: configure network manager or conman, so we can avoid this nonsense.
    wireless.networks = {
      "foo with a space" = {
        psk = "supersecretpassword";
      };
      bar_nospaces = {
        psk = "omgtheywillneverguess";
      };
    };
  };

  # Set your locale here
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure your primary user account here.
  #
  # If you are sharing the machine, you can add additional user blocks
  # here.
  users.users = {
    your_user_name = {
      isNormalUser = true;
    
      initialPassword = "zohmygorsh";
    
      extraGroups = [
        "wheel"
        "audio"
        "video"
        "plugdev"
        "input"
        "evdev"
      ];
    };
  };
}