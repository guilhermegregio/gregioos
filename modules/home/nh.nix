{
  pkgs,
  username,
  ...
}: {
  programs = {
    nh = {
      enable = true;
      package = pkgs.nh;

      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };

      flake = "/home/${username}/gregioos";
    };
  };
}
