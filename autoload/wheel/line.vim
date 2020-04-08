" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element

" Helpers

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

fun! wheel#line#toggle ()
	" Toggle selection of current line
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
	let line = getline('.')
	if empty(line)
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

" Folds in treeish buffers

fun! wheel#line#fold_coordin ()
	" Return coordin of line in treeish buffer
	let cursor_line = getline('.')
	let cursor_list = split(cursor_line, ' ')
	if empty(cursor_line)
		echomsg 'Wheel line fold_coordin : empty line'
		return
	endif
	if foldlevel('.') == 2 && len(cursor_list) == 1
		let location = getline('.')
		normal! [z
		let line = getline('.')
		let list = split(line, ' ')
		let circle = list[0]
		normal! [z
		let line = getline('.')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus, circle, location]
	elseif foldlevel('.') == 2
		let line = getline('.')
		let list = split(line, ' ')
		let circle = list[0]
		normal! [z
		let line = getline('.')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus, circle]
	elseif foldlevel('.') == 1
		let line = getline('.')
		let list = split(line, ' ')
		let torus = list[0]
		let coordin = [torus]
	endif
	return coordin
endfun

" Switch

fun! wheel#line#switch (level, ...)
	" Switch to element(s) on current or selected line(s)
	" level may be 'torus', 'circle' or 'location'
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		let selected = getline('.')
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'Wheel line switch : bad format for b:wheel_selected'
	endif
	let level = a:level
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let target = 'current'
	if a:0 > 1
		let target = a:2
	endif
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#line#select_switch (level, selected, target)
endfun

fun! wheel#line#select_switch (level, selected, target)
	" Switch to selected element(s)
	" level may be 'torus', 'circle' or 'location'
	let level = a:level
	let selected = a:selected
	let target = a:target
	if type(selected) == v:t_string
		if target == 'tab'
			tabnew
		elseif target == 'horizontal_split'
			split
		elseif target == 'vertical_split'
			vsplit
		endif
		call wheel#vortex#switch(level, selected)
	elseif type(selected) == v:t_list
		if target != 'current'
			for elem in selected
				call wheel#line#select_switch (level, elem, target)
			endfor
		else
			call wheel#line#select_switch (level, selected[0], target)
		endif
	else
		echomsg 'Wheel line select switch : wrond size of selected'
	endif
endfun

fun! wheel#line#helix (...)
	" Switch to helix location in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	if len(list) < 5
		echomsg 'Helix line is too short'
		return
	endif
	let coordin = [list[0], list[2], list[4]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#line#tree (...)
	" Switch to helix tree element in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let coordin = wheel#line#fold_coordin ()
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

fun! wheel#line#grid (...)
	" Switch to grid circle in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	if len(list) < 3
		echomsg 'Grid line is too short'
		return
	endif
	let coordin = [list[0], list[2]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#tune('torus', coordin[0])
	call wheel#vortex#tune('circle', coordin[1])
	call wheel#vortex#jump ()
endfun

fun! wheel#line#history (...)
	" Switch to history location in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	if len(list) < 11
		echomsg 'History line is too short'
		return
	endif
	let coordin = [list[6], list[8], list[10]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump ()
endfun
