local wezterm = require("wezterm")

return {
    default_cursor_style = "BlinkingBlock",
    -- tab bar
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    tab_max_width = 999999,
    window_padding = {
        left = 30,
        right = 30,
        top = 30,
        bottom = 30,
    },
    window_decorations = "RESIZE",
    inactive_pane_hsb = {
        brightness = 0.7,
    },
    send_composed_key_when_left_alt_is_pressed = false,
    send_composed_key_when_right_alt_is_pressed = true,
    -- key bindings
    -- leader = mappings.leader,
    -- keys = mappings.keys,
    -- key_tables = mappings.key_tables,
}
