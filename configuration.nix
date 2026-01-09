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
    inputs.dank-material-shell.nixosModules.dank-material-shell
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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  hardware.wooting.enable = true;

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
    nushell
    starship
    onlyoffice-desktopeditors
    protonvpn-gui
    gimp-with-plugins
    krita
    udiskie # automount
    # ---
    # nix
    nil
    nixd
    nixpkgs-fmt
    # ---
    # app launchers
    walker
    rofi
    fuzzel
    #---
    # editors
    evil-helix
    zed-editor
    inputs.nvim.packages.${stdenv.hostPlatform.system}.default
    code-cursor
    emacs
    emacs.pkgs.doom
    codex
    claude-code
    jetbrains.idea
    antigravity
    # ---
    # dev
    jdk25
    jdk17
    jdt-language-server # Java LSP
    lua-language-server
    gh
    lazydocker
    lazygit
    azure-cli
    # ---
    gnumake
    gcc
    # ---
    wl-clipboard
    overskride # bluetooth
    thunar
    lsof
    bluez-tools
    spotify
    # ---
    # productivity
    obsidian
    logseq
    onedrive
    zathura # pdf
    zathuraPkgs.zathura_core
    zathuraPkgs.zathura_pdf_mupdf
    poppler
    zbar
    speedcrunch
    # ---
    # utilities
    nsxiv
    satty # screenshot annotations
    # ---
    # browsers
    brave
    vivaldi
    chromium
    tor-browser
    inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default
    # ---
    mesa
    libva-vdpau-driver
    libvdpau-va-gl
    nvidia-vaapi-driver
    # ---
    # terminals
    ghostty
    kitty
    foot
    wezterm
    # ---
    # CLI tools
    bat
    eza
    zip
    unzip
    fd
    ripgrep
    yazi
    btop
    fastfetch
    zellij
    # ---
    # Misc
    # vesktop
    legcord
    teams-for-linux
    element-desktop
    # ---
    # sound
    qpwgraph
    pavucontrol
    # ---
    # hyprland
    # swaynotificationcenter # notifications
    # # mako
    # swww
    # hyprpaper
    # hyprsunset
    # hyprcursor
    # hyprpolkitagent
    # hyprsunset
    hyprlandPlugins.hyprscrolling
    # networkmanagerapplet
    # grim
    # slurp
    # brightnessctl
    # gnome-keyring
    # rose-pine-hyprcursor
    # bibata-cursors
    # ---
    # niri
    alacritty
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    swaylock
    xwayland-satellite

    #common between window managers
    gnome-keyring
    # mako
    nautilus
    polkit_gnome
    swww
    grim
    slurp
    bibata-cursors
    # ---
    quickshell
    inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
    # dms requires it
    kdePackages.qt6ct

    mindustry-wayland
    gradle

    winboat
    docker-compose
    freerdp
    usbutils
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
    noto-fonts
    nerd-fonts._0xproto
    nerd-fonts.space-mono
    nerd-fonts.hurmit
    nerd-fonts.departure-mono
    nerd-fonts.gohufont
    nerd-fonts._3270
    nerd-fonts.caskaydia-cove
    nerd-fonts.profont
    nerd-fonts.overpass
    nerd-fonts.intone-mono
  ];

  # niri
  systemd.packages = [
    pkgs.xwayland-satellite
    # pkgs.mako
  ];

  # systemd.user.services.mako.wantedBy = [ "graphical-session.target" ];
  # make sure xwayland-satellite starts up
  systemd.user.services.xwayland-satellite.wantedBy = [ "graphical-session.target" ];

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dankMaterialShell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
  };

  programs.niri.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  programs.firefox.enable = true;

  # programs.mnw = ./modules/neovim.nix;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      sainnhe.gruvbox-material
      jdinhlife.gruvbox
      github.github-vscode-theme
      emroussel.atomize-atom-one-dark-theme
      catppuccin.catppuccin-vsc
      pkief.material-icon-theme
      sumneko.lua
      ms-toolsai.jupyter
      redhat.java
      vscjava.vscode-java-pack
      vscjava.vscode-java-test
      vscjava.vscode-maven
      vscjava.vscode-java-debug
      vscjava.vscode-gradle
      eamodio.gitlens
      ms-azuretools.vscode-docker
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      streetsidesoftware.code-spell-checker
      tamasfe.even-better-toml
      vadimcn.vscode-lldb
      rust-lang.rust-analyzer
      fill-labs.dependi
      foxundermoon.shell-format
      usernamehw.errorlens
      njpwerner.autodocstring
      kilocode.kilo-code
      asvetliakov.vscode-neovim
      jnoortheen.nix-ide
      esbenp.prettier-vscode
      brettm12345.nixfmt-vscode
      # Python
      ms-python.python
      charliermarsh.ruff
    ];
  };

  # programs.fish = {
  #   enable = true;
  #   interactiveShellInit = ''
  #     fastfetch
  #   '';
  # };
  programs.zsh = {
    enable = true;
    histSize = 100000;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      fastfetch
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
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
    # package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  programs.steam.enable = true;

  # Polkit authentication agent
  security.polkit.enable = true;

  # Cachix to not have to rebuild hyprland
  nix.settings = {
    # substituters = [ "https://hyprland.cachix.org" ];
    # trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    connect-timeout = "5";
    min-free = "128000000";
    max-free = "1000000000";

    # Set if understood
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    fallback = true;
    warn-dirty = false;
    auto-optimise-store = true;

    # Set for developers
    keep-outputs = true;

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
  services.emacs.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = username;
      };
    };
  };
  # Auto-login configuration
  services.displayManager.autoLogin = {
    user = username;
    enable = true;
  };

  # services.getty.autologinUser = username;

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
      # "app.zen_browser.zen"
    ];
  };

  services.upower.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  virtualisation.libvirtd.enable = true;

  documentation.man.generateCaches = false;

  system.stateVersion = "24.11"; # Did you read the comment?
}
