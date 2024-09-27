{ pkgs, self, system, ... }: {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    cmake
    vim
  ];

  homebrew = {
    enable = true;

    taps = [
      "d12frosted/emacs-plus"
    ];

    casks = [
      "1password"
      "adobe-acrobat-pro"
      "alfred"
      "arc"
      "balenaetcher"
      "clickup"
      "cursor"
      "discord"
      "docker"
      "dropbox"
      "focusrite-control"
      "google-chrome"
      "google-earth-pro"
      "iina"
      "iterm2"
      "jetbrains-toolbox"
      "karabiner-elements"
      "kitty"
      "logitech-g-hub"
      "microsoft-office"
      "morgen"
      "notion"
      "obs"
      "obs-backgroundremoval"
      "obsidian"
      "orion"
      "parallels"
      "spotify"
      "steam"
      "steelseries-gg"
      "teamviewer"
      "telegram"
      "textual"
      "todoist"
      "transcribe"
      "visual-studio-code"
      "whatsapp"
      "wifiman"
    ];

    brews = [
      "emacs-plus"
      "findutils"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Amazon Kindle" = 302584613;
      "Goodnotes 6" = 1444383602;
      "LocalSend" = 1661733229;
      "Logic Pro" = 634148309;
      "PDF Squeezer 4" = 1502111349;
      "TextSniper" = 1528890965;
      "TickTick:To-Do List, Calendar" = 966085870;
      "Vimari" = 1480933944;
    };

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  fonts.packages = with pkgs; [
   (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    appswitcher-all-displays = true;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    ShowStatusBar = true;
    ShowPathbar = true;
    FXPreferredViewStyle = "Nlsv";
    FXDefaultSearchScope = "SCcf";
  };

  system.defaults.trackpad = {
    TrackpadThreeFingerDrag = true;
    Dragging = false;
    Clicking = true;
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.keyboard.fnState" = true;
    ApplePressAndHoldEnabled = false;
    AppleShowScrollBars = "Always";
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSWindowShouldDragOnGesture = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  networking.hostName = "14m3";

  security.pam.enableSudoTouchIdAuth = true;
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = system;
}
