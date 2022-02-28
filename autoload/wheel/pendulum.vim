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
" - circuit : unsorted list of timestamps & travelled wheel coordinates
"			  used in newer & older functions
"			  rotated by newer & older
"
" - alternate : coordinates of alternates locations
"
" - frecency : coordinates & scores of locations

" other names ideas for this file :
"   - longcase clock
"   - chime

" ---- timestamps

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

" ---- filters

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

" ---- helpers

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

" ---- operations

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	" Add new entry at the beginning of the list
	" Move existing entry at the beginning of the list
	" Update alternate & frecency coordinates
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
	call wheel#caduceus#update ()
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
	call wheel#caduceus#update ()
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
	call wheel#caduceus#update ()
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
	call wheel#caduceus#update ()
endfun
