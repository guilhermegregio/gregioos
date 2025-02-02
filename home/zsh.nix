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
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    autocd = true;
    dotDir = ".config/zsh";

    profileExtra = ''
    '';

    initExtra = ''
      fastfetch
    '';

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 20000;
      size = 20000;
      share = true;
    };

    shellAliases = {
      cat = "bat";
      top = "btop";
      htop = "btop";

      g = "git";

      fr = "nh os switch --hostname ${host} /home/${username}/gregioos";
      fu = "nh os switch --hostname ${host} --update /home/${username}/gregioos";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

      ls = "eza --icons";
      ll = "eza -lh --icons --grid --group-directories-first";
      la = "eza -lah --icons --grid --group-directories-first";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        name = "forgit";
        src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
      }
      # {
      #   name = "fzf-tab";
      #   src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      # }
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
      }
    ];

    prezto = {
      enable = true;
      caseSensitive = false;
      utility.safeOps = true;
      editor = {
        dotExpansion = true;
        keymap = "vi";
      };
      pmodules = [ "autosuggestions" "directory" "editor" "git" "terminal" ];
    };
  };
}
