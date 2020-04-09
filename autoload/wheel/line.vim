" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element

" Helpers

fun! wheel#line#coordin ()
	" Return coordin of line in treeish buffer
	let cursor_line = getline('.')
	let cursor_list = split(cursor_line, ' ')
	if empty(cursor_line)
		echomsg 'Wheel line path : empty line'
		return
	endif
	if foldlevel('.') == 2 && len(cursor_list) == 1
		let location = getline('.')
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line, ' ')
		let circle = list[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus, circle, location]
	elseif foldlevel('.') == 2
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line, ' ')
		let circle = list[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus, circle]
	elseif foldlevel('.') == 1
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus]
	elseif foldlevel('.') == 0
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let coordin = line
	else
		echomsg 'Wheel line coordin : wrong fold level'
	endif
	return coordin
endfun

fun! wheel#line#toggle ()
	" Toggle selection of current line
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
	let coordin = wheel#line#coordin ()
	if empty(coordin)
		return
	endif
	if line !~ '\m^\* '
		let name = line
	else
		let name = substitute(line, '\m^\* ', '', '')
	endif
	let index = index(b:wheel_selected, name)
	if index < 0
		call add(b:wheel_selected, name)
		let selected_line = substitute(line, '\m^', '* ', '')
		call setline('.', selected_line)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = selected_line
	else
		call remove(b:wheel_selected, index)
		call setline('.', name)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = name
	endif
endfun

fun! wheel#line#filter ()
	" Return lines matching words of first line
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	let linelist = copy(b:wheel_lines)
	let first = getline(1)
	let wordlist = split(first)
	if empty(wordlist)
		return linelist
	endif
	call wheel#scroll#record(first)
	let Matches = function('wheel#gear#filter', [wordlist])
	let candidates = filter(linelist, Matches)
	" two times : cleans a level each time
	let filtered = wheel#gear#fold_filter(wordlist, candidates)
	let filtered = wheel#gear#fold_filter(wordlist, filtered)
	" Return
	return filtered
endfu

fun! wheel#line#target (target)
	" Open target tab/win before* switching
	let target = a:target
	if target == 'tab'
		tabnew
	elseif target == 'horizontal_split'
		split
	elseif target == 'vertical_split'
		vsplit
	endif
endfu

" Switch

fun! wheel#line#switch (dict)
	" Switch to element(s) on current or selected line(s)
	" dict keys :
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	" - close : whether to close special buffer
	" - action : switch function or name of switch function
	let dict = copy(a:dict)
	if has_key(dict, 'level')
		let level = dict.level
	else
		let level = 'none'
	endif
	if has_key(dict, 'target')
		let target = dict.target
	else
		let target = 'current'
		let dict.target = target
	endif
	if has_key(dict, 'close')
		let close = dict.close
	else
		let close = 1
	endif
	if has_key(dict, 'action')
		let Fun = dict.action
	else
		let Fun = 'wheel#line#name'
	endif
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		let selected = [wheel#line#coordin ()]
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'Wheel line switch : bad format for b:wheel_selected'
	endif
	if close
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	if type(Fun) == v:t_func
		if target != 'current'
			for elem in selected
				let dict.selected = elem
				call Fun (dict)
			endfor
		else
			let dict.selected = selected[0]
			call Fun (dict)
		endif
	elseif type(Fun) == v:t_string
		if target != 'current'
			for elem in selected
				let dict.selected = elem
				call {Fun} (dict)
			endfor
		else
			let dict.selected = selected[0]
			call {Fun} (dict)
		endif
	endif
endfun

fun! wheel#line#name (dict)
	" Switch to dict.selected by name
	" dict keys :
	" - selected : where to switch
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	call wheel#line#target (a:dict.target)
	call wheel#vortex#switch(a:dict.level, a:dict.selected)
endfun

fun! wheel#line#helix (dict)
	" Switch to dict.selected = torus > circle > location
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let list = split(a:dict.selected, ' ')
	if len(list) < 5
		echomsg 'Helix line is too short'
		return
	endif
	let coordin = [list[0], list[2], list[4]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#line#grid (dict)
	" Switch to dict.selected = torus > circle
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let list = split(a:dict.selected, ' ')
	if len(list) < 3
		echomsg 'Grid line is too short'
		return
	endif
	let coordin = [list[0], list[2]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#tune('torus', coordin[0])
	call wheel#vortex#tune('circle', coordin[1])
	call wheel#vortex#jump ()
endfun

fun! wheel#line#tree (...)
	" Switch to helix tree element in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let coordin = wheel#line#coordin ()
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	let length = len(coordin)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#tune('torus', coordin[0])
		call wheel#vortex#tune('circle', coordin[1])
	elseif length == 1
		call wheel#vortex#tune('torus', coordin[0])
	endif
	call wheel#vortex#jump ()
endfun

fun! wheel#line#history (dict)
	" Switch to dict.selected history location
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let list = split(a:dict.selected, ' ')
	if len(list) < 11
		echomsg 'History line is too short'
		return
	endif
	let coordin = [list[6], list[8], list[10]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump ()
endfun
