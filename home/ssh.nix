{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
    '';
    matchBlocks = {
      "*" = {
        extraOptions = {
          UseKeychain = "yes";
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}
