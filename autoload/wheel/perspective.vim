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

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	lockvar s:fold_markers
endif

if ! exists('s:level_1')
	let s:level_1 = ' ' . s:fold_markers[0] . '1'
	lockvar s:level_1
endif

if ! exists('s:level_2')
	let s:level_2 = ' ' . s:fold_markers[0] . '2'
	lockvar s:level_2
endif

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
		let entry = torus.name . s:level_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name . s:level_2
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
		let entry = torus.name . s:level_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name . s:level_2
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
		let bufnr = elem.bufnr
		let record = bufnr . s:field_separ
		let record .= bufname(bufnr) . s:field_separ
		let record .= elem.lnum . s:field_separ
		let record .= elem.col . s:field_separ
		let record .= elem.text
		call add(list, record)
	endfor
	return list
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
