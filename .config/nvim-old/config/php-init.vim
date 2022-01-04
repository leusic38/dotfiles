" Php vim config

if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.config/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

"Plugins
call plug#begin('~/.config/nvim/plugged')
source ~/.config/nvim/config/core-plugins.vim
source ~/.config/nvim/config/php-plugins.vim
"source ~/.config/nvim/config/web-plugins.vim
call plug#end()

"Config

source ~/.config/nvim/config/core-config.vim
source ~/.config/nvim/config/php-config.vim
