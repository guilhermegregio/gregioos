{ pkgs, lib, host, ... }:
let nh = if pkgs.stdenv.isDarwin then "nh darwin" else "nh os";
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      #  exec Hyprland
      #fi
    '';
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';
    shellAliases = {
      g = "git";
      sv = "sudo nvim";
      fr = "${nh} switch --hostname ${host}";
      fu = "${nh} switch --hostname ${host} --update";
      zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
      v = "nvim";
      cat = "bat";
      ls = "eza --icons";
      ll = "eza -lh --icons --grid --group-directories-first";
      la = "eza -lah --icons --grid --group-directories-first";
      ".." = "cd ..";
      ls-env = "fd -H -I -t f -E node_modules -E .git -E .next -E .direnv -E .nx -E .turbo -E .cache -E dist -E build '^\\.env'";
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      # switch-to-configuration é do NixOS.
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    };
  };
}
