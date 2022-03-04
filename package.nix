{ 
  pkgs ? import <nixpkgs> {},
  theme ? "SpicetifyDefault",
  colorScheme ? "",
  thirdParyThemes ? {},
  thirdParyExtensions ? {},
  thirdParyCustomApps ? {},
  enabledExtensions ? [],
  enabledCustomApps ? [],
  spotifyLaunchFlags ? "",
  injectCss ? false,
  replaceColors ? false,
  overwriteAssets ? false,
  disableSentry ? true,
  disableUiLogging ? true,
  removeRtlRule ? true,
  exposeApis ? true,
  disableUpgradeCheck ? true,
  experimentalFeatures ? false,
}:

let

  inherit (pkgs.lib.lists) foldr;
  inherit (pkgs.lib.attrsets) mapAttrsToList;

  # Helper functions
  pipeConcat = foldr (a: b: a + "|" + b) "";
  lineBreakConcat = foldr (a: b: a + "\n" + b) "";
  boolToString = x: if x then "1" else "0";
  makeLnCommands = type: (mapAttrsToList (name: path: "ln -sf ${path} ./${type}/${name}"));

  # Setup spicetify
  spicetifyPkg = pkgs.callPackage ./spicetify.nix {};
  spicetify = "SPICETIFY_CONFIG=. ${spicetifyPkg}/spicetify";

  themes = pkgs.fetchzip {
    url = https://github.com/TonyTheAce/spicetify-themes/archive/refs/tags/2.8.5.tar.gz;
    sha256 = "0ddq4y37q4dslyi54rqs988qbpxl28jhl13m95xq9mjg08yqrpzn";
  };

  # Dribblish is a theme which needs a couple extra settings
  isDribblish = theme == "Dribbblish";
  
  extraCommands = (if isDribblish then "cp ./Themes/Dribbblish/dribbblish.js ./Extensions \n" else "")
    + (lineBreakConcat (makeLnCommands "Themes" thirdParyThemes))
    + (lineBreakConcat (makeLnCommands "Extensions" thirdParyExtensions))
    + (lineBreakConcat (makeLnCommands "CustomApps" thirdParyCustomApps));

  customAppsFixupCommands = lineBreakConcat (makeLnCommands "Apps" thirdParyCustomApps);
  
  injectCssOrDribblish = boolToString (isDribblish || injectCss);
  replaceColorsOrDribblish = boolToString (isDribblish || replaceColors);
  overwriteAssetsOrDribblish = boolToString (isDribblish || overwriteAssets);

  extensionString = pipeConcat ((if isDribblish then [ "dribbblish.js" ] else []) ++ enabledExtensions);
  customAppsString = pipeConcat enabledCustomApps;

in

pkgs.spotify-unwrapped.overrideAttrs (oldAttrs: rec {
  postInstall=''
    touch $out/prefs
    mkdir Themes
    mkdir Extensions
    mkdir CustomApps

    find ${themes} -maxdepth 1 -type d -exec ln -s {} Themes \;
    ${extraCommands}

    cat >> "config-xpui.ini" << EOF
    [Setting]
    spotify_path            = $out/share/spotify
    prefs_path              = $out/prefs
    check_spicetify_upgrade = 0
    EOF

    ${spicetify} config \
      current_theme ${theme} \
      ${if 
          colorScheme != ""
        then 
          ''color_scheme "${colorScheme}" \'' 
        else 
          ''\'' }
      ${if 
          extensionString != ""
        then 
          ''extensions "${extensionString}" \'' 
        else 
          ''\'' }
      ${if
          customAppsString != ""
        then 
          ''custom_apps "${customAppsString}" \'' 
        else 
          ''\'' }
      ${if
          spotifyLaunchFlags != ""
        then 
          ''spotify_launch_flags "${spotifyLaunchFlags}" \'' 
        else 
          ''\'' }
      inject_css ${injectCssOrDribblish} \
      replace_colors ${replaceColorsOrDribblish} \
      overwrite_assets ${overwriteAssetsOrDribblish} \
      disable_sentry ${boolToString disableSentry } \
      disable_ui_logging ${boolToString disableUiLogging } \
      remove_rtl_rule ${boolToString removeRtlRule } \
      expose_apis ${boolToString exposeApis } \
      disable_upgrade_check ${boolToString disableUpgradeCheck } \
      experimental_features ${boolToString experimentalFeatures } \

    ${spicetify} backup apply

    cd $out/share/spotify
    ${customAppsFixupCommands}
  '';
})
