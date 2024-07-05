{ pkgs, self, system, ... }: {
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  homebrew = {
    enable = true;
    casks = [
      "1password"
      "alfred"
      "discord"
      "dropbox"
      "google-chrome"
      "jetbrains-toolbox"
      "karabiner-elements"
      "kitty"
      "microsoft-office"
      "parallels"
      "spotify"
      "telegram"
      "textual"
      "whatsapp"
    ];
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

  system.defaults.dock.autohide = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
    KeyRepeat = 2;
    InitialKeyRepeat = 15;
  };

  security.pam.enableSudoTouchIdAuth = true;
  
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = system;
}
