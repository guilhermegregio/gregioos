{ ... }:
let
  inherit (import ../hosts/gregio-note/variables.nix) gitUsername gitEmail;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true;

    userName = "${gitUsername}";
    userEmail = "${gitEmail}";

    aliases = {
      c = "commit -am";
      s = "status -s";
      p = "push";
      co = "checkout";
    };
  };
}
