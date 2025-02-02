{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix) gitUsername gitEmail;
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    profileExtra = ''
    '';

    initExtra = ''
      fastfetch
    '';

    shellAliases = {
      g = "git";
      fr = "nh os switch --hostname ${host} /home/${username}/gregioos";
      fu = "nh os switch --hostname ${host} --update /home/${username}/gregioos";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      cat = "bat";
      ls = "eza --icons";
      ll = "eza -lh --icons --grid --group-directories-first";
      la = "eza -lah --icons --grid --group-directories-first";
      ".." = "cd ..";
    };
  };
}
