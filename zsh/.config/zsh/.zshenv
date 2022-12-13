
autoload -U colors && colors
export ZSH_GIT_PROMPT_FORCE_BLANK=1
export ZSH_GIT_PROMPT_SHOW_UPSTREAM="full"

export ZSH_THEME_GIT_PROMPT_PREFIX="%B [ %b"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%B ] %b"
export ZSH_THEME_GIT_PROMPT_SEPARATOR="%B -> %b"
export ZSH_THEME_GIT_PROMPT_BRANCH="⎇  %{$fg_bold[cyan]%}"
export ZSH_THEME_GIT_PROMPT_UPSTREAM_SYMBOL=" %{$fg_bold[yellow]%}⟳ "
export ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX=" %{$fg[yellow]%} ⤳ "
export ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX=""
export ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_no_bold[cyan]%}:"
export ZSH_THEME_GIT_PROMPT_BEHIND=" %{$fg_no_bold[cyan]%}↓ "
export ZSH_THEME_GIT_PROMPT_AHEAD=" %{$fg_no_bold[cyan]%}↑ "
export ZSH_THEME_GIT_PROMPT_UNMERGED=" %{$fg[red]%}✖ "
export ZSH_THEME_GIT_PROMPT_STAGED=" %{$fg[green]%}● "
export ZSH_THEME_GIT_PROMPT_UNSTAGED=" %{$fg[red]%}✚ "
export ZSH_THEME_GIT_PROMPT_UNTRACKED=" … "
export ZSH_THEME_GIT_PROMPT_STASHED=" %{$fg[blue]%}⚑ "
export ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg_bold[green]%}✔"
export HISTSIZE=2000
export SAVEHIST=2000
export HISTFILE=~/.local/share/zsh/history
export KEYTIMEOUT=1
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

