{
  config,
  pkgs,
  lib,
  ...
}:
let
  github_hook = ../assets/scripts/github.sh;
in
{
  home.packages = with pkgs; [
    zsh-fzf-tab
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = lib.mkMerge [
      {
        ls = "eza";
        ll = "eza --icons -l";
        la = "eza --icons -al";

        vi = "hx";
        vim = "hx";

        home-edit = "hx ~/.config/home-manager";
      }
      (lib.mkIf (config.kagura.home.pkgSets.network) {
        # Network package set used, use doggo
        dig = "doggo";
      })
      (lib.mkIf (config.kagura.home.pkgSets.dev) {
        nix-build = "nom-build";
      })
    ];

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        # Completion paths are managed by Nix and immutable; skip the redundant audit.
        ZSH_DISABLE_COMPFIX=true
      '';
      plugins = [
        "git"
      ];
      theme = "agnoster";
    };

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${github_hook}
      [[ ! -d ~/.cargo/bin ]] || export PATH=`realpath ~`/.cargo/bin:$PATH

      # Wrap nix build and nixos-rebuild with nix-output-monitor if available
      nix() {
        if ! command -v nom >/dev/null 2>&1; then
          command nix "$@"
          return
        fi

        local -a pre_args
        while [[ $# -gt 0 ]]; do
          case "$1" in
            build)
              shift
              nom build "''${pre_args[@]}" "$@"
              return
              ;;
            -*)
              pre_args+=("$1")
              shift
              ;;
            *)
              command nix "''${pre_args[@]}" "$@"
              return
              ;;
          esac
        done
        command nix "''${pre_args[@]}"
      }

      nixos-rebuild() {
        if command -v nom >/dev/null 2>&1; then
          setopt localoptions pipefail
          command nixos-rebuild "$@" |& nom
        else
          command nixos-rebuild "$@"
        fi
      }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
