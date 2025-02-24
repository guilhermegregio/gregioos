{ pkgs, ... }: {
  programs = {
    zellij = {
      enable = true;
      package = pkgs.zellij;

      settings = {
        theme = "catppuccin-mocha";
        simplified_ui = true;
        default_layout = "compact";

        plugins = {
          tab-bar.path = "tab-bar";
          status-bar.path = "status-bar";
          strider.path = "strider";
          compact-bar.path = "compact-bar";
        };

        "keybinds clear-defaults=true" = {
          normal = { "bind \"Ctrl Space\"" = { SwitchToMode = "tmux"; }; };
          tmux = {
            "bind \"Ctrl Space\"" = { SwitchToMode = "Normal"; };
            "bind \"Esc\"" = { SwitchToMode = "Normal"; };

            "bind \"d\"" = {
              CloseFocus = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Ctrl d\"" = { Detach = [ ]; };
            "bind \"z\"" = {
              ToggleFocusFullscreen = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"s\"" = {
              ToggleActiveSyncTab = [ ];
              SwitchToMode = "Normal";
            };

            "bind \"h\"" = {
              MoveFocus = "Left";
              SwitchToMode = "Normal";
            };
            "bind \"l\"" = {
              MoveFocus = "Right";
              SwitchToMode = "Normal";
            };
            "bind \"j\"" = {
              MoveFocus = "Down";
              SwitchToMode = "Normal";
            };
            "bind \"k\"" = {
              MoveFocus = "Up";
              SwitchToMode = "Normal";
            };

            "bind \"-\"" = {
              NewPane = "Down";
              SwitchToMode = "Normal";
            };
            "bind \"_\"" = {
              NewPane = "Right";
              SwitchToMode = "Normal";
            };

            "bind \"c\"" = {
              NewTab = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Ctrl l\"" = {
              GoToNextTab = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Ctrl h\"" = {
              GoToPreviousTab = [ ];
              SwitchToMode = "Normal";
            };

            "bind \"Ctrl r\"" = { SwitchToMode = "Resize"; };
            "bind \",\"" = {
              SwitchToMode = "RenameTab";
              TabNameInput = 0;
            };
            "bind \"<\"" = {
              SwitchToMode = "RenamePane";
              PaneNameInput = 0;
            };
          };
          renametab = {
            "bind \"Ctrl Space\"" = {
              UndoRenameTab = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Esc\"" = {
              UndoRenameTab = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Enter\"" = { SwitchToMode = "Normal"; };
          };
          renamepane = {
            "bind \"Ctrl Space\"" = {
              UndoRenamePane = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Esc\"" = {
              UndoRenamePane = [ ];
              SwitchToMode = "Normal";
            };
            "bind \"Enter\"" = { SwitchToMode = "Normal"; };
          };
          resize = {
            "bind \"Ctrl Space\"" = { SwitchToMode = "Normal"; };
            "bind \"Esc\"" = { SwitchToMode = "Normal"; };
            "bind \"h\"" = { Resize = "Increase Left"; };
            "bind \"j\"" = { Resize = "Increase Down"; };
            "bind \"k\"" = { Resize = "Increase Up"; };
            "bind \"l\"" = { Resize = "Increase Right"; };
            "bind \"H\"" = { Resize = "Decrease Left"; };
            "bind \"J\"" = { Resize = "Decrease Down"; };
            "bind \"K\"" = { Resize = "Decrease Up"; };
            "bind \"L\"" = { Resize = "Decrease Right"; };
            "bind \"=\"" = { Resize = "Increase"; };
            "bind \"-\"" = { Resize = "Decrease"; };
          };
        };
      };
    };
  };
}
