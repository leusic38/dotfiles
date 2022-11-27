
autoload -U colors && colors
export ZSH_THEME_GIT_PROMPT_CACHE=yes
export  ZSH_THEME_GIT_PROMPT_PREFIX="["
export  ZSH_THEME_GIT_PROMPT_SUFFIX="]"
export  ZSH_THEME_GIT_PROMPT_HASH_PREFIX=":"
export  ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
export  ZSH_THEME_GIT_PROMPT_BRANCH="%F{2}%{%G%}"
export  ZSH_THEME_GIT_PROMPT_STAGED=" %{$fg[red]%}%{●%G%}"
export  ZSH_THEME_GIT_PROMPT_CONFLICTS=" %{$fg[red]%}%{✖%G%}"
export  ZSH_THEME_GIT_PROMPT_CHANGED=" %{$fg[blue]%}%{✚%G%}"
export  ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%2G%}"
export  ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%2G%}"
export  ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[blue]%}%{⚑%G%}"
export  ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[cyan]%}%{…%G%}"
export  ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"
export  ZSH_THEME_GIT_PROMPT_LOCAL=" L"
# The remote branch will be shown between these two
export  ZSH_THEME_GIT_PROMPT_UPSTREAM_FRONT=" {%{$fg_bold[blue]%}"
export  ZSH_THEME_GIT_PROMPT_UPSTREAM_END="%{${reset_color}%}}"
export HISTSIZE=2000
export SAVEHIST=2000
export HISTFILE=~/.config/zsh/history
export KEYTIMEOUT=1
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

