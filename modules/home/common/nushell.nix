{ pkgs, lib, host, ... }:
let nh = if pkgs.stdenv.hostPlatform.isDarwin then "nh darwin" else "nh os";
in {
  programs = {
    nushell = {
      enable = true;
      package = pkgs.nushell;

      extraConfig = ''
        $env.config = {
          show_banner: false
        }
      '' + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''

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

        fr = "${nh} switch --hostname ${host}";
        fu = "${nh} switch --hostname ${host} --update";

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
