bindkey -e

autoload -Uz compinit && compinit
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' rehash true
zstyle :compinstall filename "$HOME/.zshrc"

HISTFILE=$HOME/.zhistory
HISTSIZE=SAVEHIST=99999
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

# set up/down keys to glob history
[[ -n "${key[Up]}"   ]]  && bindkey "${key[Up]}" history-search-backward
[[ -n "${key[Down]}" ]]  && bindkey "${key[Down]}" history-search-forward
[[ -n "^[[A" ]]  && bindkey "^[[A" history-search-backward
[[ -n "^[[B" ]]  && bindkey "^[[B" history-search-forward

autoload -Uz colors && colors
PS1="%F{blue}%n%f%F{green}@%f%F{red}%m%f%F{green}:%f%F{yellow}%~%f%(?.%F{green}.%F{red})%(!.#.$)%f "

alias sl="ls"
alias ll="ls -l"
alias la="ls -la"

export 0x0(){
  uri="https://0x0.st"
  arg="${1:-/dev/stdin}"

  case "$arg" in
  http://*|https://*)
    curl -F "url=$arg" $uri
    ;;
  *)
    curl --http1.1 -F "file=@$arg" $uri
    ;;
  esac
}
