{ lib, ... }: {
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "us+intl" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:caps_switch" ];
    };
  };
}
