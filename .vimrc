" Plug settings
call plug#begin('~/.vim/plugged')
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/vim-easy-align'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'junegunn/vim-github-dashboard'
Plug 'derekwyatt/vim-scala'
Plug 'kongo2002/fsharp-vim'
Plug 'tpope/vim-git'
Plug 'vim-scripts/pep8'
Plug 'scrooloose/nerdtree'
Plug 'alfredodeza/pytest.vim'
Plug 'fs111/pydoc.vim'
Plug 'ktvoelker/sbt-vim'
Plug 'vim-scripts/TaskList.vim'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-markdown'
Plug 'sjl/gundo.vim'
call plug#end()

filetype plugin indent on
" copy indent from current line

set autoindent

syntax on

let mapleader=","

" ,v tasklist
nnoremap <leader>v <Plug>TaskList

" ,o open a new file
nnoremap <Leader>o :CtrlP<CR>

" ,w save current file
nnoremap <Leader>w :w<CR>

" copy and paste
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" ,, enters visual mode
nmap <Leader><Leader> V

" always show status line
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}

" fold lines based on identation
set foldmethod=indent

" default to all lines unfolded
set foldlevel=99

" smart indenting based on language
" set smartindent

" use spaces not tabs
set softtabstop=4
set shiftwidth=4
set expandtab

" backspace over everything in insert mode
set backspace=indent,eol,start

" set color scheme and font options
" colorscheme kolor
set guifont=Consolas:h11
"colorscheme=kolor

autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" reminders
" command mode: ^ = start of line, non whitespace, $ = eol
" ctrl+f = pgdown, ctrl+b = pgup
"
" paste "+gP
" copy "+y
" cut "+x
"
" edit down
" ctrl+q, shift+down, I#, Esc
