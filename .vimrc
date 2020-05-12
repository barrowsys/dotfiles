" Plugins {{{
set nocompatible
filetype off
call plug#begin()

Plug 'icymind/NeoSolarized'
Plug 'rust-lang/rust.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets/'
Plug 'bling/vim-airline'
Plug 'bling/vim-bufferline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'mattn/emmet-vim'

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

" CTRL-U in insert mode deletes a lot.	Use CTRL-G u to first break undo,
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
" }}}

" Theme Settings {{{
" I think these two enable true color in terminal,, or something
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

colorscheme NeoSolarized
set background=dark

set guifont=Fira\ Code\ Light:h19 " set font

" Make comments not italic (it breaks firacode)
highlight Comment gui=none
highlight clear SignColumn	" Make gutter blend in
" }}}

" ToggleBg() {{{
function! s:ToggleBg()
	let &background = ( &background == "dark"? "light" : "dark" )
	if exists("g:colors_name")
		exe "colorscheme " . g:colors_name
	endif
	highlight clear SignColumn	" Make gutter blend in
endfunction
" }}}

" End Visual Stuff }}}

" Filetype-Specific Stuff {{{

augroup FTSpecific
	autocmd!
	" Syntax based folding for rust files, but start completely unfolded
	autocmd BufRead *.rs
				\ setlocal foldmethod=syntax |
				\ setlocal foldlevel=100 |
				\ nnoremap <buffer> gq :RustFmt<Enter>
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

" Config Helpers {{{
" \rc to reload vimrc and \rf to reload the open file
nnoremap <leader>rc :so $MYVIMRC<Enter>
nnoremap <leader>rf :e<Enter>
" \pi to install plugins
nnoremap <leader>pi :PlugInstall<Enter>

" \bg to toggle between light and dark background
nmap <Leader>bg :call <SID>ToggleBg()<CR>
" }}}

" \tg to toggle tagbar
nmap <Leader>tg :TagbarToggle<CR>

" End Keybinds }}}

" Plugin Stuff {{{

" DON'T automatically format rust code on save
" Instead use the Q binding
let g:rustfmt_autosave = 0

" Make emmet trigger with <C-y>,
let g:user_emmet_leader_key=''

" Airline {{{

" Enable powerline in the status bar
let g:airline_powerline_fonts = 1

" Set theme
let g:airline_theme='owo'
let g:airline_skip_empty_sections = 1
let g:airline_section_z='%p%% %{g:airline_symbols.linenr}%0l/%L:%v'

" }}}

" COC Settings {{{

" Completion Bindings {{{
" map ctrl-space to do completion
inoremap <silent><expr> <c-space> coc#refresh()
" Tab opens completion, as well as cycling thru it (shift tab goes back)
inoremap <silent><expr> <TAB>
	\ pumvisible() ? "\<C-n>" :
	\ <SID>check_back_space() ? "\<TAB>" :
	\ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
let col = col('.') - 1
return !col || getline('.')[col - 1]	=~# '\s'
endfunction
" }}}

nmap <silent> gd <Plug>(coc-definition)
nmap <leader>rn <Plug>(coc-rename)
" Snippets {{{
imap <C-l> <Plug>(coc-snippets-expand)
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'
imap <C-j> <Plug>(coc-snippets-expand-jump)
" }}}
"inoremap <silent><expr> <c-@> coc#refresh()
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show Documentation with K {{{
function! s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
" }}}

" End COC Settings }}}

" End Plugin Stuff }}}


