" vim: set ft=vim fdm=indent iskeyword&:

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
	" List of plugs mappings in a dedicated buffer
	let group = input('Name of your wheel autocommand group ? ', 'wheel')
	let command = 'autocmd ' .. group
	call wheel#mandala#command (command)
endfun

" mandala local help

fun! wheel#guru#mandala ()
	" Basic local maps in mandalas
	echomsg 'q : quit           | <M-n> : rename      |'
	echomsg 'H : previous layer | <M-l> : switch leaf | L : next leaf'
	echomsg '<F1> : this help   | <F2> : local maps   |'
endfun

fun! wheel#guru#mandala_mappings ()
	" List of mappings in a dedicated buffer
	let command = 'map <buffer>'
	call wheel#mandala#command (command)
endfun

