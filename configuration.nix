# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth.enable = true;

  # Define your hostname
  networking.hostName = "nixos";

  # Hosts file
  networking.extraHosts = let
    hostsPath = https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts;
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_CH.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable rotation and touch support
  services.xserver.wacom.enable = true;
  hardware.sensor.iio.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  xdg = {
  portal = {
    enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };
  hardware.pulseaudio.enable = false;
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  
  # Android phone
  programs.adb.enable = true;
  services.gvfs.enable = true;

  # Preload
  systemd.services.preload = {
      enable = true;
      wantedBy = [ "multi-user.target" ]; 
      description = "Start preload";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''/nix/store/2y5hccrrvrkd7pr86v8x345d1pb7ylf1-preload-0.6.4/bin/preload --foreground --verbose 9'';         
      };
   };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gustavo = 
    let
      unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) { };
    in
    {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "adbusers" ];
      shell = unstable.nushell; 
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar"
  ];

  environment.systemPackages = with pkgs; [
    # Development packages
    rustup
    nodejs
    nodePackages.npm
    nodePackages.typescript
    llvm
    mono
    jdk
    python39Full
    python39Packages.pip
    go
    cmake
    gnumake
    gcc
    binutils
    flatpak-builder
    git

    # Unrar
    unrar

    # PDF
    texlive.combined.scheme-full
    pandoc

    # System
    mesa
    glxinfo
    libva
    libva-utils
    jmtpfs
    usbutils
    hwinfo

    # Applications
    kitty
    neovim
    firefox
    ledger
    neofetch
    wineWowPackages.staging
  ];
  
  environment.gnome.excludePackages = [ 
    pkgs.gnome3.gnome-software
    pkgs.gnome3.yelp
    pkgs.gnome-connections
    pkgs.gnome-tour
    pkgs.gnome3.geary
    pkgs.gnome3.gnome-music
    pkgs.gnome3.gnome-photos
    pkgs.gnome3.epiphany
    pkgs.gnome3.gnome-terminal
  ];

  # Vim Configuration
  environment.variables = { EDITOR = "nvim"; };

  nixpkgs.overlays = [ (self: super: {
    neovim = super.neovim.override {
      viAlias = true;
      vimAlias = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vimtex goyo-vim vim-nix coc-nvim coc-rls coc-css coc-json coc-tsserver coc-html coc-vimtex coc-python coc-clangd ];
        };
	customRC = ''
	  set ignorecase
	  set mouse=v
	  set hlsearch
	  set number
	  set cc=80
	  filetype plugin indent on
	  set ttyfast
	  set spell
          highlight ColorColumn ctermbg=7
        '';
      };
    };
  }) ];

  #let
  #  nvim-spell-de-utf8-dictionary = builtins.fetchurl {
  #    url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.spl";
  #    sha256 = "73c7107ea339856cdbe921deb92a45939c4de6eb9c07261da1b9dd19f683a3d1";
  #  };
  #    nvim-spell-de-utf8-suggestions = builtins.fetchurl {
  #    url = "http://ftp.vim.org/vim/runtime/spell/de.utf-8.sug";
  #    sha256 = "13d0ecf92863d89ef60cd4a8a5eb2a5a13a0e8f9ba8d1c6abe47aba85714a948";
  #  };
  #  nvim-spell-en-utf8-dictionary = builtins.fetchurl {
  #    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl";
  #    sha256 = "fecabdc949b6a39d32c0899fa2545eab25e63f2ed0a33c4ad1511426384d3070";
  #  };
  #  nvim-spell-en-utf8-suggestions = builtins.fetchurl {
  #    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug";
  #    sha256 = "5b6e5e6165582d2fd7a1bfa41fbce8242c72476222c55d17c2aa2ba933c932ec";
  #  };
  #  nvim-spell-pt-utf8-dictionary = builtins.fetchurl {
  #    url = "http://ftp.vim.org/vim/runtime/spell/pt.utf-8.spl";
  #    sha256 = "3e5fc100b6951b783cfb3386ada43cb39839553e04faa415af5cf5bd5d6ab63b";
  #  };
  #in
  #  {
  #    home.file."${config.xdg.configHome}/nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
  #    home.file."${config.xdg.configHome}/nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
  #    home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
  #    home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
  #    home.file."${config.xdg.configHome}/nvim/spell/pt.utf-8.spl".source = nvim-spell-pt-utf8-dictionary;
  #  }
  

  # Enable Flatpak
  services.flatpak.enable = true;

  # Hardware acceleration
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ 
    vaapiIntel 
    libvdpau-va-gl
    vaapiVdpau
  ];

  # Enable virtualization
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    libvirtd = {
      enable = true;
    };
  };
  programs.dconf.enable = true;

  # Filesystems
  boot.supportedFilesystems = [ "ntfs" "btrfs" "ext4" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

