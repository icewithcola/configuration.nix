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
      (lib.mkIf (config.kagura.home.type == "headless") {
        dig = "doggo";
      })
    ];

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    zplug = {
      enable = true;
      plugins = [ { name = "zsh-users/zsh-autosuggestions"; } ];
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
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
