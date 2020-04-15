" Plugins {{{
set nocompatible
filetype off
call plug#begin()

Plug 'tpope/vim-surround'
Plug 'altercation/vim-colors-solarized'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'JulioJu/neovim-qt-colors-solarized-truecolor-only'

call plug#end()
" End Plugins }}}

" Basics {{{

filetype plugin indent on	" tbh dont know what this one does but it's important lol
syntax on	" Syntax Highlighting

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Add spelling dictionary to completion only if spellcheck is on
set complete=.,w,b,u,t,i,kspell

" Indentation Settings (Tabs only)
set noexpandtab
set tabstop=4
set shiftwidth=0
set softtabstop=0
set smarttab

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" End Basics }}}

" Visual Stuff {{{

" Viewport Settings {{{
set number rnu	" Hybrid Line Numbers
set ruler		" Show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch	" do incremental searching
set hlsearch	" highlight search results
set nobk nowb	" Do not keep backup file
highlight clear SignColumn	" Make gutter blend in
" }}}

" Gui Settings {{{
if has("gui_running")
	colorscheme solarized_nvimqt " B)
	set guifont=Fira\ Code\ Light:h18 " set font
	let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	" Make comments not italic (it breaks firacode)
	highlight Comment gui=none
	set background=dark " set to light if u want?? but light mode sux lul
else
	set background=dark
	let g:solarized_termcolors=256
	colorscheme solarized
endif
" }}}

" ToggleBg() {{{
function! s:ToggleBg()
	let &background = ( &background == "dark"? "light" : "dark" )
    if exists("g:colors_name")
        exe "colorscheme " . g:colors_name
    endif
endfunction
" }}}

" End Visual Stuff }}}

" Filetype-Specific Stuff {{{

augroup FTSpecific
	autocmd!
	" Syntax based folding for rust files, but start completely unfolded
	autocmd BufRead *.rs
				\ setlocal foldmethod=syntax |
				\ setlocal foldlevel=100
	" Indentation Settings (Rust is a meanie and formats to spaces even if you
	" try to use tabs)
	autocmd BufRead *.rs 
				\ set expandtab |
				\ set tabstop=4 |
				\ set shiftwidth=4 |
				\ set softtabstop=-1 |
				\ set smarttab
	autocmd BufRead .vimrc,init.vim :setlocal foldmethod=marker
augroup END

" End Filetype-Specific Stuff }}}

" Keybinds {{{

" Buffers {{{
" Ctrl-B to quickly switch to last buffer
nnoremap <C-B> :b!#<Enter>
" Switch buffers quickly a la tpope/vim-unimpaired
nnoremap ]b :bnext!<Enter>
nnoremap [b :bprevious!<Enter>
" Close buffer
nnoremap -b :bd<Enter>
" }}}

" Ctrl-S to save
nnoremap <C-S> :w<Enter>

" z1 folds 1st layer of folds
nnoremap z1 :%foldc<Enter>

" \rc to reload vimrc and the open file
nnoremap <leader>rc :so $MYVIMRC<Enter>:e<Enter>

" bg to toggle between light and dark background
nmap bg :call <SID>ToggleBg()<CR>

" End Keybinds }}}

" Plugin Stuff {{{

" Automatically format rust code on save
let g:rustfmt_autosave = 1

" End Plugin Stuff }}}

" COC Settings {{{

" Tab opens completion, as well as cycling thru it (shift tab goes back)
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" map ctrl-space (and the weird terminal thing that it maps to) to do completion
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <c-@> coc#refresh()
nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" End COC Settings }}}

