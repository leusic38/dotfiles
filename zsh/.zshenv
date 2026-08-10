# Définit ZDOTDIR pour que zsh trouve les fichiers dans ~/.config/zsh/
export ZDOTDIR="$HOME/.config/zsh"
# Variables d'environnement zsh (chargé avant .zshrc pour chaque shell)

# Historique
export HISTSIZE=2000
export SAVEHIST=2000
export HISTFILE=~/.local/share/zsh/history

# Timeout pour les séquences de touches (vi mode)
export KEYTIMEOUT=1
