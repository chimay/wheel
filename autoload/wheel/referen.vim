" vim: set ft=vim fdm=indent iskeyword&:

" Referen
"
" Reference to objects in wheel

" Script constants

if ! exists('s:levels')
	let s:levels = wheel#crystal#fetch('referen/levels')
	lockvar s:levels
endif

if ! exists('s:coordinates_levels')
	let s:coordinates_levels = wheel#crystal#fetch('referen/coordinates/levels')
	lockvar s:coordinates_levels
endif

if ! exists('s:list_keys')
	let s:list_keys = wheel#crystal#fetch('referen/list_keys')
	lockvar s:list_keys
endif

" ---- current elements

fun! wheel#referen#wheel ()
	" Wheel
	return g:wheel
endfun

fun! wheel#referen#torus ()
	" Current torus
	let cur_torus = {}
	if ! empty(g:wheel.toruses)
		let cur_torus = g:wheel.toruses[g:wheel.current]
	endif
	return cur_torus
endfun

fun! wheel#referen#circle (...)
	" Current circle
	let all = 0
	if a:0 > 0
		if a:1 ==# 'all' || a:1 ==# 'a' || a:1 == 1
			let all = 1
		endif
	endif
	let cur_torus = {}
	let cur_circle = {}
	if ! empty(g:wheel.toruses)
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if ! empty(cur_torus.circles)
			let cur_circle = cur_torus.circles[cur_torus.current]
		endif
	endif
	if all == 1
		return [cur_torus, cur_circle]
	else
		return cur_circle
	endif
endfun

fun! wheel#referen#location (...)
	" Current location
	let all = 0
	if a:0 > 0
		if a:1 ==# 'all' || a:1 ==# 'a' || a:1 == 1
			let all = 1
		endif
	endif
	let cur_torus = {}
	let cur_circle = {}
	let cur_location = {}
	if ! empty(g:wheel.toruses)
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if ! empty(cur_torus.circles)
			let cur_circle = cur_torus.circles[cur_torus.current]
			if ! empty(cur_circle.locations)
				let cur_location = cur_circle.locations[cur_circle.current]
			endif
		endif
	endif
	if all == 1
		return [cur_torus, cur_circle, cur_location]
	else
		return cur_location
	endif
endfun

fun! wheel#referen#current (level)
	" Current level = wheel, torus, circle, location
	return wheel#referen#{a:level} ()
endfun

" ---- coordinates

fun! wheel#referen#level_index_in_coordin (level)
	" Return index of level in coordinates
	" wheel -> -1
	" torus -> 0
	" circle -> 1
	" location -> 2
	return s:coordinates_levels->index(a:level)
endfun

fun! wheel#referen#coordinates ()
	" Wheel coordinates : names of current torus, circle and location
	let [torus, circle, location] = wheel#referen#location('all')
	let names = []
	if has_key(torus, 'name')
		eval names->add(torus.name)
		if has_key(circle, 'name')
			eval names->add(circle.name)
			if has_key(location, 'name')
				eval names->add(location.name)
			endif
		endif
	endif
	return names
endfun

" ---- hierarchy

fun! wheel#referen#upper (level)
	" Current upper element in hierarchy
	let index = s:levels->index(a:level)
	if index < 1 || index > 3
		echomsg 'wheel referen upper : level must be torus, circle or location'
		return
	endif
	let index -= 1
	return wheel#referen#{s:levels[index]} ()
endfun

fun! wheel#referen#lower (level)
	" Current lower element in hierarchy
	let index = s:levels->index(a:level)
	if index > 2 || index < 0
		echomsg 'wheel referen lower : level index must be wheel, torus or circle'
		return
	endif
	let index += 1
	return wheel#referen#{s:levels[index]} ()
endfun

fun! wheel#referen#upper_level_name (level)
	" Level name of upper element in hierarchy
	let index = s:levels->index(a:level)
	if index < 1 || index > 3
		echomsg 'wheel referen upper level name : level must be torus, circle or location'
		return
	endif
	let index -= 1
	return s:levels[index]
endfun

fun! wheel#referen#lower_level_name (level)
	" Level name of lower element in hierarchy
	let index = s:levels->index(a:level)
	if index > 2 || index < 0
		echomsg 'wheel referen lower level name : level index must be wheel, torus or circle'
		return
	endif
	let index += 1
	return s:levels[index]
endfun

" ---- emptiness

fun! wheel#referen#is_empty (level)
	" Whether current level element is empty
	" Wheel can be wheel, torus, circle or location
	let level = a:level
	let elem = wheel#referen#current (level)
	if empty(elem) || empty(elem.glossary)
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#referen#is_upper_empty (level)
	" Whether upper level element is empty
	" Wheel can be torus, circle or location
	return empty(wheel#referen#current (a:level))
endfun

" ---- current file in wheel ?

fun! wheel#referen#is_in_wheel (...)
	" Whether filename argument is in wheel
	" Default optional argument : current filename
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%:p')
	endif
	let wheel_files = wheel#helix#files ()
	let is_in_wheel = wheel#chain#is_inside(filename, wheel_files)
	return is_in_wheel
endfun

" ---- element lists

fun! wheel#referen#list_key (level)
	" Name of key containing list of elements
	return s:list_keys[a:level]
endfun

fun! wheel#referen#elements (dict)
	" Elements list of dict :
	" - toruses if dict is the wheel
	" - circles if dict is a torus
	" - locations if dict is a circle
	let dict = a:dict
	if has_key(dict, 'toruses')
		return dict.toruses
	elseif has_key(dict, 'circles')
		return dict.circles
	elseif has_key(dict, 'locations')
		return dict.locations
	else
		echomsg 'wheel referen elements : arg should be the wheel, a torus or a circle'
		return []
	endif
endfun

" ---- match current buffer

fun! wheel#referen#location_matches_file ()
	" Whether current location matches current file
	let cur_file = expand('%:p')
	let cur_location = wheel#referen#location()
	if empty(cur_location)
		return v:false
	endif
	return cur_file ==# cur_location.file
endfun

fun! wheel#referen#location_matches_file_line_col ()
	" Whether current location matches current file & cursor  position
	let cur_location = wheel#referen#location()
	let match = wheel#referen#location_matches_file ()
	let match = match && line('.') ==# cur_location.line
	let match = match && col('.') ==# cur_location.col
	return match
endfun
