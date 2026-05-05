{ pkgs, ... }: {
  programs = {
    starship = {
      enable = true;
      package = pkgs.starship;

      settings = {
        add_newline = false;
        command_timeout = 1000;
        format = "$directory$character";
        right_format = "$all";

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
          vicmd_symbol = "[N] >>>";
        };

        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        directory = {
          read_only = " 󰌾";
        };
        docker_context = {
          symbol = " ";
          disabled = true;
        };
        fossil_branch = {
          symbol = " ";
        };
        git_branch = {
          symbol = " ";
          format = "[$symbol$branch(:$remote_branch)]($style)";
        };
        git_status = {
          ahead = " ";
          behind = " ";
          diverged = " ";
          conflicted = "=";
          deleted = "✗";
          modified = "!";
          renamed = "»";
          staged = "+";
          stashed = "$";
          untracked = "?";
        };
        golang = {
          symbol = " ";
          format = "[ ](bold cyan)";
        };
        hg_branch = {
          symbol = " ";
        };
        hostname = {
          ssh_symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };
        package = {
          symbol = "󰏗 ";
        };
        python = {
          symbol = " ";
        };
        rust = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };

        aws = {
          format = "[$symbol(profile: \"$profile\" )(\\(region: $region\\) )]($style)";
          disabled = false;
          style = "bold blue";
          symbol = " ";
        };
        kubernetes = {
          symbol = "☸ ";
          disabled = true;
          detect_files = [ "Dockerfile" ];
          format = "[$symbol$context( \\($namespace\\))]($style) ";
        };
      };
    };
  };
}
