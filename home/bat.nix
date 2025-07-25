{ config, pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-light";
      style = "numbers,changes,header";
    };
  };
}
