{ pkgs, ... }: {
  programs = {
    kitty = {
      enable = true;
      package = pkgs.kitty;

      keybindings = {
        "shift+enter" = "send_text all \\x1b[13;2u";
      };

      settings = {
        scrollback_lines = 2000;
        wheel_scroll_min_lines = 1;
        window_padding_width = 4;
        confirm_os_window_close = 0;
        hide_window_decorations = true;
        notify_on_cmd_finish = "unfocused 10.0";
        bell_on_tab = "🔔 ";
        window_alert_on_bell = "yes";
      };
      extraConfig = ''
        tab_bar_style fade
        tab_fade 1
        active_tab_font_style   bold
        inactive_tab_font_style bold
      '';
    };
  };
}
