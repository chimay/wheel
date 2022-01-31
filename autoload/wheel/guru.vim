" vim: set ft=vim fdm=indent iskeyword&:

" Guru
"
" Help

fun! wheel#guru#help ()
	" Inline help
	tab help wheel.txt
endfun

fun! wheel#guru#mappings ()
	" List of mappings in a dedicated buffer
	let prefix = g:wheel_config.prefix
	let command = 'map ' .. prefix
	call wheel#mandala#command (command)
endfun

fun! wheel#guru#plugs ()
	" List of plugs mappings in a dedicated buffer
	call wheel#mandala#command ('map <plug>(wheel-')
endfun

fun! wheel#guru#autocomands ()
	" List of wheel autocommands in a dedicated buffer
	let group = input('Name of your wheel autocommand group ? ', 'wheel')
	let command = 'autocmd ' .. group
	call wheel#mandala#command (command)
endfun

" mandala local help

fun! wheel#guru#mandala ()
	" Basic help of a dedicated buffer
	echomsg 'q : quit                   | r : reload           | <M-n> : relabel buffer'
	echomsg 'H : previous layer         | <M-l> : switch layer | L : next layer'
	echomsg '<Backspace> : delete layer | <F1> : this help     | <M-F1> : local maps'
endfun

fun! wheel#guru#mandala_mappings ()
	" Local maps in a dedicated buffer
	call wheel#cylinder#recall ()
	let command = 'map <buffer>'
	call wheel#mandala#command (command)
endfun
