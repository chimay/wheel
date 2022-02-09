" vim: set ft=vim fdm=indent iskeyword&:

" Pendulum
"
" History

" g:wheel_history keys :
"
" - line : naturally sorted list of timestamps & wheel coordinates
"		   each coordinate appear at most once
"		   used :
"				- in history dedicated buffer
"				- to build & update g:wheel_history.alternate
"
" - circuit : unsorted list of travelled wheel coordinates
"			  used in newer & older functions
"			  rotated by newer & older
"
" - alternate : coordinates of alternates locations

" other names ideas for this file :
"   - sundial
"   - hourglass, sandglass
"   - cuckoo
"   - longcase clock

" timestamps

fun! wheel#pendulum#timestamp ()
	" Timestamp in seconds since epoch
	 return str2nr(strftime('%s'))
endfun

fun! wheel#pendulum#date_hour (timestamp)
	" Timestamp in date & hour format
	return strftime('%Y %B %d %A %H:%M', a:timestamp)
endfun

fun! wheel#pendulum#compare (one, two)
	" Comparison of history entries : used to sort index
	return a:two.timestamp - a:one.timestamp
endfun

" filters

fun! wheel#pendulum#distinct_coordin (index, one, unused, two)
	" Return true if coordin[0:index] of one & two are distinct
	" unused argument is for compatibility with filter()
	let one = a:one
	let two = a:two
	let index = a:index
	let type_one = type(one)
	let type_two = type(two)
	if type_one == v:t_list && type_two == v:t_list
		return one[:index] != two[:index]
	elseif type_one == v:t_dict && type_two == v:t_dict
		return one.coordin[:index] != two.coordin[:index]
	elseif type_one == v:t_list && type_two == v:t_dict
		return one[:index] != two.coordin[:index]
	elseif type_one == v:t_dict && type_two == v:t_list
		return one.coordin[:index] != two[:index]
	endif
endfun

fun! wheel#pendulum#coordin_inside_wheel (unused, entry)
	" Return true if coordin of entry belongs to the wheel
	" unused argument is for compatibility with filter()
	let entry = a:entry
	let coordin = entry.coordin
	let helix = wheel#helix#helix()
	return coordin->wheel#chain#is_inside(helix)
endfun

" helpers

fun! wheel#pendulum#remove_if_present (entry)
	" Remove entry from history if coordinates are already there
	let entry = a:entry
	let Filter = function('wheel#pendulum#distinct_coordin', [2, entry])
	" history line
	let timeline = g:wheel_history.line
	eval timeline->filter(Filter)
	" history circuit
	let timeloop = g:wheel_history.circuit
	eval timeloop->filter(Filter)
endfun

fun! wheel#pendulum#update_alternate ()
	" Update g:wheel_history.alternate
	let timeline = g:wheel_history.line
	let alternate = g:wheel_history.alternate
	let length = len(timeline)
	if length < 2
		return v:false
	endif
	let current = timeline[0].coordin
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin != current
			let alternate.anywhere = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin[0] ==# current[0]
			let alternate.same_torus = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin[0] ==# current[0] && coordin[1] ==# current[1]
			let alternate.same_circle = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin[0] !=# current[0]
			let alternate.other_torus = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin[0] !=# current[0] || coordin[1] !=# current[1]
			let alternate.other_circle = coordin
			break
		endif
	endfor
	for ind in range(1, length - 1)
		let coordin = timeline[ind].coordin
		if coordin[0] ==# current[0] && coordin[1] !=# current[1]
			let alternate.same_torus_other_circle = coordin
			break
		endif
	endfor
	return v:true
endfun

" operations

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	" Add new entry at the beginning of the list
	" Move existing entry at the beginning of the list
	" Update alternate coordinates
	" -- new entry
	let coordin = wheel#referen#coordinates()
	let maxim = g:wheel_config.maxim.history
	let entry = {}
	let entry.coordin = coordin
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#remove_if_present (entry)
	" -- new entry in history line
	let timeline = g:wheel_history.line
	eval timeline->wheel#chain#push_max(entry, maxim)
	" -- new entry in history circuit
	let timeloop = g:wheel_history.circuit
	eval timeloop->wheel#chain#push_max(entry, maxim)
	" -- alternate history
	call wheel#pendulum#update_alternate ()
	" -- frecency
	call wheel#cuckoo#record ()
endfun

fun! wheel#pendulum#rename (level, old, new)
	" Rename all occurences old -> new in history
	" level = 0 or torus    : rename torus
	" level = 1 or circle   : rename circle
	" level = 2 or location : rename location
	let level = a:level
	let old = a:old
	let new = a:new
	let level_index = wheel#referen#level_index_in_coordin (level)
	let new_names = wheel#referen#coordinates ()
	let old_names = copy(new_names)
	let old_names[level_index] = old
	" -- history line
	for elem in g:wheel_history.line
		let coordin = elem.coordin
		if coordin[:level_index] == old_names[:level_index]
			let elem.coordin[level_index] = new
		endif
	endfor
	" -- history circuit
	for elem in g:wheel_history.circuit
		let coordin = elem.coordin
		if coordin[:level_index] == old_names[:level_index]
			let elem.coordin[level_index] = new
		endif
	endfor
	" -- frecency
	for elem in g:wheel_history.frecency
		let coordin = elem.coordin
		if coordin[:level_index] == old_names[:level_index]
			let elem.coordin[level_index] = new
		endif
	endfor
	" -- alternate
	call wheel#pendulum#update_alternate ()
endfun

fun! wheel#pendulum#delete (level, coordin)
	" Delete all occurences of coordin coordin in history
	" level = 0 or torus    : delete torus
	" level = 1 or circle   : delete circle
	" level = 2 or location : delete location
	let level = a:level
	let coordin = a:coordin
	let level_index = wheel#referen#level_index_in_coordin (level)
	let coordin = coordin
	let Filter = function('wheel#pendulum#distinct_coordin', [level_index, coordin])
	" -- history line
	let timeline = g:wheel_history.line
	eval timeline->filter(Filter)
	" -- history circuit
	let timeloop = g:wheel_history.circuit
	eval timeloop->filter(Filter)
	" -- frecency
	let frecency = g:wheel_history.frecency
	eval frecency->filter(Filter)
	" -- alternate
	call wheel#pendulum#update_alternate ()
endfun

fun! wheel#pendulum#broom ()
	" Remove history entries that do not belong to the wheel anymore
	let Filter = function('wheel#pendulum#coordin_inside_wheel')
	" -- history line
	let timeline = g:wheel_history.line
	eval timeline->filter(Filter)
	" -- history circuit
	let timeloop = g:wheel_history.circuit
	eval timeloop->filter(Filter)
	" -- frecency
	let frecency = g:wheel_history.frecency
	eval frecency->filter(Filter)
	" -- alternate
	call wheel#pendulum#update_alternate ()
endfun

" newer & older

fun! wheel#pendulum#newer_anywhere ()
	" Go to newer entry in g:wheel_history.circuit
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_right (timeloop)
	let coordin = timeloop[0].coordin
	" rotate makes deepcopy
	let g:wheel_history.circuit = timeloop
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#older_anywhere ()
	" Go to older entry in g:wheel_history.circuit
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_left (timeloop)
	let coordin = timeloop[0].coordin
	" rotate makes deepcopy
	let g:wheel_history.circuit = timeloop
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#newer (level = 'wheel')
	" Go to newer entry in g:wheel_history.circuit, same level
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel newer :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#newer_anywhere ()
	endif
	" ---- current coordin
	let names = wheel#referen#coordinates ()
	" ---- index for range in coordin
	let level_index = wheel#referen#level_index_in_coordin (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_right (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_right (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" newer found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel newer : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a deepcopy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#older (level = 'wheel')
	" Go to older entry in g:wheel_history.circuit, same level
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel older :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#older_anywhere ()
	endif
	" current coordin
	let names = wheel#referen#coordinates ()
	" index for range in coordin
	let level_index = wheel#referen#level_index_in_coordin (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_left (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_left (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" older found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel older : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a copy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

" alternate

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
	if has_key(g:wheel_history.alternate, a:mode)
		let coordin = g:wheel_history.alternate[a:mode]
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
