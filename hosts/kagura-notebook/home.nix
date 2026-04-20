_: {
  imports = [
    ../../home
    ../../homeModules/niri
    ../../homeModules/waybar
    ../../homeModules/fuzzel
  ];

  kagura.home.pkgSets = {
    gui = true;
    dev = true;
    network = true;
  };
}
