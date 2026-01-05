# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  git
  kubectl
  helm
)


# User configuration

source $ZSH/oh-my-zsh.sh

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/default.omp.json)"

alias vi="nvim"
alias v="nvim"
alias gg="lazygit"
alias ff="fzf"
alias getmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"
alias python="python3"
alias devc="devpod up . && devpod ssh . --command "zsh""

if [[ "$(uname)" == 'Darwin' ]]; then
  alias acr="az login && az acr login -n r1k8sacrdev"
fi
