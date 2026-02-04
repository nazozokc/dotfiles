" =========================
" 基本設定
" =========================
set nocompatible
set encoding=utf-8
scriptencoding utf-8

set number
set relativenumber
set cursorline
set signcolumn=yes
set showcmd
set showmode
set hidden
set updatetime=300
set shortmess+=c

set expandtab
set tabstop=2
set shiftwidth=2
set smartindent
set autoindent

set ignorecase
set smartcase
set incsearch
set hlsearch

set clipboard=unnamedplus
set mouse=a

" =========================
" プラグイン管理 (vim-plug)
" =========================
call plug#begin('~/.vim/plugged')

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" LSP & 補完
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ファイルツリー
Plug 'preservim/nerdtree'

" ファジーファインダー
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" ステータスライン
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" シンタックス
Plug 'sheerun/vim-polyglot'
Plug 'rebelot/kanagawa.nvim'

call plug#end()

" =========================
" キーマップ
" =========================
let mapleader=" "

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" FZF
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<CR>

" Git
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>

" =========================
" GitGutter
" =========================
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

" =========================
" coc.nvim (LSP)
" =========================
set completeopt=menuone,noinsert,noselect

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" =========================
" 見た目
" =========================
set termguicolors
colorscheme kanagawa

let g:airline_powerline_fonts = 1

