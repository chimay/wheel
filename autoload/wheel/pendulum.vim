" vim: ft=vim fdm=indent:

" History

fun! wheel#pendulum#timestamp ()
	" Timestamp in seconds since epoch
	 return str2nr(strftime('%s'))
endfu

fun! wheel#pendulum#date_hour (timestamp)
	" Timestamp in date & hour format
	if g:wheel_config.debug > 0
		return strftime('%Y %B %d %A %H:%M:%S', a:timestamp)
	else
		return strftime('%Y %B %d %A %H:%M', a:timestamp)
	endif
endfu

fun! wheel#pendulum#is_in_history (entry)
	let present = 0
	let entry = a:entry
	for elt in g:wheel_history
		if elt.coordin == entry.coordin
			let present = 1
		endif
	endfor
	return present
endfu

fun! wheel#pendulum#remove_if_present (entry)
	let entry = a:entry
	let history = g:wheel_history
	for elt in g:wheel_history
		if elt.coordin == entry.coordin
			let g:wheel_history = wheel#chain#remove_element(elt, history)
		endif
	endfor
endfu

fun! wheel#pendulum#rename(index, old, new)
	" Rename all occurences old -> new in history
	" index = 0 : rename torus
	" index = 1 : rename circle
	" index = 2 : rename location
	let index = a:index
	let old = a:old
	let new = a:new
	for elem in g:wheel_history
		let coordin = elem.coordin
		if coordin[index] == old
			let elem.coordin[index] = new
		endif
	endfor
endfun

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	let history = g:wheel_history
	let [torus, circle, location] = wheel#referen#location('all')
	let coordin = [torus.name, circle.name, location.name]
	let entry = {}
	let entry.coordin = coordin
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#remove_if_present (entry)
	let g:wheel_history = insert(g:wheel_history, entry, 0)
	let max = g:wheel_config.max_history
	let g:wheel_history = g:wheel_history[:max - 1]
endfu

fun! wheel#pendulum#newer ()
	" Go to newer entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_right (history)
	let g:wheel_history[0].timestamp = wheel#pendulum#timestamp ()
	let coordin = g:wheel_history[0].coordin
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#older ()
	" Go to older entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_left (history)
	let g:wheel_history[0].timestamp = wheel#pendulum#timestamp ()
	let coordin = g:wheel_history[0].coordin
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#alternate ()
	" Alternate last two entries in history
	" If outside the wheel, just jump inside
	let files = wheel#helix#files ()
	let filename = expand('%:p')
	if index(files, filename) >= 0
		call wheel#vortex#update ()
		let history = g:wheel_history
		let g:wheel_history = wheel#chain#swap (history)
		let g:wheel_history[0].timestamp = wheel#pendulum#timestamp ()
		let coordin = g:wheel_history[0].coordin
		call wheel#vortex#tune(coordin)
	endif
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#alternate_same_torus ()
	" Alternate entries in same torus
endfun

fun! wheel#pendulum#alternate_same_circle ()
	" Alternate entries in same circle
endfun

fun! wheel#pendulum#alternate_other_torus ()
	" Alternate last two toruses
endfun

fun! wheel#pendulum#alternate_other_circle ()
	" Alternate last two circles
endfun

fun! wheel#pendulum#alternate_same_torus_other_circle ()
	" Alternate in same torus but other circle
endfun

fun! wheel#pendulum#locations ()
	" Index of locations coordinates in the history
	" Each coordinate is a string : date hour | torus >> circle > location
	let history = g:wheel_history
	let strings = []
	for entry in history
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour . ' | '
		let entry .= coordin[0] . ' >> ' . coordin[1] . ' > ' . coordin[2]
		let strings = add(strings, entry)
	endfor
	return strings
endfu
