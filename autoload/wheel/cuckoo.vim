" vim: set ft=vim fdm=indent iskeyword&:

" Cuckoo
"
" Frecency : frequent + recent

" script constants

if ! exists('s:frecency_stair')
	let s:frecency_stair = wheel#crystal#fetch('frecency/stair')
	lockvar s:frecency_stair
endif

if ! exists('s:frecency_slope')
	let s:frecency_slope = wheel#crystal#fetch('frecency/slope')
	lockvar s:frecency_slope
endif

" helpers

fun! wheel#cuckoo#slide (entry)
	" Decrease score in frecency
	let entry = a:entry
	let entry.score -= s:frecency_slope
	return entry
endfun

" functions

fun! wheel#cuckoo#record ()
	" Record current torus, circle, location in frecency
	let frecency = g:wheel_history.frecency
	let coordin = wheel#referen#names()
	let entry = {}
	let length = len(frecency)
	for index in range(length)
		let elem = frecency[index]
		if elem.coordin == coordin
			let entry = frecency->remove(index)
			let entry.score += s:frecency_stair
			break
		endif
	endfor
	if empty(entry)
		let entry.coordin = coordin
		let entry.score = s:frecency_stair
	endif
	echomsg entry
	eval frecency->map({ _, val -> wheel#cuckoo#slide (val) })
	eval frecency->filter({ _, val -> val.score >= 0 })
	for index in range(length)
		let elem = frecency[index]
		if entry.score >= elem.score
			eval frecency->insert(entry, index)
			return v:true
		endif
	endfor
	" still not inserted ? add it at the end
	eval frecency->add(entry)
	return v:true
endfun
