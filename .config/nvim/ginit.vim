if has("gui_running")
	colorscheme solarized_nvimqt " B)
	set guifont=Fira\ Code\ Light:h18 " set font
	let $NVIM_TUI_ENABLE_TRUE_COLOR=1
	" Make comments not italic (it breaks firacode)
	highlight Comment gui=none
	set background=dark " set to light if u want?? but light mode sux lul
endif
