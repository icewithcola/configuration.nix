{...}:
{
  imports = [./configuration.nix]
  home-manager.users.kagura = import (users.users.kagura.home + '.config/home-manager/home.nix');
}