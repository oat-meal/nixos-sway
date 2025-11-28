{ config, pkgs, lib, ... }:

{
  ################################
  ## Sway Configuration (Niri-inspired)
  ################################
  
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false; # Disable validation during build
    
    config = {
      modifier = "Mod4"; # Super/Windows key
      terminal = "alacritty";
      menu = "wofi --show=drun --allow-images";
      
      # Disable default sway bar since we use Noctalia
      bars = [];

      # Niri-inspired window behavior
      window = {
        # Disable window titlebars for clean look
        titlebar = false;
        # Remove borders for seamless experience
        border = 0;
      };

      # Niri-like floating window settings
      floating = {
        # Use smart borders for floating windows
        border = 2;
        titlebar = false;
        modifier = "Mod4";
      };

      # Gaps for a modern look
      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = true;
        smartBorders = "on";
      };

      # Focus behavior similar to Niri
      focus = {
        followMouse = "no";
        mouseWarping = "container";
        newWindow = "smart";
      };

      # Workspaces - mimic Niri's dynamic workspace behavior
      workspaceLayout = "default";
      workspaceAutoBackAndForth = true;

      # Colors - Catppuccin Macchiato to match your theme
      colors = {
        focused = {
          border = "#c6a0f6";
          background = "#c6a0f6";
          text = "#24273a";
          indicator = "#c6a0f6";
          childBorder = "#c6a0f6";
        };
        focusedInactive = {
          border = "#494d64";
          background = "#494d64";
          text = "#cad3f5";
          indicator = "#494d64";
          childBorder = "#494d64";
        };
        unfocused = {
          border = "#363a4f";
          background = "#363a4f";
          text = "#cad3f5";
          indicator = "#363a4f";
          childBorder = "#363a4f";
        };
        urgent = {
          border = "#ed8796";
          background = "#ed8796";
          text = "#24273a";
          indicator = "#ed8796";
          childBorder = "#ed8796";
        };
        placeholder = {
          border = "#24273a";
          background = "#24273a";
          text = "#cad3f5";
          indicator = "#24273a";
          childBorder = "#24273a";
        };
        background = "#24273a";
      };

      # Input configuration
      input = {
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "50";
          xkb_options = "caps:escape";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          scroll_method = "two_finger";
          accel_profile = "adaptive";
          pointer_accel = "0.3";
        };
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
      };

      # Output configuration - let Noctalia handle wallpapers
      output = {};

      # Key bindings - Niri-inspired navigation
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        # Basic controls
        "${modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
        "${modifier}+d" = "exec ${config.wayland.windowManager.sway.config.menu}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'";
        
        # Niri-like horizontal scrolling navigation
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right"; 
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        
        # Vi-keys for power users
        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";
        
        # Moving windows - like Niri's column manipulation
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";
        
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+j" = "move down";

        # Workspace navigation - vertical like Niri
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        # Move containers to workspaces
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Niri-like layout controls (horizontal emphasis)
        "${modifier}+b" = "splith"; # Split horizontally (default for Niri-like behavior)
        "${modifier}+v" = "splitv"; # Split vertically when needed
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        
        # Fullscreen and floating
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";

        # Resizing (similar to Niri's smooth resizing)
        "${modifier}+r" = "mode resize";
        
        # Scratchpad (Niri-like quick access)
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";

        # Audio controls
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        
        # Media player controls (via Noctalia IPC)
        "XF86AudioPlay" = "exec qs -c noctalia-shell ipc call media playPause";
        "XF86AudioPause" = "exec qs -c noctalia-shell ipc call media pause";
        "XF86AudioNext" = "exec qs -c noctalia-shell ipc call media next";
        "XF86AudioPrev" = "exec qs -c noctalia-shell ipc call media previous";
        
        # Alternative media controls (for keyboards without media keys)
        "${modifier}+p" = "exec qs -c noctalia-shell ipc call media playPause";
        "${modifier}+bracketright" = "exec qs -c noctalia-shell ipc call media next";
        "${modifier}+bracketleft" = "exec qs -c noctalia-shell ipc call media previous";
        
        # Screenshots
        "Print" = "exec grim ~/Pictures/screenshot-$(date +'%Y-%m-%d-%H-%M-%S').png";
        "Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y-%m-%d-%H-%M-%S').png";
        
        # Screen lock (Noctalia)
        "${modifier}+Delete" = "exec sh -c 'qs ipc --id $(qs list --all | head -1 | grep -o \"Instance [^:]*\" | cut -d\" \" -f2 | head -c2) call lockScreen lock'";
      };

      # Startup applications
      startup = [
        { command = "mako"; }
        # Update D-Bus activation environment for wofi compatibility
        { command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP=sway GDK_BACKEND SDL_VIDEODRIVER"; }
        # Start Noctalia shell
        { command = "noctalia-shell"; }
        # Auto-tiling script for Niri-like behavior
        { command = "${pkgs.writeScript "sway-niri-mode" ''
          #!/bin/sh
          # Default to horizontal splits for Niri-like column behavior
          swaymsg "default_orientation horizontal"
        ''}"; }
        # Lock screen after startup for security
        { command = "${pkgs.writeScript "auto-lock" ''
          #!/bin/sh
          # Wait for noctalia to fully load then lock screen
          sleep 3
          instance_id=$(qs list --all | head -1 | grep -o "Instance [^:]*" | cut -d" " -f2 | head -c2)
          if [ -n "$instance_id" ]; then
            qs ipc --id "$instance_id" call lockScreen lock
          fi
        ''}"; }
      ];
      
      # Window rules for better Niri-like experience
      assigns = {};
      
      modes = {
        resize = {
          # Niri-style smooth resizing
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px"; 
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";
          
          "h" = "resize shrink width 10px";
          "j" = "resize grow height 10px";
          "k" = "resize shrink height 10px";
          "l" = "resize grow width 10px";
          
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };
    };
    
    # SwayFX-specific configuration for animations and effects
    extraConfig = ''
      # TEMPORARILY DISABLED FOR WOFI TESTING
      # SwayFX blur settings (Niri-inspired)
      # blur enable
      # blur_xray enable
      # blur_passes 2
      # blur_radius 5

      # Rounded corners like Niri
      # corner_radius 12

      # Shadows for depth
      # shadows enable
      # shadows_on_csd enable
      # shadow_blur_radius 20
      # shadow_color #000000AA

      # Dim inactive windows slightly
      # default_dim_inactive 0.1
      # dim_inactive_colors.unfocused #000000AA

      # Layer shell blur for Noctalia shell and overlays
      # layer_effects "noctalia" blur enable; shadows enable;
      # layer_effects "notifications" blur enable; shadows enable;
      # Don't apply effects to launcher layer shells
      # layer_effects "launcher" blur disable; shadows disable;

      # Smart gaps - hide gaps when only one window
      smart_gaps on
      smart_borders no_gaps

      # Default to horizontal orientation for Niri-like columns
      default_orientation horizontal

      # Focus follows mouse for smoother navigation
      focus_follows_mouse no
      mouse_warping container

      # Window rules for Niri-like behavior
      for_window [app_id="^floating$"] floating enable
      for_window [title="^Open File$"] floating enable, resize set 1000 600
      for_window [title="^Save As$"] floating enable, resize set 1000 600
      # Don't auto-focus launchers or dialogs
      for_window [class=".*" title="^(?!wofi|rofi|dmenu).*"] focus
      
      # Steam-specific window rules for stability (both X11 class and Wayland app_id)
      for_window [class="steam"] move container to workspace number 9
      for_window [class="steam"] focus
      for_window [app_id="steam"] move container to workspace number 9
      for_window [app_id="steam"] focus
      for_window [class="steam" title="^Steam$"] floating disable
      for_window [app_id="steam" title="^Steam$"] floating disable
      # Also match Steam main window by title only
      for_window [title="^Steam$"] move container to workspace number 9, focus
      for_window [class="steam" title="Friends List"] floating enable, resize set 350 700
      for_window [app_id="steam" title="Friends List"] floating enable, resize set 350 700
      for_window [class="steam" title="Steam Settings"] floating enable, resize set 800 600
      for_window [app_id="steam" title="Steam Settings"] floating enable, resize set 800 600
      for_window [class="steam" title="Screenshot Manager"] floating enable, resize set 800 600
      for_window [app_id="steam" title="Screenshot Manager"] floating enable, resize set 800 600
      for_window [class="steam" title="Steam - News"] floating enable, resize set 800 600
      for_window [app_id="steam" title="Steam - News"] floating enable, resize set 800 600
      for_window [class="steam" title="Steam Guard"] floating enable, resize set 350 190
      for_window [app_id="steam" title="Steam Guard"] floating enable, resize set 350 190
      for_window [class="steam" title="^Steam Keyboard$"] floating enable
      for_window [app_id="steam" title="^Steam Keyboard$"] floating enable
      
      # Game window optimizations
      for_window [class="steam_app_.*"] fullscreen enable
      for_window [class="steam_app_.*"] move container to workspace number 10
      for_window [class="steam_app_.*"] focus
      for_window [class="steam_app_.*"] inhibit_idle focus
      
      # Gaming launcher rules
      for_window [app_id="lutris"] move container to workspace number 9
      for_window [app_id="heroic"] move container to workspace number 9
      for_window [class="bottles"] move container to workspace number 9
      
      # Smart borders - exclude launchers and special windows
      for_window [class=".*" title="^(?!wofi|rofi|dmenu).*"] border pixel 2
      for_window [app_id="^(?!wofi|rofi|dmenu).*"] border none
      for_window [class="steam_app_.*"] border none
    '';
  };

  # Noctalia shell is installed system-wide and started via Sway startup
  # It provides its own bar and widgets, replacing waybar

  # Notification daemon
  services.mako = {
    enable = true;
    settings = {
      background-color = "#24273a";
      border-color = "#c6a0f6";
      border-radius = 12;
      border-size = 2;
      text-color = "#cad3f5";
      margin = "10";
      padding = "15";
      default-timeout = 5000;
    };
  };
}