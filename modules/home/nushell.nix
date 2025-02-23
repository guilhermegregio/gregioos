{ pkgs, profile, ... }: {
  programs = {
    nushell = {
      enable = true;
      package = pkgs.nushell;

      shellAliases = {
        g = "git";
        fr = "nh os switch --hostname ${profile}";
        fu = "nh os switch --hostname ${profile} --update";
        ncg =
          "nix-collect-garbage --delete-old and sudo nix-collect-garbage -d and sudo /run/current-system/bin/switch-to-configuration boot";
        v = "hx";
        cat = "bat";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
        top = "btop";
        htop = "btop";
      };
    };

    carapace = {
      enable = true;
      package = pkgs.carapace;

      enableNushellIntegration = true;
      enableZshIntegration = false;
      enableBashIntegration = false;
      enableFishIntegration = false;
    };
  };
}
