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
	Plug 'neoclide/coc.nvim', { 'branch': 'release' }
	Plug 'honza/vim-snippets/'
	Plug 'bling/vim-bufferline'
	Plug 'itchyny/lightline.vim'
	Plug 'scrooloose/syntastic'
	Plug 'godlygeek/tabular' 
	Plug 'plasticboy/vim-markdown'
	Plug 'mattn/emmet-vim'
	Plug 'wellle/targets.vim'
	Plug 'preservim/nerdtree'
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
    " Plug 'severin-lemaignan/vim-minimap'
	Plug 'dhruvasagar/vim-table-mode'
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

	call plug#end()
" End Plugins }}}

" Basics {{{
	filetype plugin indent on
	syntax on
	set backspace=indent,eol,start " allow backspacing across lines
	set complete=.,w,b,u,t,i,kspell " Add spelling dictionary to completion only if spellcheck is on
	" Indentation Settings (Tabs only)
	if !exists("b:indent_config") && !exists("b:default_indent_config")
		set noexpandtab tabstop=4 shiftwidth=4 softtabstop=0 smarttab
	endif
	" Toggle mouse support with \m
	nnoremap <Leader>mm :let &mouse = ( &mouse == "" ? "a" : "" )<CR>
    set mouse=a
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
		autocmd BufRead *.rs DefaultSpacesOnly 4
		autocmd BufRead *.c,*.h,*.cpp,*.ino DefaultTabsOnly 8
		autocmd BufRead Makefile,.bashrc,.vimrc,*.vim DefaultTabsOnly 4
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
	nnoremap <silent> <F8> :TagbarToggle<CR>

	" F10 to clear highlight
	nnoremap <silent> <F10> :nohl<CR>

	" Leader-rh to toggle rust-analyzer type hints
	nnoremap <silent> <Leader>rh :CocCommand rust-analyzer.toggleInlayHints<CR>
	" Leader-j to join lines with rust-analyzer
	nnoremap <silent> <Leader>j :CocCommand rust-analyzer.joinLines<CR>
	vnoremap <silent> <Leader>j :CocCommand rust-analyzer.joinLines<CR>

	" Leader-w to toggle wrapping
	nnoremap <silent> <Leader>w :set wrap!<CR>

	" Leader-hll to highlight current line
	nnoremap <silent> <Leader>hll :exe "let m = matchadd('ColorColumn', '\\%" . line('.') . "l')"<CR>
	nnoremap <silent> <Leader>hlc :call clearmatches()<CR>

	" Convenience for navigating the quickfix list (i think?)
	nnoremap <silent> ]c :cnext<CR>
	nnoremap <silent> [c :cprev<CR>
	nnoremap <silent> <Leader>[c :cfirst<CR>
	nnoremap <silent> <Leader>]c :clast<CR>
    " Toggle quickfix list {{{
		nnoremap <silent> <F9> :CToggle<CR>
        command! -nargs=0 CToggle call s:ToggleCList()
        function! s:ToggleCList()
            if empty(filter(getwininfo(), 'v:val.quickfix'))
                copen
            else
                cclose
            endif
        endfunction
    " End Toggle quickfix list }}}

	" Convenience for navigating the location list (i think?)
	nnoremap <silent> ]l :lnext<CR>
	nnoremap <silent> [l :lprev<CR>
	nnoremap <silent> <Leader>[l :lfirst<CR>
	nnoremap <silent> <Leader>]l :llast<CR>

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
		nnoremap <silent> <Leader>[b :bfirst!<CR>
		nnoremap <silent> <Leader>]b :blast!<CR>
		" Close buffer
		nnoremap <silent> -b :Bclose<CR>
		command! -bang -complete=buffer -nargs=? Bclose call s:Bclose(<q-bang>, <q-args>)
		function! s:Bclose(bang, buffer)
			if empty(a:buffer)
				let btarget = bufnr('%')
			elseif a:buiffer =~ '^\d\+$'
				let btarget = bufnr(str2nr(a:buffer))
			else
				let btarget = bufnr(a:buffer)
			endif
			if btarget < 0
				echomsg 'No matching buffer for '.a:buffer
				return
			endif
			if empty(a:bang) && getbufvar(btarget, '&modified')
				echomsg 'No write since last change for buffer '.btarget
				return
			endif
			let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
			let wcurrent = winnr()
			for w in wnums
				execute w.'wincmd w'
				let prevbuf = bufnr('#')
				if prevbuf > 0 && buflisted(prevbuf) && prevbuf != btarget
					buffer #
				else
					bprevious
				endif
				if btarget == bufnr('%')
					let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
					let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
					let bjump = (bhidden + blisted + [-1])[0]
					if bjump > 0
						execute 'buffer '.bjump
					else
						execute 'enew'.a:bang
					endif
				endif
			endfor
			execute 'bdelete'.a:bang.' '.btarget
			execute wcurrent.'wincmd w'
		endfunction
	" End Buffers }}}

	" Tabs {{{
		nnoremap <silent> ]t :tabnext<CR>
		nnoremap <silent> [t :tabprevious<CR>
		nnoremap <silent> <Leader>[t :tabfirst<CR>
		nnoremap <silent> <Leader>]t :tablast<CR>
		nnoremap <silent> -t :tabclose<CR>
	" End Tabs }}}

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
	command! Help :tab help | :tabonly

    " Todo List {{{
        command! -nargs=0 Todo call s:LoadTodoList()
        function! s:LoadTodoList()
            " Nabbed from https://stackoverflow.com/a/271709
            let all = range(1, bufnr('$'))
            let res = []
            for b in all
                if buflisted(b)
                    call add(res, bufname(b))
                endif
            endfor
            " echom string(res)
            exec 'vimgrep /TODO/ '.join(res, ' ')
        endfunction
    " End Todo List }}}

	" Indent Config {{{
		command! -nargs=? -complete=custom,s:IndentArgs SpacesOnly call s:IndentConfig(1, <q-args>)
		command! -nargs=? -complete=custom,s:IndentArgs TabsOnly call s:IndentConfig(0, <q-args>)
		command! -nargs=? -complete=custom,s:IndentArgs DefaultSpacesOnly call s:DefaultIndentConfig(1, <q-args>)
		command! -nargs=? -complete=custom,s:IndentArgs DefaultTabsOnly call s:DefaultIndentConfig(0, <q-args>)
		command! -nargs=? -complete=custom,s:IndentArgs DefaultIndent call s:ResetDefaultIndent()

		function! s:ResetDefaultIndent()
			if exists("b:indent_config") && exists("b:default_indent_config")
				unlet b:indent_config
				call s:IndentConfig(b:default_indent_config['mode'], b:default_indent_config['width'])
			endif
		endfunction

		function! s:DefaultIndentConfig(mode, width)
			let b:default_indent_config = {'mode': a:mode, 'width': a:width}
			if !exists("b:indent_config")
				call s:IndentConfig(b:default_indent_config['mode'], b:default_indent_config['width'])
			else
				call s:IndentConfig(b:indent_config['mode'], b:indent_config['width'])
			endif
		endfunction

		function! s:IndentConfig(mode, width)
			let b:indent_config = {'mode': a:mode, 'width': a:width}
			let l:width = str2nr(a:width)
			if a:mode
				set expandtab
				if l:width != 0
					let &tabstop = l:width
					let &shiftwidth = l:width
				endif
				" echom "Indent Mode: " . &shiftwidth . " spaces"
			else
				set noexpandtab
				if l:width != 0
					let &tabstop = l:width
					let &shiftwidth = l:width
				endif
				" echom "Indent Mode: " . &tabstop . "-wide tabs"
			endif
		endfunction

		function! s:IndentArgs(ArgLead, CmdLine, CursorPos)
			let mlist = matchlist(a:CmdLine, '^\(Tabs\|Spaces\)Only *$')
			if len(mlist) >= 2
				if mlist[1] == "Tabs"
					return &tabstop
				elseif mlist[1] == "Spaces"
					return &shiftwidth
				endif
			endif
			return ""
		endfunction
	" End Indent Config }}}

	" Per-Buffer g:tmpl_project {{{
		function! SetBufferProj()
			" echom '% = ' . expand('%')
			" echom '%:p = ' . expand('%:p')
			" echom '%:p:h = ' . expand('%:p:h')
			" echom '%:p:h:t = ' . expand('%:p:h:t')
			let l:cargo_toml_path = expand('%:p:h') . "/Cargo.toml"
			" echom '%:p:h/Cargo.toml = ' . l:cargo_toml_path
			if filereadable(l:cargo_toml_path)
				let b:project_name = expand('%:p:h:t')
				let g:tmpl_project = b:project_name
			endif
		endfunction
		function! SetTmplProj()
			if exists("b:project_name")
				let g:tmpl_project = b:project_name
			elseif exists("g:tmpl_project")
				unlet g:tmpl_project
			endif
		endfunction
		" function! UnsetTmplProj()
		" 	unlet g:tmpl_project
		" endfunction
		augroup TmplProjControls
			autocmd!
			autocmd BufNewFile,BufReadPost,BufFilePost,FileReadPost *
					\ call SetBufferProj()
			autocmd BufEnter,BufWinEnter *
				\ call SetTmplProj()
		augroup END
	" End Per-Buffer g:tmpl_project }}}

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

    " Make iamcco/markdown-preview.nvim use firefox
    let g:mkdp_browser='firefox'

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
        nmap <leader>a :CocAction<CR>

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

