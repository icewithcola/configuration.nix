git_init_null() {
  git config user.email "me@kagurach.uk"
  git config user.name "kagura"  
  export GPG_TTY=$(tty)
}

git_init_kagura114(){
  git config user.email "me@lolicon.cyou"
  git config user.name "kagura114"  
  git config user.signingkey CB63871A8B336B32
  export GPG_TTY=$(tty)
}

git_init_icewithcola(){
  git config user.email "me@kagurach.uk"
  git config user.name "icewithcola"  
  git config user.signingkey B53793A578D3925B
  export GPG_TTY=$(tty)
}

git_account_kagura114(){
  eval $(ssh-agent -s)
  ssh-add /home/kagura/.ssh/id_ed25519
}

git_account_icewithcola(){
  eval $(ssh-agent -s)
  ssh-add /home/kagura/.ssh/gh_icewithcola
}
