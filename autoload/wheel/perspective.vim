" vim: ft=vim fdm=indent:

" Content generators for mandala

" Script vars

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Helpers

fun! wheel#perspective#execute (runme, ...)
	" Generic ex or system command for wheel buffer
	if a:0 > 0
		let Execute = a:1
	else
		let Execute = function('execute')
	endif
	let runme = a:runme
	if type(Execute) == v:t_func
		let lines = Execute(runme)
	elseif type(Execute) == v:t_string
		let lines = {Execute}(runme)
	else
		echomsg 'Wheel perspective execute : bad function argument'
	endif
	let lines = split(lines, "\n")
	return lines
endfun

fun! wheel#perspective#bounce (runme)
	" Generic lines for jumps / changes lists
	let lines = wheel#perspective#execute(a:runme)[1:]
	let past = v:true
	let length = len(lines)
	for index in range(length)
		let elem = lines[index]
		if elem =~ '\m^>'
			let past = v:false
			let elem = substitute(elem, '\m^>', '', '')
			if empty(elem)
				call remove(lines, index)
			endif
		endif
		if past
			let fields = split(elem)
			let negative = - str2nr(fields[0])
			let fields[0] = string(negative)
			let elem = join(fields, s:field_separ)
		endif
		let elem = trim(elem, ' ')
		let lines[index] = elem
	endfor
	return lines
endfun

" From referen

fun! wheel#perspective#switch (level)
	" Content for switch mandala
	let level = a:level
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		return upper.glossary
	else
		return []
	endif
endfun

" From helix

fun! wheel#perspective#helix ()
	" Locations index for wheel buffer
	" Each coordinate is a string torus > circle > location
	let helix = wheel#helix#helix ()
	let lines = []
	for coordin in helix
		let entry = join(coordin, s:level_separ)
		let lines = add(lines, entry)
	endfor
	return lines
endfu

fun! wheel#perspective#grid ()
	" Circle index for wheel buffer
	" Each coordinate is a string torus > circle
	let grid = wheel#helix#grid ()
	let lines = []
	for coordin in grid
		let entry = coordin[0] . s:level_separ . coordin[1]
		let lines = add(lines, entry)
	endfor
	return lines
endfu

fun! wheel#perspective#tree ()
	" Tree representation of the wheel for wheel buffer
	let lines = []
	for torus in g:wheel.toruses
		let entry = torus.name . s:fold_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name . s:fold_2
			let lines = add(lines, entry)
			for location in circle.locations
				let entry = location.name
				let lines = add(lines, entry)
			endfor
		endfor
	endfor
	return lines
endfu

fun! wheel#perspective#reorganize ()
	" Content for reorganize buffer
	let lines = []
	for torus in g:wheel.toruses
		let entry = torus.name . s:fold_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name . s:fold_2
			let lines = add(lines, entry)
			for location in circle.locations
				let entry = string(location)
				let lines = add(lines, entry)
			endfor
		endfor
	endfor
	return lines
endfu

" From history

fun! wheel#perspective#pendulum ()
	" Sorted history index for wheel buffer
	" Each entry is a string : date hour | torus > circle > location
	let history = deepcopy(g:wheel_history)
	let Compare = function('wheel#pendulum#compare')
	let history = sort(history, Compare)
	let strings = []
	for entry in history
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour . s:field_separ
		let entry .= coordin[0] . s:level_separ . coordin[1] . s:level_separ . coordin[2]
		let strings = add(strings, entry)
	endfor
	return strings
endfu

" From vector

fun! wheel#perspective#grep ()
	" Quickfix list for wheel buffer
	" Each line has the format :
	" buffer-number | file | line | col | text
	let quickfix = getqflist()
	let list = []
	for elem in quickfix
		let bufnum = elem.bufnr
		let record = bufnum . s:field_separ
		let record .= bufname(bufnum) . s:field_separ
		let record .= elem.lnum . s:field_separ
		let record .= elem.col . s:field_separ
		let record .= elem.text
		call add(list, record)
	endfor
	return list
endfun

" From symbol

fun! wheel#perspective#symbol ()
	" Tags for special buffer
	let table = wheel#symbol#table ()
	let lines = []
	for record in table
		let suit = join(record, s:field_separ)
		call add(lines, suit)
	endfor
	return lines
endfun

" From attic

fun! wheel#perspective#attic ()
	" Sorted most recenty used files for wheel buffer
	" Each entry is a string : date hour | filename
	let attic = deepcopy(g:wheel_attic)
	let Compare = function('wheel#pendulum#compare')
	let attic = sort(attic, Compare)
	let strings = []
	for entry in attic
		let filename = entry.file
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour . s:field_separ
		let entry .= filename
		let strings = add(strings, entry)
	endfor
	return strings
endfu

" From codex

fun! wheel#perspective#yank (mode)
	" Yanks for wheel buffer
	let lines = []
	if a:mode == 'list'
		for elem in g:wheel_yank
			call add(lines, string(elem))
		endfor
	elseif a:mode == 'plain'
		for elem in g:wheel_yank
			let plain = join(elem, "\n")
			" Only add if some text is there
			if plain =~ '\m\w'
				call add(lines, plain)
			endif
		endfor
	endif
	return lines
endfun

" From nowhere

fun! wheel#perspective#occur (pattern)
	" Occur for wheel buffer
	let pattern = a:pattern
	let position = getcurpos()
	let runme = 'global /' . pattern . '/'
	let lines = execute(runme)
	let lines = split(lines, "\n")
	for index in range(len(lines))
		let lines[index] = trim(lines[index], ' ')
		let lines[index] = substitute(lines[index], '\s\+', s:field_separ, '')
	endfor
	call wheel#gear#restore_cursor(position)
	return lines
endfun

fun! wheel#perspective#locate (pattern)
	" Locate for wheel buffer
	let pattern = a:pattern
	let database = g:wheel_config.locate_db
	if empty(database)
		let runme = 'locate ' . pattern
	else
		let runme = 'locate -d ' . expand(database) . ' ' . pattern
	endif
	let lines = systemlist(runme)
	return lines
endfun
