" Vundle {{{
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-surround'
Plugin 'rust-lang/rust.vim'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'file:///home/barrow/.vim/coc.nvim/' " Hacky workaround for not doing this properly lol

call vundle#end()"
" End Vundle }}}

" Basics {{{

filetype plugin indent on	" tbh dont know what this one does but it's important lol
syntax on	" Syntax Highlighting

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Viewport Settings
set number rnu	" Hybrid Line Numbers
set ruler		" Show the cursor position all the time
set showcmd		" display incomplete commands
set history=50	" keep 50 lines of command line history
set incsearch	" do incremental searching
set hlsearch	" highlight search results
set nobackup	" Do not keep backup file
set nowritebackup	" ^^^
highlight clear SignColumn	" Make gutter blend in

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

" Filetype-Specific Stuff {{{

augroup FTSpecific
	:autocmd!
	" Syntax based folding for rust files, but start completely unfolded
	autocmd BufRead *.rs
				\ :setlocal foldmethod=syntax |
				\ :setlocal foldlevel=100
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

" Ctrl-B to quickly switch to last buffer
nnoremap <C-B> :b!#<Enter>

" Switch buffers quickly a la tpope/vim-unimpaired
nnoremap ]b :bnext!<Enter>
nnoremap [b :bprevious!<Enter>
" Close buffer
nnoremap -b :bd<Enter>

" Ctrl-S to save
nnoremap <C-S> :w<Enter>

" z1 folds 1st layer of folds
nnoremap z1 :%foldc<Enter>

" \rc to reload vimrc and the open file
nnoremap <leader>rc :so $MYVIMRC<Enter>:e<Enter>

" End Keybinds }}}



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
"These came with the thing idk
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
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

