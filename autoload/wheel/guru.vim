" vim: set ft=vim fdm=indent iskeyword&:

" Help

fun! wheel#guru#help ()
	" Inline help
	tab help wheel.txt
endfun

fun! wheel#guru#mappings ()
	" List of mappings in a dedicated buffer
	let prefix = g:wheel_config.prefix
	let command = 'map ' . prefix
	call wheel#mandala#command (command)
endfun

fun! wheel#guru#plugs ()
	" List of plugs mappings in a dedicated buffer
	call wheel#mandala#command ('map <plug>(wheel-')
endfun
