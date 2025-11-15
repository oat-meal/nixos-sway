{ pkgs, ... }:

{
  ###############################################
  ## Desktop entry for Dank Material Shell
  ###############################################
  xdg.desktopEntries.dms = {
    name = "Dank Material Shell";
    exec = "dms";
    icon = "applications-utilities";
    type = "Application";
    terminal = false;
    categories = [ "Utility" ];
  };
}

