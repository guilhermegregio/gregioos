{ pkgs, ... }:
let
  catppuccin-omerxx = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin-omerxx";
    version = "unstable-2023-11-30";
    rtpFilePath = "catppuccin.tmux";
    src = pkgs.fetchFromGitHub {
      owner = "omerxx";
      repo = "catppuccin-tmux";
      rev = "e30336b79986e87b1f99e6bd9ec83cffd1da2017";
      hash = "sha256-Ig6+pB8us6YSMHwSRU3sLr9sK+L7kbx2kgxzgmpR920=";
    };
  };
in {
  home.packages = [ pkgs.sesh ];

  stylix.targets.tmux.enable = false;

  xdg.configFile."sesh/sesh.toml".text = ''
    blacklist = ["scratch"]

    [default_session]
    startup_command = "nvim -c 'lua Snacks.picker.files()'"

    [[session]]
    name = "gregioos"
    path = "~/gregioos"
    startup_command = "nvim flake.nix"
  '';

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    shortcut = "a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 1000000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    sensibleOnTop = false;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      tmux-thumbs
      tmux-fzf
      fzf-tmux-url
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color 'magenta'
          set -g @floax-text-color 'blue'
          set -g @floax-bind 'p'
          set -g @floax-change-path 'true'
        '';
      }
      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind 'o'
          set -g @sessionx-zoxide-mode 'on'
          set -g @sessionx-filter-current 'false'
          set -g @sessionx-preview-enabled 'true'
        '';
      }
      {
        plugin = catppuccin-omerxx;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
          set -g @catppuccin_status_modules_right "directory date_time"
          set -g @catppuccin_status_modules_left "session"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator " "
          set -g @catppuccin_status_right_separator_inverse "no"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_directory_text "#{b:pane_current_path}"
          set -g @catppuccin_date_time_text "%H:%M"
        '';
      }
    ];

    extraConfig = ''
      set -g status-position top
      set -g renumber-windows on
      set -g set-clipboard on
      set -g focus-events on
      set -g allow-passthrough on
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -as terminal-features ",xterm*:RGB"
      set -as terminal-features ",xterm*:sync"
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'
      bind-key -n S-Enter send-keys Escape "[13;2u"

      set -g pane-active-border-style 'fg=magenta'
      set -g pane-border-style 'fg=brightblack'

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind x kill-pane
      bind / switch-client -l
      bind Space run-shell "notify-jump"
      bind C-Space display-popup -E -w 80% -h 70% "notify-pick"

      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind -n C-h if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind -n C-j if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind -n C-k if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind -n C-l if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
      bind -T copy-mode-vi C-h select-pane -L
      bind -T copy-mode-vi C-j select-pane -D
      bind -T copy-mode-vi C-k select-pane -U
      bind -T copy-mode-vi C-l select-pane -R

      bind L pipe-pane -o "cat >> $HOME/.claude-logs/#S-#W-#P-$(date +%Y%m%d).log" \; \
        display "Logging #S:#W.#P"

      bind-key "T" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""
    '';
  };
}
