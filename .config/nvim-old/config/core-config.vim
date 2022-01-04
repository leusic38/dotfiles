" config core plugins
"
set nocompatible
set number
set hlsearch "highlight search result
set ignorecase
set smartcase " Do not ignore case if search patter has huppercase
syntax on
colorscheme onedark

source ~/.config/nvim/config/plugin-config/nerd.vim
"source ~/.config/nvim/config/plugin-config/fzf.vim

let g:airline_theme='onedark'

" fzf
nnoremap <C-p> :Files<cr> " find files
