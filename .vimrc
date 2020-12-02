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
	" Plug 'tibabit/vim-templates'
	Plug '~/Documents/vim-templates'
	Plug 'wannesm/wmgraphviz.vim'
	Plug 'kshenoy/vim-signature'
	Plug 'morhetz/gruvbox'
	Plug 'flazz/vim-colorschemes'
	Plug 'joshdick/onedark.vim'
	Plug 'nanotech/jellybeans.vim'
	Plug 'jonathanfilip/vim-lucius'
	Plug 'majutsushi/tagbar'

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
	nnoremap <Leader>mm :let &mouse = ( &mouse == "" ? "a" : "" )<CR>
	set number rnu ruler showcmd incsearch nobk nowb
" End Basics }}}

" Subconfigs {{{

	" ~ a e s t h e t i c s ~ "
	source $HOME/.vim/theme.vim

" End Subconfigs }}}

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
		" Surrounds a given text linewise with commented-out triple {} fold points.
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
				let l:commentstring = get(b:, 'commentary_format', substitute(substitute(substitute(
							\ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', ''))
				call append(l:startline-1, [substitute(l:commentstring, '%s', join([l:name, repeat('{', 3)], ' '), '')])
				call append(l:endline+1, [substitute(l:commentstring, '%s', join(['End', l:name, repeat('}', 3)], ' '), '')])
			catch
				echoe "Exception!" v:exception
				exec "undo "..l:undo
			endtry
		endfunction
	" End Marker Folds }}}
	
	" ExecBuffer {{{
		noremap <Leader>@ :let b:execreg_buffer = v:register<CR>:set opfunc=ExecuteReg<CR>g@
		function! ExecuteText(type)
			" let l:raddr = b:regreplace_buffer
			" let l:rdata = getreg(l:raddr)
			let l:prevreg = getreg('"')
			if a:0
				silent exec "normal! `<" . a:type . "`>y"
			elseif a:type == 'line'
				silent exec "normal! '[V']y"
			elseif a:type == 'block'
				silent exec "normal! `[\<C-V>`]y"
			else
				silent exec "normal! `[v`]y"
			endif
			silent exec 'normal! :<C-R>"<CR>'
			silent exec setreg('"', l:prevreg)
		endfunction
	" End ExecBuffer }}}

	" Move Register {{{
		nnoremap <silent> <Leader>mr :let b:movereg_buffer = v:register<CR>:call MoveRegister()<CR>
		function! MoveRegister()
			let l:raddr = b:movereg_buffer
			let l:rdata = getreg(l:raddr)
			let l:name = input("Register: ")
			setreg(l:name, l:rdata)
		endfunction
	" End Move Register }}}

	" List Bindings {{{
		let g:bindings = {}
		command! Binds :call Bindings()
		function! Bindings()
			let l:keys = keys(g:bindings)
			let l:key = inputlist(l:keys)
		endfunction
		function! s:Bind(category, name, description)
			if !has_key(g:bindings, a:category)
				let g:bindings[a:category] = {}
			endif
			let g:bindings[a:category][a:name] = a:description
		endfunction
		call s:Bind("test", "", "")
		call s:Bind("yeeting", "", "")
		call s:Bind("yoinking", "", "")
		call s:Bind("yateing", "", "")
		call s:Bind("testifying", "", "")
	" End List Bindings }}}

" End Functions }}}

" Keybinds {{{

	" Ctrl-S to save
	nnoremap <C-S> :w<CR>

	" F8 to toggle tagbar
	nnoremap <F8> :TagbarToggle<CR>

	" Leader-w to toggle wrapping
	nnoremap <silent> <Leader>w :set wrap!<CR>

	" Leader-hll to highlight current line
	nnoremap <silent> <Leader>hll :exe "let m = matchadd('ColorColumn', '\\%" . line('.') . "l')"<CR>
	nnoremap <silent> <Leader>hlc :call clearmatches()<CR>

	" Vim-Endwise {{{
		" Disable endwise mappings
		let g:endwise_no_mappings = 1
		" Remap <C-X><CR> manually
		imap <C-X><CR> <CR><C-R>=EndwiseAlways()<CR>
		" Do not map <CR>, see coc <CR> binding below
	" End Vim-Endwise }}}

	" Folds {{{
		" z1 to interact with only the top layer of folds
		nnoremap z1c :%foldc<CR>
		nnoremap z1o :%foldo<CR>
		nnoremap <Leader>z1 :set foldlevel=1<CR>
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
		nnoremap <leader>rc :so $MYVIMRC<CR>
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
		let g:tmpl_search_paths = ['~/templates']

		let g:tmpl_author_name = "Ezra Barrow"
		let g:tmpl_author_email = "barrow@tilde.team"
		let g:tmpl_license = "MIT"
	" }}}

	" COC Settings {{{

		" Completion Bindings {{{
			function! s:check_back_space() abort
				let col = col('.') - 1
				return !col || getline('.')[col - 1]	=~# '\s'
			endfunction
			" map ctrl-space to do completion
			inoremap <silent><expr> <c-space> coc#refresh()
			" Tab opens completion, as well as cycling thru it (shift tab goes back)
			inoremap <silent><expr> <TAB>
				\ pumvisible() ? "\<C-n>" :
				\ <SID>check_back_space() ? "\<TAB>" :
				\ coc#jumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
				\ coc#refresh()
			inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
			inoremap <expr><script><CR>
				\ pumvisible() ? "\<C-y>" :
				\ "\<CR><C-R>=EndwiseDiscretionary()<CR>"
				" ^ Include endwise trigger
		" }}}

		nmap <silent> gd <Plug>(coc-definition)
		nmap <leader>rn <Plug>(coc-rename)
		nmap <silent> gy <Plug>(coc-type-definition)
		nmap <silent> gi <Plug>(coc-implementation)
		nmap <silent> gr <Plug>(coc-references)

		" Snippets {{{
			" inoremap <silent><expr> <C-l> coc#rpc#request('doKeymap', ['snippets-expand-jump',''])
			" imap <silent><expr><C-l> \<Plug>(coc-snippets-expand)
			let g:coc_snippet_next = '<tab>'
			let g:coc_snippet_prev = '<s-tab>'
			" imap <C-j> \<Plug>(coc-snippets-expand-jump)
		" }}}

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

" WIP {{{
delfunction! PrettyUnfold

function PrettyUnfold()
let start = nvim_buf_get_mark(0, "<")
let end = nvim_buf_get_mark(0, ">")
echo start end
if start[0] != end[0]
	echom "ERROR: selection spans multiple lines"
	return
endif
let start_cursor = nvim_win_get_cursor(0)
set virtualedit=all
norm! g$
let buffer_width = virtcol(".")
echom buffer_width
set virtualedit&
let line = nvim_buf_get_lines(0, start[0]-1, end[0], 0)[0]
call nvim_win_set_cursor(0, start)
let line1 = strcharpart(line, 0, start[1])
let line2 = strcharpart(line, start[1], end[1]-start[1]+1)
let line3 = strcharpart(line, end[1]+1)
let lines = []
call add(lines, printf("%-*s", buffer_width, line1))
call add(lines, printf("	%-*s", buffer_width, line2))
call add(lines, printf("%-*s", buffer_width, line3))
let b:ns_id = nvim_create_namespace("")
call nvim_buf_set_lines(0, end[0]-1, end[0], 0, [join(lines, "")])
call nvim_win_set_cursor(0, start_cursor)
endfunction
" End WIP }}}

