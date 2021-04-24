" vim: ft=vim fdm=indent:

" Generic helpers

" Script constants

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

" Rotating

fun! wheel#gear#circular_plus (index, length)
	" Rotate/increase index with modulo
	return (a:index + 1) % a:length
endfun

fun! wheel#gear#circular_minus (index, length)
	" Rotate/decrease index with modulo
	let index = (a:index - 1) % a:length
	if index < 0
		let index += a:length
	endif
	return index
endfun

" Functions

fun! wheel#gear#call (fun, ...)
	" Call Function depicted as a Funcref or a string
	" Optional arguments are passed to Fun
	if empty(a:fun)
		return v:false
	endif
	let arg = a:000
	let Fun = a:fun
	let kind = type(Fun)
	if kind == v:t_func
		if empty(arg)
			" form : Fun = function('name') without argument
			return Fun()
		else
			" form : Fun = function('name') with arguments
			return call(Fun, arg)
		endif
	elseif kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of wheel#gear#call is ignored
			return eval(Fun)
			" works, but less elegant
			"exe 'let value =' Fun
		elseif empty(arg)
			" form : Fun = 'function' without argument
			return {Fun}()
		else
			" form : Fun = 'function' with arguments
			return call(Fun, arg)
		endif
	else
		" likely not a representation of a function
		" simply forward concatened arguments
		return [Fun] + arg
	endif
endfun

" Directory

fun! wheel#gear#project_root (markers)
	" Change local directory to root of project
	" where current buffer belongs
	if type(a:markers) == v:t_string
		let markers = [a:markers]
	elseif type(a:markers) == v:t_list
		let markers = a:markers
	else
		echomsg 'Wheel Project root : argument must be either a string or a list.'
	endif
	let dir = expand('%:p:h')
	exe 'lcd' dir
	let found = 0
	while v:true
		for mark in markers
			if filereadable(mark) || isdirectory(mark)
				let found = 1
				break
			endif
		endfor
		if found || dir ==# '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun

" Cursor

fun! wheel#gear#restore_cursor (position, ...)
	" Restore cursor position
	if a:0 > 0
		let default = a:1
	else
		let default = '$'
	endif
	let position = a:position
	if line('$') > position[1]
		call setpos('.', position)
	else
		call cursor(default, 1)
	endif
endfun

fun! wheel#gear#win_gotoid (iden)
	" Go to win given by iden if iden is a number
	if type(a:iden) == v:t_number
		call win_gotoid (a:iden)
	endif
endfun

" Clear, save, restore

fun! wheel#gear#unlet (variable)
	" Unlet variable named variable
	" If var is a list, unlet every variable in it
	let variable = a:variable
	let kind = type(variable)
	if kind == v:t_string
		if exists(variable)
			unlet {variable}
		endif
	elseif kind == v:t_list
		for elem in variable
			call wheel#gear#unlet (elem)
		endfor
	endif
endfun

fun! wheel#gear#unmap (key, ...)
	" Unmap buffer mapping key in mode
	" If key is a list, unmap every key in it
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'n'
	endif
	let key = a:key
	let typekey = type(key)
	if typekey == v:t_string
		" dictionary with map caracteristics
		let dict = maparg(key, mode, 0, 1)
		if ! empty(dict) && dict.buffer
			let pre = mode . 'unmap <silent> <buffer> '
			let runme = pre . key
			exe runme
		endif
	elseif typekey == v:t_list
		for elem in key
			call wheel#gear#unmap(elem, mode)
		endfor
	else
		echomsg 'Wheel gear unmap : bad key format'
	endif
endfun

fun! wheel#gear#autocmds (group, event)
	" Return a list of buffer local autocmds of group at event
	let runme = 'autocmd ' . a:group . ' ' . a:event . ' <buffer>'
	let output = execute(runme)
	let lines = split(output, '\n')
	call filter(lines, {_,v -> v !~ '\m^--- .* ---$'})
	call filter(lines, {_,v -> v !~ '\m^' . s:mandala_autocmds_group})
	if empty(lines)
		return []
	endif
	let autocmds = []
	let here = v:false
	for elem in lines
		if elem =~ '<buffer=[^>]\+>'
			if elem =~ '\m<buffer=' . bufnr('%') . '>'
				let here = v:true
			else
				let here = v:false
			endif
		else
			if here
				let elem = substitute(elem, '\m^\s*', '', '')
				call add(autocmds, elem)
			endif
		endif
	endfor
	return autocmds
endfun

fun! wheel#gear#save_options (optlist)
	" Return dictionary with options whose names are in optlist
	let ampersands = {}
	for optname in a:optlist
		let runme = 'let ampersands.' . optname . '=' . '&' . optname
		execute runme
	endfor
	return ampersands
endfun

fun! wheel#gear#restore_options (optdict)
	" Restore options whose names and values are given by optdict
	for [optname, value] in items(a:optdict)
		let runme = 'let &' . optname . '=' . string(value)
		execute runme
	endfor
endfun

" Misc

" Used by chain#tie

fun! wheel#gear#decrease_greater(number, treshold)
	" Return number - 1 if > treshold, else return number
	if a:number > a:treshold
		return a:number - 1
	else
		return a:number
	endif
endfun
