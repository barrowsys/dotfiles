" Plugins {{{
	" Install vim-plug if it isn't
	if empty(glob('~/.vim/autoload/plug.vim'))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
			\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif
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
	Plug 'tpope/vim-repeat'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'honza/vim-snippets/'
	Plug 'bling/vim-bufferline'
	Plug 'itchyny/lightline.vim'
	Plug 'scrooloose/syntastic'
	Plug 'godlygeek/tabular'
	Plug 'plasticboy/vim-markdown'
	Plug 'mattn/emmet-vim'
	Plug 'wellle/targets.vim'
	Plug 'tibabit/vim-templates'
	Plug 'wannesm/wmgraphviz.vim'
	Plug 'kshenoy/vim-signature'
	Plug 'morhetz/gruvbox'
	Plug 'flazz/vim-colorschemes'
	Plug 'joshdick/onedark.vim'
	Plug 'nanotech/jellybeans.vim'
	Plug 'jonathanfilip/vim-lucius'

	call plug#end()
" End Plugins }}}

" Basics {{{
	filetype plugin indent on
	syntax on
	set backspace=indent,eol,start " allow backspacing across lines
	set complete=.,w,b,u,t,i,kspell " Add spelling dictionary to completion only if spellcheck is on
	" Indentation Settings (Tabs only)
	set noexpandtab tabstop=4 shiftwidth=0 softtabstop=0 smarttab
	" Toggle mouse support with \m
	nnoremap <Leader>m :let &mouse = ( &mouse == "" ? "a" : "" )<CR>
	set number rnu ruler showcmd incsearch nobk nowb
" End Basics }}}

" ~ a e s t h e t i c s ~ "
source $HOME/.vim/theme.vim

" Filetype-Specific Stuff {{{
	augroup FTSpecific
		autocmd!
		" Syntax based folding for rust files, but start completely unfolded
		" Also, map gq in rust files to RustFmt
		autocmd BufRead *.rs
					\ setlocal foldmethod=syntax |
					\ setlocal foldlevel=100 |
					\ nnoremap <buffer> gq :RustFmt<CR>
		" Indentation Settings (Rust is a meanie and formats to spaces even if you
		" try to use tabs, but hey at least it's standard)
		autocmd BufRead *.rs
					\ set expandtab |
					\ set tabstop=4 |
					\ set shiftwidth=4 |
					\ set softtabstop=-1 |
					\ set smarttab
		autocmd BufRead .bashrc,.vimrc,*.vim :setlocal foldmethod=marker
	augroup END
" End Filetype-Specific Stuff }}}

" Functions {{{

	" cr{motion} Change/Replace {{{
		" replace text with the contents of a register,,
		" leaving the register intact
		nnoremap <silent> cr :let b:regreplace_buffer = v:register<CR>:set opfunc=RegReplace<CR>g@
		function! RegReplace(type)
			let l:raddr = b:regreplace_buffer
			let l:rdata = getreg(l:raddr)
			if a:0
				silent exec "normal! `<" . a:type . "`>c" . l:rdata
			elseif a:type == 'line'
				silent exec "normal! '[V']c" . l:rdata
			elseif a:type == 'block'
				silent exec "normal! `[\<C-V>`]c" . l:rdata
			else
				silent exec "normal! `[v`]c" . l:rdata
			endif
			call setreg(l:raddr, l:rdata)
		endfunction
	" End cr{motion} Change/Replace }}}

	" Marker Folds {{{
		" Surrounds a given text linewise with triple {} fold points.
		" :set foldmethod=marker babeyyyyy
		nnoremap ysm :set opfunc=FoldIn<CR>g@
		vnoremap Sm :<C-U>call FoldIn(visualmode())<CR>
		function! FoldIn(type)
			let l:undo = undotree().seq_cur
			try
				if a:type ==? "V"
					let l:startline = line("'<")
					let l:endline = line("'>")
				else
					let l:startline = line("'[")
					let l:endline = line("']")
				endif
				let l:name = input("Name: ")
				call append(l:startline-1, [join(['"', l:name, repeat('{', 3)], ' ')])
				call append(l:endline+1, [join(['"', 'End', l:name, repeat('}', 3)], ' ')])
			catch
				echoe "Exception!" v:exception
				exec "undo "..l:undo
			endtry
		endfunction
	" End Formatting }}}

" End Functions }}}

" Keybinds {{{

	" Ctrl-S to save
	nnoremap <C-S> :w<CR>

	" Folds {{{
		" z1 to interact with only the top layer of folds
		nnoremap z1c :%foldc<CR>
		nnoremap z1o :%foldo<CR>
		" next and previous folds as motions,, now in arrow keys
		nnoremap z<Down> zj
		nnoremap z<Up> zk
	" End Folds }}}

	" Buffers {{{
		" Ctrl-B to quickly switch to last buffer
		nnoremap <silent> <C-B> :b!#<CR>
		" Switch buffers quickly a la tpope/vim-unimpaired
		nnoremap <silent> ]b :bnext!<CR>
		nnoremap <silent> [b :bprevious!<CR>
		" Close buffer
		nnoremap <silent> -b :bd<CR>
	" End Buffers }}}

	" Config Helpers {{{
		" \rc to reload vimrc and \rf to reload the open file
		nnoremap <leader>rc :so $MYVIMRC<CR>:do User ReloadConfig<CR>
		nnoremap <leader>rf :e<CR>
		" \pi to install plugins, \pc to clean
		nnoremap <leader>pi :PlugInstall<CR>
		nnoremap <leader>pc :PlugClean<CR>
	" End Config Helpers }}}

" End Keybinds }}}

" Commands {{{

	" vim -c :Help starts a fullscreen help
	command! -bar Help :tab help | :tabonly

" End Commands }}}

" Plugin Stuff {{{
	" DON'T automatically format rust code on save
	" Instead use the gq/Q binding (see filetype-specific stuff)
	" Discussion: but why tho? -e
	" somebody got mad at us for accidently formatting their shit when we
	" submitted a PR lol -j
	let g:rustfmt_autosave = 0

	" Make emmet trigger with <C-t>,
	" The default is <C-y> but thats the binding to scroll the buffer upwards
	" without changing ur cursor position
	let g:user_emmet_leader_key=''

	" Templates {{{
		" Discussion: this is nonsense lol. we could remove this any time.

		let g:tmpl_search_paths = ['~/templates']

		let g:tmpl_author_name = "Ezra Barrow"
		let g:tmpl_author_email = "barrow@tilde.team"
		let g:tmpl_license = "MPL-2.0"
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
		" Discussion: not used, can remove?
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


