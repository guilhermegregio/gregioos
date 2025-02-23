{ pkgs, profile, ... }: {
  programs = {
    nushell = {
      enable = true;
      package = pkgs.nushell;

      extraConfig = ''
        $env.config = {
          show_banner: false
        }

        def ncg [] {
            nix-collect-garbage --delete-old
            sudo nix-collect-garbage -d
            sudo /run/current-system/bin/switch-to-configuration boot
        }
      '';

      shellAliases = {
        g = "git";
        v = "hx";
        top = "btop";
        htop = "btop";
        cat = "bat";

        fr = "nh os switch --hostname ${profile}";
        fu = "nh os switch --hostname ${profile} --update";

        l = "ls";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
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
