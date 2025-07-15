{ pkgs, self, system, hostname, ... }: {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    cmake
    goku
    vim
  ];

  homebrew = {
    enable = true;

    taps = [
      "qmk/qmk"
    ];

    casks = [
      "1password"
      "1password-cli"
      "adobe-acrobat-pro"
      "alfred"
      "android-platform-tools"
      "android-studio"
      "arc"
      "arduino-ide"
      "balenaetcher"
      "bambu-studio"
      "brave-browser"
      "claude"
      "cursor"
      "devpod"
      "discord"
      "docker"
      "dropbox"
      "firefox"
      "focusrite-control"
      "ghostty"
      "google-chrome"
      "google-chrome@canary"
      "google-earth-pro"
      "iina"
      "iterm2"
      "jetbrains-toolbox"
      "karabiner-elements"
      "kdenlive"
      "keymapp"
      "kicad"
      "kitty"
      "logi-options+"
      "logitech-g-hub"
      "mattermost"
      "microsoft-edge"
      "microsoft-office"
      "ngrok"
      "notion"
      "obs"
      "obs-backgroundremoval"
      "obsidian"
      "ollama"
      "orion"
      "parallels"
      "qgis"
      "qmk-toolbox"
      "raycast"
      "steam"
      "steelseries-gg"
      "spotify"
      "teamviewer"
      "telegram"
      "textual"
      "todoist"
      "transcribe"
      "visual-studio-code"
      "vial"
      "vnc-viewer"
      "vivaldi"
      "wasabi-wallet"
      "whatsapp"
      "wifiman"
      "zed@preview"
      "zen-browser"
    ];

    brews = [
      "qmk/qmk/qmk"
      "findutils"
      "graphviz"
      "haskell-stack"
      "sevenzip"
    ];

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  nix.enable = false; # managed by determinate
  # nix.package = pkgs.nix;

  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  system.primaryUser = "sebastorama";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  system.defaults.dock = {
    autohide = true;
    tilesize = 44;
    largesize = 96;
    magnification = true;
    showhidden = true;
    scroll-to-open = true;
    orientation = "bottom";
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
    enableKeyMapping = false;
  };

  networking.hostName = hostname;

  security.sudo.extraConfig = ''
    sebastorama ALL=(ALL) NOPASSWD: ALL
  '';
  security.pam.services.sudo_local.touchIdAuth = true;
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
