{ pkgs, lib, ... }: {
  home.packages = with pkgs; [ nixd nil nixfmt-classic ];

  programs = {
    zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "make"
        "html"
        "dockerfile"
        "sql"
        "lua"
        "git-firefly"
        "catppuccin"
      ];
      ## everything inside of these brackets are Zed options.
      userSettings = {
        assistant = {
          enabled = true;
          version = "2";
          default_open_ai_model = null;
          default_model = {
            provider = "zed.dev";
            model = "claude-3-7-sonnet-latest";
          };
        };
        edit_predictions = {
          disabled_globs = [ ];
          mode = "eager_preview";
        };
        features = { edit_prediction_provider = "zed"; };
        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };
        terminal = {
          alternate_scroll = "off";
          blinking = "off";
          copy_on_select = false;
          dock = "bottom";
          detect_venv = {
            on = {
              directories = [ ".env" "env" ".venv" "venv" ];
              activate_script = "default";
            };
          };
          env = { TERM = "xterm-ghostty"; };
          font_family = "FiraCode Nerd Font";
          font_features = null;
          font_size = null;
          line_height = "comfortable";
          option_as_meta = false;
          button = false;
          shell = "system";
          toolbar = { title = true; };
          working_directory = "current_project_directory";
        };
        lsp = {
          nil = {
            initialization_options = {
              formatting = {
                command = [ "${pkgs.nixfmt-classic}/bin/nixfmt" ];
              };
            };
          };
          biome = {
            settings = {
              require_config_file = true;
              config_path = "<path>/biome.json";
            };
          };
        };
        languages = {
          nix = {
            language_servers =
              [ "${pkgs.nixd}/bin/nixd" "${pkgs.nil}/bin/nil" ];
            format_on_save = {
              external = { command = "${pkgs.nixfmt-classic}/bin/nixfmt"; };
            };
          };
          json = {
            language_server = {
              binary = {
                path =
                  "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
                path_lookup = true;
              };
            };
          };
          typescript = {
            language_servers = [
              "${pkgs.biome}/bin/biome"
              "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server"
            ];
            # formatter = "biome";
            # code_actions_on_format = {
            #   source.fixAll.biome = true;
            #   source.organizeImports.biome = true;
            # };
            # format_on_save = {
            #   external = {
            #     command = "${pkgs.biome}/bin/biome";
            #     arguments = [ "format --write" "{buffer_path}" ];
            #   };
            # };
          };
          tsx = {
            language_servers = [
              "${pkgs.biome}/bin/biome"
              "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server"
            ];
            # formatter = "biome";
            # code_actions_on_format = {
            #   source.fixAll.biome = true;
            #   source.organizeImports.biome = true;
            # };
            # format_on_save = {
            #   external = {
            #     command = "${pkgs.biome}/bin/biome";
            #     arguments = [ "format --write" "{buffer_path}" ];
            #   };
            # };
          };
        };
        # formatter = { language_server = { name = "biome"; }; };
        calls = {
          mute_on_join = true;
          share_on_join = false;
        };
        hour_format = "hour24";
        auto_update = false;
        vim_mode = true;
        load_direnv = "shell_hook";
        theme = "Catppuccin Mocha";
        ui_font_size = 16;
        base_keymap = "VSCode";
        relative_line_numbers = true;
        tab_size = 2;
      };
    };
  };
}
