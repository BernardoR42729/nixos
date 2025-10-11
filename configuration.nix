# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  hostname,
  username,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules
    ./users.nix
  ];

  # enabling Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  networking.hostName = hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_LANGUAGE = "en_US.UTF-8";
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # --- NVIDIA DRIVER CONFIGURATION ---
  hardware.nvidia = {
    # Modesetting is essential for Wayland.
    modesetting.enable = true;

    # Use the proprietary drivers. 'false' means proprietary.
    open = false;

    # Optionally, specify the NVIDIA package. 'stable' is usually fine for a 1080 Ti.
    # Other options: beta, legacy_470 etc. (but 1080 Ti is well supported by stable)
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  hardware.bluetooth.enable = true;

  # Optional: Explicitly set kernel parameters for NVIDIA.
  # `hardware.nvidia.modesetting.enable = true;` should handle this,
  # but being explicit can sometimes help or be necessary for certain setups.
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    # "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Can help with resume from suspend
    # "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  # Ensure OpenGL is enabled and uses NVIDIA.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # NixOS will automatically configure it to use NVIDIA drivers when 'services.xserver.videoDrivers = [ "nvidia" ];' is set.
  };

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Nvidia
    LIBVA_DRIVER_NAME = "nvidia"; # For hardware video acceleration (VA-API)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "0";
    WLR_NO_HARDWARE_CURSORS = "1"; # Can fix cursor rendering issues on NVIDIA with some compositors
    NVD_BACKEND = "direct"; # For NVIDIA's direct rendering manager backend
    # XDG_SESSION_TYPE = "wayland"; # GDM should set this, but can be explicit
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    # pulseaudio compatibility
    pulse.enable = true;
    # alsa compatibility
    alsa = {
      enable = true;
      support32Bit = true;
    };
    wireplumber.enable = true;
  };
  # Enable RealtimeKit for better low-latency performance.
  security.rtkit.enable = true;

  # Allow users in the 'wheel' group to use sudo.
  security.sudo.wheelNeedsPassword = true; # Or false if you prefer passwordless sudo for wheel group.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    # nix
    nil
    nixd
    nixpkgs-fmt

    rofi
    # editors
    evil-helix
    zed-editor
    neovim

    wl-clipboard
    overskride # bluetooth
    xfce.thunar
    lsof
    bluez-tools
    spotify

    # productivity
    obsidian
    logseq

    onedrive
    fastfetch
    vesktop
    fzf
    # zoxide
    zellij
    python314

    # browsers
    brave
    vivaldi
    chromium
    floorp-bin
    tor-browser
    # ---
    zathura # pdf
    mesa
    vaapiVdpau
    # libvdpau-va-gl
    nvidia-vaapi-driver

    # terminals
    ghostty
    kitty
    foot
    wezterm

    yazi
    btop
    speedcrunch

    # sound
    qpwgraph
    pavucontrol

    # hyprland
    swaynotificationcenter # notifications
    # mako
    swww
    hyprpaper
    hyprsunset
    hyprcursor
    hyprpolkitagent
    hyprsunset
    networkmanagerapplet
    grim
    slurp
    brightnessctl
    gnome-keyring
    rose-pine-hyprcursor
    bibata-cursors

    # # niri
    # alacritty
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-gtk
    # gnome-keyring
    # mako
    # nautilus
    # polkit_gnome
    # fuzzel
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
    noto-fonts
    nerd-fonts._0xproto
    nerd-fonts.space-mono
  ];

  # niri
  # programs.niri.enable = true;
  #
  # programs.waybar.enable = true;
  # systemd.packages = [
  #   pkgs.xwayland-satellite
  #
  #   pkgs.mako
  # ];
  # systemd.user.services.mako.wantedBy = ["graphical-session.target"];
  # # make sure xwayland-satellite starts up
  # systemd.user.services.xwayland-satellite.wantedBy = ["graphical-session.target"];

  programs.firefox.enable = true;

  # programs.fish = {
  #   enable = true;
  #   interactiveShellInit = ''
  #     fastfetch
  #   '';
  # };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      fastfetch
    '';
  };

  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    historyLimit = 5000;
  };

  programs.starship.enable = true;

  programs.chromium.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  programs.waybar.enable = true;

  # Polkit authentication agent
  security.polkit.enable = true;

  # Cachix to not have to rebuild hyprland
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
  # Portals (screen share, file chooser)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
  # -------
  # List services that you want to enable:

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  # Auto-login configuration
  services.displayManager.autoLogin = {
    user = username;
    enable = true;
  };

  services.getty.autologinUser = username;

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  services.power-profiles-daemon.enable = true;

  services.flatpak = {
    enable = true;
    update.onActivation = true;
    packages = [
      "app.zen_browser.zen"
    ];
  };

  documentation.man.generateCaches = false;

  system.stateVersion = "24.11"; # Did you read the comment?
}
