# Zsh login profile

# Source le profile générique
[ -f "$HOME/.config/shell/profile" ] && . "$HOME/.config/shell/profile"

# ZDOTDIR est déjà défini avant ce fichier (par /etc/zsh/zshenv ou similaire)
# mais on le redéfinit ici pour être sûr
export ZDOTDIR="$HOME/.config/zsh"
