" ------------------------------------------------------------------------------
"   _____     _____ _           _
"  |  _  |_ _| __  | |___ ___ _| |
"  |   __| | | __ -| | -_|   | . |
"  |__|  |_  |_____|_|___|_|_|___|
"        |___|                2021
" ------------------------------------------------------------------------------
"  -= No compatability for you =-
" ------------------------------------------------------------------------------
set nocompatible
" ------------------------------------------------------------------------------
"  -= No Cursor Keys =-
" ------------------------------------------------------------------------------
no <Up> <Nop>
no <Down> <Nop>
no <Left> <Nop>
no <Right> <Nop>

" ------------------------------------------------------------------------------
"  -= Leader Key =-
" ------------------------------------------------------------------------------
let mapleader="\\"

" ------------------------------------------------------------------------------
"  -= General Keybindings =-
" ------------------------------------------------------------------------------
" shift panes
no <C-h> :wincmd h<CR>
no <C-j> :wincmd j<CR>
no <C-k> :wincmd k<CR>
no <C-l> :wincmd l<CR>

" ALT+k move line up
nno k kddpk
" ALT+j move line down
nno j ddp
" ALT+l move visual selection right
vno l xp`<lma`>lmb`a`b
" ALT+h move visual selection left
vno h xhhp`<hma`>hmb`a`b

" write, quit, force-quit
no <leader>w :w<CR>
no <leader>q :q<CR>
no <leader>Q :q!<CR>

" reload .vimrc
no <leader>r :source ~/.vimrc<CR>

" clear search
no <leader><space> :let @/=''<CR>
" show/hide non-printing chars
no <leader>1 :set list!<CR>
" show hide spell-checking
nno <leader>s :set spell!<CR>

" set magic search
nno / /\v
vno / /\v

" unbind delete in normal mode
nno <delete> <Nop>

" ------------------------------------------------------------------------------
"  -= Colors =-
" ------------------------------------------------------------------------------
set t_Co=256
set background=dark
colorscheme slate

" ------------------------------------------------------------------------------
"  -= Line Numbers =-
" ------------------------------------------------------------------------------
set nonumber
set noruler

" ------------------------------------------------------------------------------
"  -= Default Settings =-
" ------------------------------------------------------------------------------
syntax on
filetype plugin indent on
set encoding=utf-8

" mouse support
set mouse=a

" extra chars
set fillchars+=vert:│
set listchars=tab:│\ ,eol:¬,extends:▶,trail:·,precedes:◀
set list

" search
set incsearch
set ignorecase
set smartcase
set showmatch
set hlsearch

" menus
set wildmenu
set wildmode=full
set completeopt=menuone,noinsert

" text rendering
set nowrap
set foldenable
set foldmethod=manual
set scrolloff=5
set ttyfast
set visualbell

" security
set modelines=0
set nomodeline
set statusline=\ %t\ %m%r%y

" status
set shortmess=aAIsT
set nosmd
set noshowcmd
set cmdheight=2
set laststatus=2

" splitting
set splitright

" editing
set virtualedit=block
set backspace=indent,eol,start
set hidden

" formatting
set formatoptions=n1j
set foldlevel=99
set smartindent
set tabstop=2
set shiftwidth=2
set softtabstop=2

" undo file
if version > 720
	set undofile
	set undodir=~/.vimundo/
endif

" autocmds
autocmd BufWritePre *.py execute ':Black'
autocmd BufNewFile,BufRead *.py nn <F5> :confirm w <bar> !/usr/bin/env python3 %<CR>
autocmd BufNewFile,BufRead *.sh nn <F5> :!bash %<CR>
