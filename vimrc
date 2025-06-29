" Vim configuration with Vundle and Catppuccin Macchiato theme
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Catppuccin colorscheme
Plugin 'catppuccin/vim'

" Essential plugins
Plugin 'preservim/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-markdown'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'dense-analysis/ale'
Plugin 'Yggdroot/indentLine'
Plugin 'jiangmiao/auto-pairs'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" General settings
set number                    " Show line numbers
set relativenumber           " Show relative line numbers
set cursorline              " Highlight current line
set showcmd                 " Show command in bottom bar
set wildmenu                " Visual autocomplete for command menu
set showmatch               " Highlight matching parentheses
set incsearch               " Search as characters are entered
set hlsearch                " Highlight matches
set ignorecase              " Case insensitive search
set smartcase               " But case sensitive when uppercase present
set autoindent              " Auto indent
set smartindent             " Smart indent
set expandtab               " Use spaces instead of tabs
set shiftwidth=4            " Number of spaces to use for autoindent
set tabstop=4               " Number of visual spaces per TAB
set softtabstop=4           " Number of spaces in tab when editing
set wrap                    " Wrap lines
set linebreak               " Break lines at word boundaries
set scrolloff=8             " Keep 8 lines above/below cursor
set sidescrolloff=8         " Keep 8 columns left/right of cursor
set backspace=indent,eol,start " Allow backspace in insert mode
set hidden                  " Allow hidden buffers
set history=1000            " Remember more commands
set undolevels=1000         " More undo levels
set visualbell              " No beeping
set noerrorbells            " No error bells
set t_vb=                   " No visual bell
set mouse=a                 " Enable mouse support
set clipboard=unnamed       " Use system clipboard
set encoding=utf-8          " UTF-8 encoding
set fileencoding=utf-8      " UTF-8 file encoding
set ruler                   " Show cursor position
set laststatus=2            " Always show status line

" Color scheme and appearance
if (has("termguicolors"))
  set termguicolors
endif
set background=dark

" Try to set catppuccin_macchiato colorscheme with fallback
try
  colorscheme catppuccin_macchiato
catch /^Vim\%((\a\+)\)\=:E185/
  " Catppuccin not available, use fallback
  try
    colorscheme desert
  catch /^Vim\%((\a\+)\)\=:E185/
    " Use default if nothing else works
    colorscheme default
  endtry
endtry

" Airline theme with fallback
if exists('g:loaded_airline')
  try
    let g:airline_theme = 'catppuccin_macchiato'
  catch
    " Fallback to a default theme if catppuccin is not available
    let g:airline_theme = 'dark'
  endtry
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_powerline_fonts = 1
endif

" Status line (fallback if airline is not available)
if !exists('g:loaded_airline')
    set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
endif

" NERDTree settings
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc$', '\~$', '\.git$', '__pycache__', 'node_modules']

" FZF settings
if executable('fzf')
    map <C-p> :Files<CR>
    map <C-f> :Rg<CR>
endif

" Git gutter settings
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

" ALE settings
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tslint'],
\   'rust': ['cargo'],
\   'go': ['golint', 'go vet'],
\}
let g:ale_fixers = {
\   'python': ['black', 'isort'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'rust': ['rustfmt'],
\   'go': ['gofmt'],
\}
let g:ale_fix_on_save = 1

" IndentLine settings
let g:indentLine_char = '│'
let g:indentLine_enabled = 1

" Folding settings
set foldmethod=indent
set foldlevel=99

" Key mappings
let mapleader = " "

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Clear search highlighting
nnoremap <leader>/ :nohlsearch<CR>

" Save and quit shortcuts
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" Copy and paste with system clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Enter visual mode
nmap <Leader><Leader> V

" Toggle paste mode
set pastetoggle=<F2>

" Quick edit vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" File type specific settings
autocmd FileType python setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType javascript,typescript,json,html,css,yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType rust setlocal shiftwidth=4 tabstop=4 softtabstop=4

" Markdown syntax highlighting
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END