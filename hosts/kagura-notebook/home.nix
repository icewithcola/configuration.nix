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
    devJvm = true;
    devAndroid = true;
    network = true;
  };
}
