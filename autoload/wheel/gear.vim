" vim: set ft=vim fdm=indent iskeyword&:

" Generic helpers

" Script constants

if ! exists('s:modes_letters')
	let s:modes_letters = wheel#crystal#fetch('modes-letters')
	lockvar s:modes_letters
endif

if ! exists('s:letters_modes')
	let s:letters_modes = wheel#crystal#fetch('letters-modes')
	lockvar s:letters_modes
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

fun! wheel#gear#function (function, ...)
	" Return funcref of function string
	" Optional arguments are passed to Fun
	" If already funcref, simply return it
	let Fun = a:function
	let arg = a:000
	let kind = type(Fun)
	if kind == v:t_string
		return function(Fun, arg)
	elseif kind == v:t_func
		return Fun
	else
		echomsg 'wheel gear function : bad argument'
	endif
endfun

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
			"execute 'let value =' Fun
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

" Vim cmdline range

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

" Directory

fun! wheel#gear#relative_path (...)
	" Return path of filename relative to current directory
	" Optional argument :
	"   - filename
	"   - default : current filename
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%:p')
	endif
	let directory = '\m^' .. getcwd() .. '/'
	let filename = substitute(filename, directory, '', '')
	return filename
endfun

fun! wheel#gear#project_root (markers)
	" Change local directory to root of project
	" where current buffer belongs
	if type(a:markers) == v:t_string
		let markers = [a:markers]
	elseif type(a:markers) == v:t_list
		let markers = a:markers
	else
		echomsg 'wheel project root : argument must be either a string or a list.'
	endif
	let dir = expand('%:p:h')
	execute 'lcd' dir
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

" Map modes

fun! wheel#gear#short_mode (mode)
	" Returns short one letter name of mode
	let mode = a:mode
	if empty(mode)
		echomsg 'wheel gear short mode : empty argument'
		return v:false
	endif
	if len(mode) > 1
		let keys = keys(s:modes_letters)
		if wheel#chain#is_inside(mode, keys)
			return s:modes_letters[mode]
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	else
		let keys = keys(s:letters_modes)
		if wheel#chain#is_inside(mode, keys)
			return mode
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	endif
endfun

fun! wheel#gear#long_mode (mode)
	" Returns long name of mode
	let mode = a:mode
	if empty(mode)
		echomsg 'wheel gear long mode : empty argument'
		return v:false
	endif
	if len(mode) == 1
		let keys = keys(s:letters_modes)
		if wheel#chain#is_inside(mode, keys)
			return s:letters_modes[mode]
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	else
		let keys = keys(s:modes_letters)
		if wheel#chain#is_inside(mode, keys)
			return mode
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	endif
endfun

" Autocommands

" Clear

fun! wheel#gear#unmap (key, mode = 'normal')
	" Unmap buffer local mapping key in mode
	" If key is a list, unmap every key in it
	" If key is a dict, it has the form
	" {'normal' : [normal keys list], 'insert' : [insert keys list], ...}
	let key = a:key
	let mode = a:mode
	let kind = type(key)
	if kind == v:t_string
		" maparg returns dictionary with map caracteristics
		let dict = maparg(key, mode, v:false, v:true)
		let letter = wheel#gear#short_mode (mode)
		if ! empty(dict) && dict.buffer
			execute 'silent!' letter .. 'unmap <buffer>' key
		endif
	elseif kind == v:t_list
		for elem in key
			call wheel#gear#unmap(elem, mode)
		endfor
	elseif kind == v:t_dict
		if a:0 > 0
			echomsg 'wheel unmap : if key is a dict, optional argument is meaningless'
			return v:false
		endif
		for mode in keys(key)
			call wheel#gear#unmap(key[mode], mode)
		endfor
	else
		echomsg 'wheel gear unmap : bad key format'
	endif
endfun

fun! wheel#gear#clear_autocmds (group, event)
	" Clear buffer local autocommands in group at event
	" If event is a list, clear every event autocmds in it
	let group = a:group
	let event = a:event
	let kind = type(event)
	if kind == v:t_string
		let group_event_pattern = '#' .. group .. '#' .. event .. '#<buffer>'
		if exists(group_event_pattern)
			execute 'autocmd!' group event '<buffer>'
		endif
	elseif kind == v:t_list
		for elem in event
			call wheel#gear#clear_autocmds (group, elem)
		endfor
	endif
endfun

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

" Save

fun! wheel#gear#save_options (optlist)
	" Return dictionary with options whose names are in optlist
	let ampersands = {}
	for optname in a:optlist
		let runme = 'let ampersands.' .. optname .. '=' .. '&' .. optname
		execute runme
	endfor
	return ampersands
endfun

fun! wheel#gear#save_maps (keysdict)
	" Save buffer local maps of keys in keysdict
	" keysdict has the form
	" {'normal' : [normal keys list], 'insert' : [insert keys list], ...}
	" Returns nested dict of the form
	" {'normal' : {'key' : rhs, ...}, 'insert' : {'key' : rhs, ...}, ...}
	let keysdict = a:keysdict
	let mapdict = {}
	for mode in keys(keysdict)
		let modename = wheel#gear#long_mode (mode)
		let letter = wheel#gear#short_mode (mode)
		let modemaps = {}
		for key in keysdict[mode]
			let maparg = maparg(key, letter, v:false, v:true)
			if empty(maparg)
				let modemaps[key] = ''
				continue
			endif
			if maparg.buffer == 1
				let modemaps[key] = maparg.rhs
			else
				let modemaps[key] = ''
			endif
		endfor
		let mapdict[modename] = modemaps
	endfor
	return mapdict
endfun

fun! wheel#gear#save_autocmds (group, events)
	" Save buffer local autocommands
	let kind = type(a:events)
	if kind == v:t_string
		let group = a:group
		let event = a:events
		let buffer = '<buffer=' .. bufnr('%') ..  '>'
		let runme = 'autocmd ' .. group .. ' ' .. event .. ' ' .. buffer
		let output = execute(runme)
		let lines = split(output, '\n')
		eval lines->filter({ _, val -> val !~ '\m^--- .* ---$' })
		eval lines->filter({ _, val -> val !~ '\m^' .. group })
		eval lines->filter({ _, val -> val !~ '\m' .. '<buffer[^>]*>' })
		if empty(lines)
			return []
		endif
		let autocmds = []
		for elem in lines
			let elem = substitute(elem, '\m^\s*', '', '')
			call add(autocmds, elem)
		endfor
		return autocmds
	elseif kind == v:t_list
		let autodict = {}
		for event in a:events
			let autodict[event] = wheel#gear#save_autocmds (a:group, event)
		endfor
		return autodict
	endif
endfun

" Restore

fun! wheel#gear#restore_options (optdict)
	" Restore options whose names and values are given by optdict
	for [optname, value] in items(a:optdict)
		let runme = 'let &' .. optname .. '=' .. string(value)
		execute runme
	endfor
endfun

fun! wheel#gear#restore_maps (mapdict)
	" Restore buffer local maps
	" mapdict has the form
	" {'normal' : {'key' : maparg, ...}, 'insert' : {'key' : maparg, ...}, ...}
	" like the one returned by wheel#gear#save_maps
	let mapdict = a:mapdict
	for mode in keys(mapdict)
		let modename = wheel#gear#long_mode (mode)
		let letter = wheel#gear#short_mode (mode)
		let modemaps = mapdict[mode]
		for key in keys(modemaps)
			if ! empty(modemaps[key])
				execute 'silent!' letter .. 'noremap <buffer>' key modemaps[key]
			else
				execute 'silent!' letter .. 'unmap <buffer>' key
			endif
		endfor
	endfor
endfun

fun! wheel#gear#restore_autocmds (group, autodict)
	" Restore buffer local autocommands
	for event in keys(a:autodict)
		" empty group event
		execute 'autocmd!' a:group event '<buffer>'
		" restore
		let autocmds = a:autodict[event]
		if ! empty(autocmds)
			for autocom in autocmds
				execute 'autocmd' a:group event '<buffer>' autocom
			endfor
		endif
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
