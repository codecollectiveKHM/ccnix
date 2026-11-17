# T3 Code desktop (Electron AppImage) with Wayland flags + .desktop entry
{
  appimageTools,
  fetchurl,
  writeShellScriptBin,
  makeDesktopItem,
  symlinkJoin,
}:
let
  version = "0.0.20";
  base = appimageTools.wrapType2 {
    pname = "t3-code";
    inherit version;
    src = fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
      sha256 = "1vl0drr8c233j84cjvd4r342sm0y73wvl2cmmqmwxrh0qlbjfml2";
    };
  };
  launcher = writeShellScriptBin "t3-code" ''
    exec ${base}/bin/t3-code --enable-features=UseOzonePlatform --ozone-platform=wayland --no-sandbox --force-device-scale-factor=1.25 "$@"
  '';
  desktop = makeDesktopItem {
    name = "t3-code";
    desktopName = "T3 Code";
    genericName = "AI Coding Agent";
    exec = "t3-code";
    icon = "utilities-terminal";
    terminal = false;
    categories = [
      "Development"
      "Utility"
    ];
  };
in
symlinkJoin {
  name = "t3-code-${version}";
  paths = [
    launcher
    desktop
  ];
  passthru.parts = [
    launcher
    desktop
  ];
}
