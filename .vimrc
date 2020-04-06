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
"Plugin 'vim-syntastic/syntastic'
"Plugin 'szw/vim-tags'
"Plugin 'majutsushi/tagbar'
"Plugin 'lifepillar/vim-mucomplete'

call vundle#end()"
" End Vundle }}}

" Basics {{{

filetype plugin indent on
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

" Add spelling dictionary to completion only if spellcheck is on
set complete=.,w,b,u,t,i,kspell

" Indentation Settings
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

" Rusty-Tags Config {{{
" Doc: https://github.com/dan-t/rusty-tags#vim-configuration

" Set tags file to rusty_tags.vi
autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty_tags.vi
" Generate tags file on save
autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!

" End Rusty-Tags Config }}}

" Misc Stuff {{{
" This was included in the example .vimrc i started with
" Might as well keep it in

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" End Misc Stuff }}}

" Plugin Settings {{{

" let g:rustfmt_autosave = 1

" Map F9 to toggle tagbar
nnoremap <silent> <F9> :TagbarToggle<CR>

" End Plugin Settings }}}

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
"if &t_Co > 2 || has("gui_running")
"  autocmd GUIEnter * set vb t_vb=
"endif

"set foldmethod=syntax
