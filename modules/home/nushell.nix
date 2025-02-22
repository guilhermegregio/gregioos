{
  pkgs,
  profile,
  ...
}:
{
  programs = {
    nushell = {
      enable = true;

      extraConfig = ''
        # Completions
        # mainly pieced together from https://www.nushell.sh/cookbook/external_completers.html

        # carapce completions https://www.nushell.sh/cookbook/external_completers.html#carapace-completer
        # + fix https://www.nushell.sh/cookbook/external_completers.html#err-unknown-shorthand-flag-using-carapace
        # enable the package and integration bellow
        let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
        }
        # some completions are only available through a bridge
        # eg. tailscale
        # https://carapace-sh.github.io/carapace-bin/setup.html#nushell
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

        $env.config = {
          show_banner: false,
          completions: {
            case_sensitive: false # set to true to enable case-sensitive completions
            quick: true    # set this to false to prevent auto-selecting completions when only one remains
            partial: true    # set this to false to prevent partial filling of the prompt
            algorithm: "prefix"    # prefix or fuzzy
            external: {
              enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
              max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
              completer: null # check 'carapace_completer' above as an example
            }
            use_ls_colors: true # set this to true to enable file/path/directory completions using LS_COLORS
          }
        }
      '';

      shellAliases = {
        g = "git";
        sv = "sudo nvim";
        fr = "nh os switch --hostname ${profile}";
        fu = "nh os switch --hostname ${profile} --update";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

        v = "nvim";
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
      enableNushellIntegration = true;
    };
  };
}
