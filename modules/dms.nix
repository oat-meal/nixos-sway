{ pkgs, lib, ... }:

let
  dms = pkgs.python3.pkgs.buildPythonApplication {
    pname = "DankMaterialShell";
    version = "latest";

    # Fetch from GitHub (DMS is not in nixpkgs)
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "DankMaterialShell";
      rev = "main";           # You can pin a commit later for reproducibility
      sha256 = lib.fakeSha256;  # Run nix build once to get the actual hash
    };

    propagatedBuildInputs = with pkgs.python3.pkgs; [
      pygobject3
      # Required GTK libs
      pycairo
    ];

    # DMS is a pure Python application—no native build phase
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
  options.desktop.dms.enable = lib.mkEnableOption "Enable DankMaterialShell launcher";

  config = lib.mkIf config.desktop.dms.enable {

    ########################################
    # Make `dms` available system-wide
    ########################################
    environment.systemPackages = [ dms ];

    ########################################
    # Add recommended Sway keybind
    ########################################
    programs.sway.extraConfig = ''
      ### Launch Dank Material Shell
      bindsym $mod+d exec "dms"
    '';
  };
}
