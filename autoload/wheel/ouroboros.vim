" vim: set ft=vim fdm=indent iskeyword&:

" Ouroboros : clear, save & restore
"
" Manages :
"
"   - variables
"   - maps
"   - autocommands

" other names ideas for this file :
"
" caduceus

" ---- script constants

if ! exists('s:modes_letters')
	let s:modes_letters = wheel#crystal#fetch('modes-letters')
	lockvar s:modes_letters
endif

if ! exists('s:letters_modes')
	let s:letters_modes = wheel#crystal#fetch('letters-modes')
	lockvar s:letters_modes
endif

" ---- map modes

fun! wheel#ouroboros#short_mode (mode)
	" Returns short one letter name of mode
	" normal -> n
	" insert -> i
	" visual -> v
	" ...
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
			echomsg 'wheel gear : argument is not a valid mode name'
			return v:false
		endif
	endif
	let keys = keys(s:letters_modes)
	if wheel#chain#is_inside(mode, keys)
		return mode
	else
		echomsg 'wheel gear : argument is not a valid mode name'
		return v:false
	endif
endfun

fun! wheel#ouroboros#long_mode (mode)
	" Returns long name of mode
	" n -> normal
	" i -> insert
	" v -> visual
	" ...
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
			echomsg 'wheel gear : argument is not a valid mode name'
			return v:false
		endif
	endif
	let keys = keys(s:modes_letters)
	if wheel#chain#is_inside(mode, keys)
		return mode
	else
		echomsg 'wheel gear : argument is not a valid mode name'
		return v:false
	endif
endif
endfun

" ---- clear

fun! wheel#ouroboros#unmap (key, mode = 'normal')
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
		let letter = wheel#ouroboros#short_mode (mode)
		if ! empty(dict) && dict.buffer
			execute 'silent!' letter .. 'unmap <buffer>' key
		endif
	elseif kind == v:t_list
		for elem in key
			call wheel#ouroboros#unmap(elem, mode)
		endfor
	elseif kind == v:t_dict
		if a:0 > 0
			echomsg 'wheel unmap : if key is a dict, optional argument is meaningless'
			return v:false
		endif
		for mode in keys(key)
			call wheel#ouroboros#unmap(key[mode], mode)
		endfor
	else
		echomsg 'wheel gear unmap : bad key format'
	endif
endfun

fun! wheel#ouroboros#clear_autocmds (group, event)
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
			call wheel#ouroboros#clear_autocmds (group, elem)
		endfor
	endif
endfun

fun! wheel#ouroboros#unlet (variable)
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
			call wheel#ouroboros#unlet (elem)
		endfor
	endif
endfun

" ---- save

fun! wheel#ouroboros#save_options (optlist)
	" Return dictionary with options whose names are in optlist
	let ampersands = {}
	for optname in a:optlist
		let runme = 'let ampersands.' .. optname .. '=' .. '&l:' .. optname
		execute runme
	endfor
	return ampersands
endfun

fun! wheel#ouroboros#save_maps (keysdict)
	" Save buffer local maps of keys in keysdict
	" keysdict has the form
	" {'normal' : [normal keys list], 'insert' : [insert keys list], ...}
	" Returns nested dict of the form
	" {'normal' : {'key' : rhs, ...}, 'insert' : {'key' : rhs, ...}, ...}
	let keysdict = a:keysdict
	let mapdict = {}
	for mode in keys(keysdict)
		let modename = wheel#ouroboros#long_mode (mode)
		let letter = wheel#ouroboros#short_mode (mode)
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

fun! wheel#ouroboros#save_autocmds (group, events)
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
			eval autocmds->add(elem)
		endfor
		return autocmds
	elseif kind == v:t_list
		let autodict = {}
		for event in a:events
			let autodict[event] = wheel#ouroboros#save_autocmds (a:group, event)
		endfor
		return autodict
	endif
endfun

" ---- restore

fun! wheel#ouroboros#restore_options (optdict)
	" Restore options whose names and values are given by optdict
	for [optname, value] in items(a:optdict)
		let runme = 'let &l:' .. optname .. '=' .. string(value)
		execute runme
	endfor
endfun

fun! wheel#ouroboros#restore_maps (mapdict)
	" Restore buffer local maps
	" mapdict has the form
	" {'normal' : {'key' : maparg, ...}, 'insert' : {'key' : maparg, ...}, ...}
	" like the one returned by wheel#ouroboros#save_maps
	let mapdict = a:mapdict
	for mode in keys(mapdict)
		let modename = wheel#ouroboros#long_mode (mode)
		let letter = wheel#ouroboros#short_mode (mode)
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

fun! wheel#ouroboros#restore_autocmds (group, autodict)
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
