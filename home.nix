{ config, lib, pkgs, ... }@inputs:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sebastorama";
  home.homeDirectory = "/Users/sebastorama";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.

  home.packages = with pkgs; [
    act
    aider-chat
    bc
    btop
    cargo
    devcontainer
    fd
    freerdp3
    fzf
    gcc
    gh
    gum
    imagemagick
    jq
    lsd
    mtr
    neovim
    nil
    nodejs_22
    pgformatter
    pipx
    postgresql_16
    python3
    ripgrep

    (ruby_3_3.withPackages (rp: with rp; [
      bundler
      pry
    ]))

    sesh
    stdenv
    stylua
    tldr
    tmux
    wget
    yt-dlp
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".config/kitty/kitty.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix-darwin/dotfiles/kitty.conf";

    ".config/ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix-darwin/dotfiles/ghostty_conf";

    ".config/nvim/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix-darwin/dotfiles/nvim";

    ".aider.model.settings.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix-darwin/dotfiles/aider.model.settings.yml";

    ".npmrc".source = dotfiles/npmrc;

    ".gitignore_global".text = ''
      # Aider files
      .aider*
      aider.log
      .vscode
    '';

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/scripts"
    "$HOME/.local/hm-bins/duo"
    "$HOME/.npm-packages/bin"
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sebastorama/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    LC_CTYPE = "en_US.UTF-8";
  };

  programs.git = {
   enable = true;
   userEmail = "sebastorama@gmail.com";
   userName = "Sebastião Giacheto Ferreira Júnior";

   extraConfig = {
     init.defaultBranch = "main";
     core.editor = "nvim";
     core.excludesfile = "~/.gitignore_global";
     merge.tool = "nvimdiff";
     mergetool."nvimdiff".cmd = "nvim -d \"$LOCAL\" \"$MERGED\" \"$BASE\" \"$REMOTE\" -c \"wincmd w\" -c \"wincmd J\"";
     diff.tool = "nvimdiff";
     difftool."nvimdiff".cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
   };

   aliases = {
     st = "status -s";
     ci = "commit";
     co = "checkout";
     dc = "diff --cached";
     df = "diff";
     lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset' --abbrev-commit";
   };

   diff-so-fancy = {
     enable = true;
   };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    disableConfirmationPrompt = true;
    mouse = true;
    newSession = false;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [ tokyo-night-tmux ];
    extraConfig = ''
      set-window-option -g window-status-current-style fg=red
      set-option -g status-position top

      set -g default-terminal 'tmux-256color'

      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

      # Use v to trigger selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      # Use y to yank current selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind-key C-u run-shell -b "tmux capture-pane -J -p | grep -oE '(https?):\/\/[^ ]*' | fzf-tmux -d20 --multi --bind alt-a:select-all,alt-d:deselect-all | xargs open"

      bind-key -n C-M-l select-pane -R
      bind-key -n C-M-h select-pane -L
      bind-key -n C-M-5 split-window -h

      bind-key "t" display-popup -E -w 40% "sesh connect \"$(
       sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
      )\""

      bind-key -n C-M-PageUp swap-window -t -1\; select-window -t -1
      bind-key -n C-M-PageDown swap-window -t +1\; select-window -t +1

      bind-key C-Space select-pane -t .+\; resize-pane -Z

      bind-key 9 resize-pane -L 10
      bind-key 0 resize-pane -R 10
      bind-key F3 resize-pane -L 50
      bind-key F4 resize-pane -R 50

      bind-key -n C-PageUp previous-window
      bind-key -n C-PageDown next-window

      bind-key -n S-F1 swap-window -t -1\; select-window -t -1
      bind-key -n S-F2 swap-window -t +1\; select-window -t +1

      bind-key -n M--  previous-window
      bind-key -n M-= next-window
      bind-key -n F3 choose-window
      bind-key ! break-pane -d -n _hidden_pane
      bind-key @ join-pane -s $.1

      set -gu default-command
      set -g default-shell "$SHELL"

      set -sg escape-time 0
      set -g @tokyo-night-tmux_theme storm
      set -g @tokyo-night-tmux_window_tidy_icons 0
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "fino";
      plugins = [
        "git"
        "npm"
        "history"
        "node"
        "rust"
      ];
    };

    shellAliases = {
      ta = "tmux new-session -As";
      ls = "lsd";
    };

    autosuggestion = {
      enable = true;
      highlight = "fg=#666666,bold";
    };

    history.ignoreAllDups = true;

    autocd = true;

    plugins = [{
      name = "zsh-fzf-history-search";
      src = pkgs.fetchFromGitHub {
        owner = "joshskidmore";
        repo = "zsh-fzf-history-search";
        rev = "d5a9730b5b4cb0b39959f7f1044f9c52743832ba";
        sha256 = "tQqIlkgIWPEdomofPlmWNEz/oNFA1qasILk4R5RWobY=";
      };
    }];

    initContent = ''
      source ~/.secrets
    '';
  };

  pam.sessionVariables = config.home.sessionVariables // {
    LANGUAGE = "en_US:en";
    LANG = "en_US.UTF-8";
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
}
