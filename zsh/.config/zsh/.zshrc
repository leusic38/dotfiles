# Configuration zsh interactive

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Couleurs
autoload -U colors && colors

# env by dir
eval "$(direnv hook zsh)"

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
_comp_options+=(globdots)

# Mode vi
bindkey -v

# Indicateur de mode vi dans le prompt
VI_MODE_INDICATOR_NORMAL="%F{yellow}[N]%f"
VI_MODE_INDICATOR_INSERT="%F{green}[I]%f"
VI_MODE_INDICATOR_VISUAL="%F{magenta}[V]%f"
VI_MODE_INDICATOR_VLINE="%F{magenta}[VL]%f"
VI_MODE_PROMPT="$VI_MODE_INDICATOR_INSERT"

# Forme du curseur selon le mode (séquences DECSCUSR)
VI_CURSOR_BLOCK=$'\e[2 q'   # bloc plein (normal / visuel)
VI_CURSOR_BEAM=$'\e[6 q'    # barre "|" (insertion)

# Le mode visuel reste sur le keymap vicmd ; on le distingue via $REGION_ACTIVE.
# zle-keymap-select ne se déclenche pas à l'entrée/sortie du mode visuel, donc on
# recalcule l'indicateur à chaque redraw via line-pre-redraw (sans reset-prompt :
# le redraw réévalue déjà ${VI_MODE_PROMPT} dans PROMPT).
function _vi_mode_indicator {
  local new cursor
  case $KEYMAP in
    vicmd)
      cursor="$VI_CURSOR_BLOCK"
      case $REGION_ACTIVE in
        1) new="$VI_MODE_INDICATOR_VISUAL" ;;
        2) new="$VI_MODE_INDICATOR_VLINE" ;;
        *) new="$VI_MODE_INDICATOR_NORMAL" ;;
      esac
      ;;
    *) new="$VI_MODE_INDICATOR_INSERT"; cursor="$VI_CURSOR_BEAM" ;;
  esac
  # reset-prompt seulement si l'indicateur change (sinon boucle de redraw infinie)
  if [[ $new != $VI_MODE_PROMPT ]]; then
    VI_MODE_PROMPT="$new"
    print -n -- "$cursor"
    zle reset-prompt
  fi
}
# add-zle-hook-widget permet de cumuler plusieurs hooks (cohabite avec les plugins)
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-pre-redraw _vi_mode_indicator

# Chaque nouveau prompt démarre en insertion -> curseur en barre "|"
function _vi_cursor_beam_precmd { print -n -- "$VI_CURSOR_BEAM" }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _vi_cursor_beam_precmd

# Réduit le délai de bascule normal/insert (par défaut 0.4s)
export KEYTIMEOUT=1

# Recherche dans l'historique
bindkey '^R' history-incremental-pattern-search-backward

# Editer la ligne dans vim (ctrl-v)
autoload edit-command-line; zle -N edit-command-line
bindkey '^v' edit-command-line
autoload -U edit-command-line && zle -N edit-command-line && bindkey -M vicmd "^v" edit-command-line

# Navigation vim dans le menu de completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Aliases
[ -f ~/.config/shell/aliasesrc ] && source ~/.config/shell/aliasesrc

# Plugins
source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Git prompt - variables de thème
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
export ZSH_THEME_GIT_PROMPT_BRANCH_MAX_LENGTH=20

# export NODE_EXTRA_CA_CERTS="/home/manu/Projects/lama/docker/nginx/dev/ssl/server.crt"

source $ZDOTDIR/plugins/zsh-git-prompt/git-prompt.zsh

# Override make completion to include local.mk and all included .mk files
_make() {
  local -a targets
  targets=($(make -pnq 2>/dev/null \
    | awk -F: '/^[a-zA-Z0-9][a-zA-Z0-9_-]*[[:space:]]*:([^=]|$)/ && !/^#/ && !/^Makefile/ { print $1 }' \
    | sort -u))
  _describe 'targets' targets
}

# Prompt
PROMPT=$'┏╸%F{033}%n%f@%F{045}%m%f->\x1b[3m%}%(?..%F{red}%?%f · )%F{160}%d%f\x1b[0m%}$(gitprompt)\n┗╸${VI_MODE_PROMPT} %B%F{cyan}❯%f%b '
export PHPSTAN_CONFIG=phpstan.next.neon
