{ pkgs, lib, ... }:

let
  dms = pkgs.python3.pkgs.buildPythonApplication {
    pname = "DankMaterialShell";
    version = "latest";

    # Fetch from upstream GitHub repo
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "DankMaterialShell";
      rev = "main";  # you can pin to a specific commit later
      sha256 = lib.fakeSha256; # replace with real hash after first build
    };

    propagatedBuildInputs = with pkgs.python3.pkgs; [
      pygobject3
      pycairo
    ];

    format = "other";
    installPhase = ''
      mkdir -p $out/bin
      cp -r . $out/
      chmod +x $out/DankMaterialShell.py
      ln -s $out/DankMaterialShell.py $out/bin/dms
    '';
  };
in
{
  ################################
  ## Make DMS available
  ################################
  environment.systemPackages = [ dms ];

  ################################
  ## Optional Sway keybind
  ################################
  programs.sway.extraConfig = ''
    # Launch Dank Material Shell
    bindsym $mod+d exec "dms"
  '';

  ################################
  ## Desktop entry (for wofi, etc.)
  ################################
  xdg.desktopEntries.dms = {
    name = "Dank Material Shell";
    exec = "dms";
    icon = "applications-utilities";
    type = "Application";
    categories = [ "Utility" ];
  };
}
