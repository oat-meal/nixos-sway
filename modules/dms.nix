{ pkgs, lib, ... }:

let
  dms = pkgs.python3.pkgs.buildPythonApplication {
    pname = "DankMaterialShell";
    version = "main";

    # Fetch from GitHub
    src = pkgs.fetchFromGitHub {
      owner = "AvengeMedia";
      repo = "DankMaterialShell";
      rev = "main";                # optional: pin to specific commit later
      sha256 = lib.fakeSha256;     # replace with real hash after first build
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
  ###############################################
  ## Make DMS available globally as "dms"
  ###############################################
  environment.systemPackages = [ dms ];

  # NOTE:
  # This module intentionally contains *no* Sway config
  # and *no* .desktop entries. Those belong to user-level
  # Home Manager configuration.
}

