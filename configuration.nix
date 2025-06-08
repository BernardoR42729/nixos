# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, hostname, username, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # enabling Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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

    # Power management can be useful, but sometimes causes issues.
    # Start with it enabled. If you face instability or resume issues, try disabling it.
    powerManagement.enable = true; # Or false if issues arise

    # Optionally, specify the NVIDIA package. 'stable' is usually fine for a 1080 Ti.
    # Other options: beta, legacy_470 etc. (but 1080 Ti is well supported by stable)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Optional: Explicitly set kernel parameters for NVIDIA.
  # `hardware.nvidia.modesetting.enable = true;` should handle this,
  # but being explicit can sometimes help or be necessary for certain setups.
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    # "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Can help with resume from suspend
    # "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  # Ensure OpenGL is enabled and uses NVIDIA.
  hardware.graphics = {
    enable = true;
    # NixOS will automatically configure it to use NVIDIA drivers when 'services.xserver.videoDrivers = [ "nvidia" ];' is set.
  };

# --- DISPLAY MANAGER (SDDM) ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Crucial: tells SDDM to list and prefer Wayland sessions
    # theme = "my-sddm-theme"; # Optional: if you install a custom SDDM theme package
    # Example: To use the 'catppuccin-mocha' theme for SDDM (install it first)
    # package = pkgs.sddm-catppuccin-theme; # You'd need to find or package this
    # theme = "catppuccin-mocha";
    # For a simpler, built-in theme that often works well:
    # theme = "elarun"; # Or "maldives", "maya"

    # Optional: Auto-login for the primary user
    # autologin.enable = true;
    # autologin.user = username; # Uses the username from specialArgs
  };

  environment.sessionVariables = {
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Nvidia
    LIBVA_DRIVER_NAME = "nvidia"; # For hardware video acceleration (VA-API)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1"; # Can fix cursor rendering issues on NVIDIA with some compositors
    NVD_BACKEND = "direct"; # For NVIDIA's direct rendering manager backend
    # XDG_SESSION_TYPE = "wayland"; # GDM should set this, but can be explicit
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

 # Define a user account. Don't forget to set a password with ‘passwd’.
 users.users.${username} = {
   isNormalUser = true;
   extraGroups = [ "wheel" "networkmanager" "video" "audio" ]; # Enable ‘sudo’ for the user.
   shell = pkgs.fish;
   packages = with pkgs; [
     tree
   ];
 };

 # Allow users in the 'wheel' group to use sudo.
  security.sudo.wheelNeedsPassword = true; # Or false if you prefer passwordless sudo for wheel group.

  programs.firefox.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    fastfetch
    '';
  };
  programs.chromium.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
 environment.systemPackages = with pkgs; [
   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
   neovim
   rofi-wayland
   nvidia-vaapi-driver

   # terminals
   ghostty
   kitty

   yazi
   btop
   speedcrunch

   # VCS
   git

   # sound
   qpwgraph
   pavucontrol

   # hyprland
   waybar
   swaynotificationcenter	# notifications
   hyprpaper			# 
   networkmanagerapplet
   hyprpolkitagent
   nerd-fonts.jetbrains-mono
   grim
   slurp
   brightnessctl
   hyprcursor

 ];
# Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };
  # Cachix to not have to rebuild hyprland
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  # Screesharing
  #xdg.portal = {
  #  enable = true;
  #  extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  #};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.y
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

