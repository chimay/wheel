" vim: ft=vim fdm=indent:

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
		if index(keys, mode) >= 0
			return s:modes_letters[mode]
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	else
		let keys = keys(s:letters_modes)
		if index(keys, mode) >= 0
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
		if index(keys, mode) >= 0
			return s:letters_modes[mode]
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	else
		let keys = keys(s:modes_letters)
		if index(keys, mode) >= 0
			return mode
		else
			echomsg 'wheel gear : argument is not a valid mode name.'
			return v:false
		endif
	endif
endfun

" Autocommands

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

" Clear

fun! wheel#gear#unmap (key, ...)
	" Unmap buffer mapping key in mode
	" If key is a list, unmap every key in it
	" If key is a dict, it has the form
	" {'normal' : [normal keys list], 'insert' : [insert keys list], ...}
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'n'
	endif
	let key = a:key
	let kind = type(key)
	if kind == v:t_string
		" maparg returns dictionary with map caracteristics
		let dict = maparg(key, mode, 0, 1)
		if ! empty(dict) && dict.buffer
			let pre = mode . 'unmap <silent> <buffer> '
			let runme = pre . key
			exe runme
		endif
	elseif kind == v:t_list
		for elem in key
			call wheel#gear#unmap(elem, mode)
		endfor
	elseif kind == v:t_dict
		" normal maps
		call wheel#gear#unmap(key.normal, 'n')
		" insert maps
		call wheel#gear#unmap(key.insert, 'i')
		" visual maps
		call wheel#gear#unmap(key.visual, 'v')
	else
		echomsg 'Wheel gear unmap : bad key format'
	endif
endfun

fun! wheel#gear#clear_autocmds (group, event)
	" Clear local autocommands in group at event
	" If event is a list, clear every event autocmds in it
	let group = a:group
	let event = a:event
	let kind = type(event)
	if kind == v:t_string
		let group_event_pattern = '#' . group . '#' . event . '#<buffer>'
		if exists(group_event_pattern)
			exe 'autocmd!' group event '<buffer>'
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
		let runme = 'let ampersands.' . optname . '=' . '&' . optname
		execute runme
	endfor
	return ampersands
endfun

fun! wheel#gear#save_maps (keysdict)
	" Save maps of keys in keysdict
	" keysdict has the form
	" {'normal' : [normal keys list], 'insert' : [insert keys list], ...}
	" Returns nested dict of the form
	" {'normal' : {'key' : map, ...}, 'insert' : {'key' : map, ...}, ...}
	let keysdict = a:keysdict
	let mapdict = {}
	" normal mode
	let mapdict.normal = {}
	for key in keysdict.normal
		let mapdict.normal[key] = maparg(key, 'n')
	endfor
	" insert mode
	let mapdict.insert = {}
	for key in keysdict.insert
		let mapdict.insert[key] = maparg(key, 'i')
	endfor
	" visual mode
	let mapdict.visual = {}
	for key in keysdict.visual
		let mapdict.visual[key] = maparg(key, 'v')
	endfor
	" return
	return mapdict
endfun

fun! wheel#gear#save_autocmds (group, events)
	" Save autocommands
	let autodict = {}
	for event in a:events
		let autodict[event] = wheel#gear#autocmds (a:group, event)
	endfor
	return autodict
endfun

" Restore

fun! wheel#gear#restore_options (optdict)
	" Restore options whose names and values are given by optdict
	for [optname, value] in items(a:optdict)
		let runme = 'let &' . optname . '=' . string(value)
		execute runme
	endfor
endfun

fun! wheel#gear#restore_maps (mapdict)
	" Restore maps
	let mapdict = a:mapdict
	for key in keys(mapdict.normal)
		if ! empty(mapdict.normal[key])
			exe 'silent! nnoremap <buffer>' key mapdict.normal[key]
		else
			exe 'silent! nunmap <buffer>' key
		endif
	endfor
	for key in keys(mapdict.insert)
		if ! empty(mapdict.insert[key])
			exe 'silent! inoremap <buffer>' key mapdict.insert[key]
		else
			exe 'silent! iunmap <buffer>' key
		endif
	endfor
	for key in keys(mapdict.visual)
		if ! empty(mapdict.visual[key])
			exe 'silent! vnoremap <buffer>' key mapdict.visual[key]
		else
			exe 'silent! vunmap <buffer>' key
		endif
	endfor
endfun

fun! wheel#gear#restore_autocmds (group, autodict)
	" Restore autocommands
	for event in keys(a:autodict)
		exe 'autocmd!' a:group event '<buffer>'
		let autocmds = a:autodict[event]
		if ! empty(autocmds)
			for autocom in autocmds
				exe 'autocmd' a:group event '<buffer>' autocom
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
