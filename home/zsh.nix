{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # Set ZDOTDIR to follow XDG Base Directory Specification
    # This moves .zshrc and related files to ~/.config/zsh
    dotDir = ".config/zsh";

    # History configuration for strong history suggestions
    history = {
      size = 50000;
      save = 50000;
      # Move history to XDG data directory
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    # Enable autocd and other useful options
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "kubectl"
        "history"
        "colored-man-pages"
        "command-not-found"
        "extract"
        "z"
      ];
    };

    # Shell aliases - add your custom aliases here
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # List files
      ll = "ls -lah --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";

      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Safety nets
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Misc
      grep = "grep --color=auto";
      df = "df -h";
      du = "du -h";
      free = "free -h";

      # Kubernetes
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";
      kgd = "kubectl get deployments";
    };

    # Additional init commands
    initContent = ''
      # Set XDG environment variables (follows XDG Base Directory Specification)
      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
      export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"

      # Ensure oh-my-zsh cache directory is writable
      if [ -d "$XDG_CACHE_HOME/oh-my-zsh" ]; then
        chmod -R u+w "$XDG_CACHE_HOME/oh-my-zsh" 2>/dev/null || true
      fi

      # Better history search with up/down arrows
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward

      # Ctrl+R for reverse history search
      bindkey "^R" history-incremental-search-backward

      # Ctrl+Backspace to delete whole word
      bindkey '^H' backward-kill-word

      # Edit command in editor with Ctrl+E
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^E" edit-command-line

      # Better completion styling
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

      # Colored man pages
      export LESS_TERMCAP_mb=$'\e[1;32m'
      export LESS_TERMCAP_md=$'\e[1;32m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[1;4;31m'
    '';
  };

  # dircolors for better ls colors
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  # fzf for fuzzy finding (integrates with Ctrl+R history)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
