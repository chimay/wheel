" vim: set ft=vim fdm=indent iskeyword&:

" Gear
"
" Generic helpers

" ---- script constants

if ! exists('s:modes_letters')
	let s:modes_letters = wheel#crystal#fetch('modes-letters')
	lockvar s:modes_letters
endif

if ! exists('s:letters_modes')
	let s:letters_modes = wheel#crystal#fetch('letters-modes')
	lockvar s:letters_modes
endif

" ---- functions

fun! wheel#gear#function (function, ...)
	" Return funcref of function string
	" Optional arguments are passed to Fun
	" If already funcref, simply return it
	let Fun = a:function
	let arguments = a:000
	let kind = type(Fun)
	if kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of wheel#gear#call is ignored
			return eval(Fun)
		else
			return function(Fun, arguments)
		endif
	elseif kind == v:t_func
		return Fun
	else
		echomsg 'wheel gear function : bad argument'
		" likely not a representation of a function
		" simply forward concatened arguments
		return [Fun] + arguments
	endif
endfun

fun! wheel#gear#call (fun, ...)
	" Call Function depicted as a Funcref or a string
	" Optional arguments are passed to Fun
	if empty(a:fun)
		return v:false
	endif
	let arguments = a:000
	let Fun = a:fun
	let kind = type(Fun)
	if kind == v:t_func
		if empty(arguments)
			" form : Fun = function('name') without argument
			return Fun()
		else
			" form : Fun = function('name') with arguments
			return call(Fun, arguments)
		endif
	elseif kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of wheel#gear#call is ignored
			return eval(Fun)
			" works, but less elegant
			"execute 'let value =' Fun
		elseif empty(arguments)
			" form : Fun = 'function' without argument
			return {Fun}()
		else
			" form : Fun = 'function' with arguments
			return call(Fun, arguments)
		endif
	else
		echomsg 'wheel gear call : bad argument'
		" likely not a representation of a function
		" simply forward concatened arguments
		return [Fun] + arguments
	endif
endfun

" ---- vim cmdline range

fun! wheel#gear#vim_cmd_range (...)
	" Return range for :[range]cmd
	" Arguments : first & last line
	if a:0 == 2
		let first = a:1
		let last = a:2
	elseif type(a:1) == v:t_list
		let first = a:1[0]
		let last = a:1[1]
	else
		echomsg 'wheel gear vim_cmd_range : bad argument format'
	endif
	let range = string(first) .. ',' .. string(last)
	return range
endfun

" ---- cursor, focus

fun! wheel#gear#restore_cursor (position, default_line = '$')
	" Restore cursor position
	let position = a:position
	let default_line = a:default_line
	if line('$') > position[1]
		call setpos('.', position)
	else
		call cursor(default_line, 1)
	endif
endfun

fun! wheel#gear#win_gotoid (iden)
	" Go to win given by iden if iden is a number
	if type(a:iden) == v:t_number
		call win_gotoid (a:iden)
	endif
endfun

" ---- misc

" used by chain#tie

fun! wheel#gear#decrease_greater(number, treshold)
	" Return number - 1 if > treshold, else return number
	if a:number > a:treshold
		return a:number - 1
	else
		return a:number
	endif
endfun
