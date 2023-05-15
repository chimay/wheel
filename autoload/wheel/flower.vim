" vim: set ft=vim fdm=indent iskeyword&:

" Flower
"
" Content generators for :
"
"   - completion of prompting function
"   - dedicated buffers (mandalas)
"
" Wheel elements
"
" Flower of life is a grid of overlapping circles
" often used as a frame when drawing a mandala

" ---- script constants

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = wheel#crystal#fetch('separator/level')
lockvar s:level_separ

if exists('s:fold_1')
	unlockvar s:fold_1
endif
let s:fold_1 = wheel#crystal#fetch('fold/one')
lockvar s:fold_1

if exists('s:fold_2')
	unlockvar s:fold_2
endif
let s:fold_2 = wheel#crystal#fetch('fold/two')
lockvar s:fold_2

" ---- helpers

fun! wheel#flower#execute (runme, ...)
	" Ex or system command
	if a:0 > 0
		let Execute = a:1
	else
		let Execute = function('execute')
	endif
	let runme = a:runme
	if type(Execute) == v:t_func
		let returnlist = Execute(runme)
	elseif type(Execute) == v:t_string
		let returnlist = {Execute}(runme)
	else
		throw 'wheel flower execute : bad function argument'
	endif
	let returnlist = split(returnlist, "\n")
	return returnlist
endfun

" ---- from referen

fun! wheel#flower#element (level)
	" Switch level = torus, circle or location
	let level = a:level
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		return upper.glossary
	else
		return []
	endif
endfun

fun! wheel#flower#rename_file ()
	" Locations & files names
	let circle = deepcopy(wheel#referen#circle())
	if empty(circle) || empty(circle.glossary)
		return []
	endif
	let glossary = circle.glossary
	let locations = circle.locations
	let filenames = locations->map({ _, val -> val.file })
	let returnlist = []
	let len_circle = len(locations)
	for index in range(len_circle)
		let entry = [glossary[index], filenames[index]]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	return returnlist
endfun

" ---- from helix

fun! wheel#flower#helix ()
	" Locations index
	" Each coordinate is a string torus > circle > location
	let helix = deepcopy(wheel#helix#helix ())
	return helix->map({ _, val -> join(val, s:level_separ) })
endfun

fun! wheel#flower#grid ()
	" Circle index
	" Each coordinate is a string torus > circle
	let grid = deepcopy(wheel#helix#grid ())
	return grid->map({ _, val -> join(val, s:level_separ) })
endfun

fun! wheel#flower#tree ()
	" Folded tree representation of the wheel index
	let returnlist = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		eval returnlist->add(entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			eval returnlist->add(entry)
			for location in circle.locations
				let entry = location.name
				eval returnlist->add(entry)
			endfor
		endfor
	endfor
	return returnlist
endfun

fun! wheel#flower#reorganize ()
	" Content for reorganize buffer
	" Return complete locations, not only the names
	let returnlist = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		eval returnlist->add(entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			eval returnlist->add(entry)
			for location in circle.locations
				let entry = string(location)
				eval returnlist->add(entry)
			endfor
		endfor
	endfor
	return returnlist
endfun

" ---- from pendulum

fun! wheel#flower#history ()
	" Naturally sorted timeline index
	" Each entry is a string : date hour | torus > circle > location
	let timeline = g:wheel_history.line
	let returnlist = []
	for entry in timeline
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ .. join(coordin, s:level_separ)
		eval returnlist->add(entry)
	endfor
	return returnlist
endfun

fun! wheel#flower#history_circuit ()
	" History circuit
	" Each entry is a string : date hour | torus > circle > location
	let timeloop = g:wheel_history.circuit
	let returnlist = []
	for entry in timeloop
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ .. join(coordin, s:level_separ)
		eval returnlist->add(entry)
	endfor
	return returnlist
endfun

" ---- from cuckoo

fun! wheel#flower#frecency ()
	" Frecency : frequent & recent
	let frecency = g:wheel_history.frecency
	let returnlist = []
	for entry in frecency
		let score = printf('%7d', entry.score)
		let coordin = entry.coordin
		let entry = score .. s:field_separ .. join(coordin, s:level_separ)
		eval returnlist->add(entry)
	endfor
	return returnlist
endfun
