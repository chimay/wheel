" vim: set ft=vim fdm=indent iskeyword&:

" Metafun
"
" Functional helpers : functions of functions

fun! wheel#metafun#function (function, ...)
	" Return funcref of function string
	" Optional arguments are passed to Fun
	" If already funcref, simply return it
	let Fun = a:function
	let arguments = a:000
	let kind = type(Fun)
	if kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of wheel#metafun#call is ignored
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

fun! wheel#metafun#call (function, ...)
	" Call function depicted as a Funcref or a string
	" Optional arguments are passed to Fun
	if empty(a:function)
		return v:false
	endif
	let arguments = a:000
	let Fun = a:function
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
			" a:000 of wheel#metafun#call is ignored
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
