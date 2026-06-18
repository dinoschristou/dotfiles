set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'catppuccin/vim', { 'as': 'catppuccin' }
Plugin 'preservim/nerdtree'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'

call vundle#end()
filetype plugin indent on

" Appearance
if has('termguicolors')
  set termguicolors
endif
set background=dark
try
  colorscheme catppuccin_macchiato
catch
  colorscheme desert
endtry

" Options
set number relativenumber
set cursorline
set expandtab shiftwidth=2 tabstop=2 softtabstop=2
set smartindent autoindent
set ignorecase smartcase
set incsearch hlsearch
set scrolloff=8 sidescrolloff=8
set hidden
set mouse=a
set clipboard=unnamed
set encoding=utf-8 fileencoding=utf-8
set backspace=indent,eol,start
set history=1000 undolevels=1000
set wildmenu showcmd showmatch
set laststatus=2 ruler
set visualbell noerrorbells
set wrap linebreak

" Status line (when airline is absent)
set statusline=%f%m%r%h%w\ %y\ %l:%v\ %p%%

" Leader
let mapleader = ' '

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Misc
nnoremap <leader>/ :nohlsearch<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
set pastetoggle=<F2>

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc$', '\~$', '\.git$', '__pycache__', 'node_modules']

" FZF if available
if executable('fzf')
  set rtp+=/opt/homebrew/opt/fzf
  nnoremap <C-p> :FZF<CR>
endif

" Filetype indentation
autocmd FileType javascript,typescript,json,html,css,yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4
autocmd FileType python setlocal shiftwidth=4 tabstop=4
