" I think these two enable true color in terminal,, or something
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

set background=dark
set noshowmode " Dont show --INSERT-- --NORMAL-- etc in the command line,, we have it in the statusline
set guifont=Fira\ Code\ Light:h19

" \bg to toggle between light and dark background
nnoremap <silent> <Leader>bg :do User ToggleBackground<CR>

" Gruvbox {{{
	" https://github.com/morhetz/gruvbox/wiki/Configuration
	let g:gruvbox_bold = 1
	let g:gruvbox_underline = 1
	let g:gruvbox_italic = 0 " italics and ligatures do not mix
	let g:gruvbox_undercurl = 1
	let g:gruvbox_termcolors = 256
	let g:gruvbox_contrast_dark = "soft"
	let g:gruvbox_contrast_light = "medium"
	let g:gruvbox_italicize_comments = 0
	let g:gruvbox_invert_selection = 0
	colorscheme gruvbox
" End Gruvbox }}}

" Bufferline {{{

let g:bufferline_echo = 0
let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_modified = '+'
let g:bufferline_show_bufnr = 0
let g:bufferline_rotate = 1
let g:bufferline_fixed_index =  1
let g:bufferline_fname_mod = ':t'

" End Bufferline }}}

" Lightline {{{
let g:lightline  = {
	\	'colorscheme': 'gruvbox',
	\	'enable': { 'statusline': 1, 'tabline': 0 },
	\	'active': {
	\		'left': [
	\			[ 'mode', 'paste' ],
	\			[ 'fugitive' ],
	\			[ 'readonly', 'bufferline', 'modified' ],
	\		],
	\		'right': [
	\			[ 'lineinfo' ], [ 'percent' ],
	\			[ 'fileencoding', 'filetype'],
	\		],
	\	},
	\	'inactive': {
	\		'left': [['filename']],
	\		'right': [['lineinfo'], ['percent']],
	\	},
	\	'component': {
	\		'bufferline': '%{bufferline#refresh_status()}%{g:bufferline_status_info.before . g:bufferline_status_info.current . g:bufferline_status_info.after}',
	\	},
	\	'component_function': {
	\		'gitstatus': 'FugitiveStatusline',
	\		'gitbranch': 'FugitiveHead',
	\		'fugitive': 'LightlineFugitive',
	\	},
	\	'separator': { 'left': '', 'right': '' },
	\	'subseparator': { 'left': '', 'right': '' }
	\}
" End Lightline }}}

" Commands {{{
function! LightlineFugitive()
	if exists('*FugitiveHead')
		let branch = FugitiveHead()
		return branch !=# '' ? ''.branch : ''
	endif
	return ''
endfunction
function! s:lightline_reload()
	source $HOME/.vim/plugged/gruvbox/autoload/lightline/colorscheme/gruvbox.vim
	call lightline#init()
	call lightline#colorscheme()
	call lightline#update()
endfunction
function! LoadDict()
	let startpos = winsaveview()
	let y = search("	\	},", "nw")
	if y == 0
		silent execute 'normal! /" End Lightline'..' }}}mo/" Lightline'..' {{{V`o:s/	\\\([	}]\)/	\1/'
	endif
	nohl
	call winrestview(startpos)
endfunction
function! SaveDict()
	let startpos = winsaveview()
	let y = search("	\	},", "nw")
	if y != 0
		silent execute 'normal! /" End Lightline'..' }}}mo/" Lightline'..' {{{V`o:s/	\([	}]\)/	\\\1/'
	endif
	nohl
	call winrestview(startpos)
endfunction
augroup ThemeControls
	autocmd!
	autocmd BufWritePost,TextChanged,TextChangedI *
		\ call lightline#update()

	autocmd User ToggleBackground
		\ let &background = ( &background == "dark"? "light" : "dark" ) |
		\ call s:lightline_reload()

	autocmd BufWritePre .vim/theme.vim
		\ call SaveDict()

	autocmd BufWinEnter,BufWritePost .vim/theme.vim
		\ call LoadDict()

	" nnoremap <Leader>f1 :'g,'hs/	\\	/		/<CR>
	" nnoremap <Leader>f2 :'g,'hs/^		/	\\	/<CR>
augroup END
" End Commands }}}
