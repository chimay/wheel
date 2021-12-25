" vim: set ft=vim fdm=indent iskeyword&:

" History

" Wheel variables :
" - g:wheel_history : sorted list of timestamps & wheel coordinates
"					  each coordinate should appear at most once
" - g:wheel_track : list of wheel traveled wheel coordinates
"					each coordinate can appear more than once

" other names ideas :
" sundial
" hourglass, sandglass
" longcase clock

" Helpers

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

fun! wheel#pendulum#compare (one, two)
	" Comparison of history entries : used to sort index
	return a:two.timestamp - a:one.timestamp
endfu

fun! wheel#pendulum#is_in_history (entry)
	" Whether entry is in history
	let present = 0
	let entry = a:entry
	for elem in g:wheel_history
		if elem.coordin ==# entry.coordin
			let present = 1
		endif
	endfor
	return present
endfu

fun! wheel#pendulum#remove_if_present (entry)
	" Remove entry from history if coordinates are already there
	let entry = a:entry
	let history = g:wheel_history
	for elem in g:wheel_history
		if elem.coordin ==# entry.coordin
			let g:wheel_history = wheel#chain#remove_element(elem, history)
		endif
	endfor
endfu

" Operations

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	" Add new entry at the beginning of the list
	" Move existing entry at the beginning of the list
	" Update alternate coordinates
	" new entry in g:wheel_history
	let coordin = wheel#referen#names()
	let entry = {}
	let entry.coordin = coordin
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#remove_if_present (entry)
	let g:wheel_history = insert(g:wheel_history, entry)
	let max = g:wheel_config.maxim.history
	let g:wheel_history = g:wheel_history[:max - 1]
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let g:wheel_history = sort(g:wheel_history, Compare)
	" new entry in g:wheel_track
	" TODO
	" alternate history
	let alternate = g:wheel_alternate
	let history = deepcopy(g:wheel_history)
	let length = len(history)
	if length < 2
		return v:false
	endif
	let current = history[0].coordin
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin != current
			let alternate.anywhere = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin[0] ==# current[0]
			let alternate.same_torus = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin[0] ==# current[0] && coordin[1] ==# current[1]
			let alternate.same_circle = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin[0] !=# current[0]
			let alternate.other_torus = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin[0] !=# current[0] || coordin[1] !=# current[1]
			let alternate.other_circle = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = history[ind].coordin
		if coordin[0] ==# current[0] && coordin[1] !=# current[1]
			let alternate.same_torus_other_circle = coordin
			break
		endif
	endfor
	" return
	return v:true
endfu

fun! wheel#pendulum#rename(level, old, new)
	" Rename all occurences old -> new in history
	" level = 0 or torus    : rename torus
	" level = 1 or circle   : rename circle
	" level = 2 or location : rename location
	if type(a:level) == v:t_number
		let index = a:level
	elseif type(a:level) == v:t_string
		let index = wheel#referen#coordin_index (a:level)
	else
		echomsg 'Pendulum rename : level arg must be number or string'
		return
	end
	let new_names = wheel#referen#names ()
	let old_names = copy(new_names)
	let old_names[index] = a:old
	for elem in g:wheel_history
		let coordin = elem.coordin
		if coordin[:index] == old_names[:index]
			let elem.coordin[index] = a:new
		endif
	endfor
endfun

fun! wheel#pendulum#delete(level, old_names)
	" Delete all occurences of old_names in history
	" level = 0 or torus    : delete torus
	" level = 1 or circle   : delete circle
	" level = 2 or location : delete location
	if type(a:level) == v:t_number
		let index = a:level
	elseif type(a:level) == v:t_string
		let index = wheel#referen#coordin_index (a:level)
	else
		echomsg 'Pendulum delete : level arg must be number or string'
		return
	end
	let history = deepcopy(g:wheel_history)
	for elem in history
		let coordin = elem.coordin
		if coordin[:index] == a:old_names[:index]
			let g:wheel_history =
						\ wheel#chain#remove_element(elem, g:wheel_history)
		endif
	endfor
endfun

fun! wheel#pendulum#broom ()
	" Remove history entries that do not belong to the wheel anymore
	let success = 1
	let history = deepcopy(g:wheel_history)
	let helix = wheel#helix#helix()
	let ind = 0
	let length = len(history)
	while ind < length
		let coordin = history[ind].coordin
		if index(helix, coordin) < 0
			let success = 0
			echomsg 'Removing [' join(coordin, ', ') '] from history.'
			call wheel#chain#remove_element(history[ind], g:wheel_history)
		endif
		let ind += 1
	endwhile
	return success
endfun

" Newer & older

fun! wheel#pendulum#newer ()
	" Go to newer entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_right (history)
	" done in wheel#vortex#jump
	"let g:wheel_history[0].timestamp = wheel#pendulum#timestamp ()
	let coordin = g:wheel_history[0].coordin
	if coordin == g:wheel_alternate.anywhere
		let g:wheel_history = wheel#chain#rotate_right (history)
		let coordin = g:wheel_history[0].coordin
	endif
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#older ()
	" Go to older entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_left (history)
	" done in wheel#vortex#jump
	"let g:wheel_history[0].timestamp = wheel#pendulum#timestamp ()
	let coordin = g:wheel_history[0].coordin
	if coordin == g:wheel_alternate.anywhere
		let g:wheel_history = wheel#chain#rotate_left (history)
		let coordin = g:wheel_history[0].coordin
	endif
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

" Alternate

fun! wheel#pendulum#alternate (mode)
	" Alternate entries in history
	" mode argument can be :
	" - anywhere : alternate with previous entry anywhere in the wheel
	" - same_torus : previous entry in same torus
	" - other_torus : previous entry in another torus
	" - same_circle : previous entry in same circle
	" - other_circle : previous entry in another circle
	" - same_torus_other_circle : previous entry in same torus, but another circle
	" If not in current location file, just jump to it
	if ! wheel#referen#location_matches_file ()
		return wheel#vortex#jump ()
	endif
	if has_key(g:wheel_alternate, a:mode)
		call wheel#vortex#update ()
		let coordin = g:wheel_alternate[a:mode]
		call wheel#vortex#chord(coordin)
	endif
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#alternate_menu ()
	" Alternate prompt menu
	let prompt = 'Alternate mode ? '
	let mode = confirm(prompt, "&1 Anywhere\n&2 Same torus\n&3 Same circle\n&4 Other torus\n&5 Other circle\n&6 Same torus, other circle", 1)
	if mode == 1
		call wheel#pendulum#alternate ('anywhere')
	elseif mode == 2
		call wheel#pendulum#alternate ('same_torus')
	elseif mode == 3
		call wheel#pendulum#alternate ('same_circle')
	elseif mode == 4
		call wheel#pendulum#alternate ('other_torus')
	elseif mode == 5
		call wheel#pendulum#alternate ('other_circle')
	elseif mode == 6
		call wheel#pendulum#alternate ('same_torus_other_circle')
	endif
endfun
