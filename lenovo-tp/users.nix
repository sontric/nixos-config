{ config, pkgs, lib, ... }:

{

  # Define admin account
  users.users.sontric = {
    isNormalUser = true;
    description = "Sontric";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Define a runner account
  users.users.shr = {
    isNormalUser = true;
    description = "Github Self-Hosted Runner";
    extraGroups = [ "networkmanager" ];
  };

}
