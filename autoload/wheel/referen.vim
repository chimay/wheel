" vim: ft=vim fdm=indent:

" Reference to objects in wheel

" Script vars

if ! exists('s:levels')
	let s:levels = wheel#crystal#fetch('referen/levels')
	lockvar s:levels
endif

if ! exists('s:coordin')
	let s:coordin = wheel#crystal#fetch('referen/coordin')
	lockvar s:coordin
endif

if ! exists('s:list_keys')
	let s:list_keys = wheel#crystal#fetch('referen/list_keys')
	lockvar s:list_keys
endif

" Current elements

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

" Coordinates

fun! wheel#referen#coordin_index (level)
	" Return index of level in coordinates
	" torus -> 0
	" circle -> 1
	" location -> 2
	return index(s:coordin, a:level)
endfun

fun! wheel#referen#names ()
	" Names of current torus, circle and location
	let [torus, circle, location] = wheel#referen#location('all')
	let names = []
	if has_key(torus, 'name')
		call add(names, torus.name)
		if has_key(circle, 'name')
			call add(names, circle.name)
			if has_key(location, 'name')
				call add(names, location.name)
			endif
		endif
	endif
	return names
endfun

" Hierarchy

fun! wheel#referen#upper (level)
	" Current upper element in hierarchy
	let index = index(s:levels, a:level)
	if index < 1 || index > 3
		echomsg 'Wheel referen upper : level must be torus, circle or location.'
		return
	endif
	let index -= 1
	return wheel#referen#{s:levels[index]} ()
endfun

fun! wheel#referen#lower (level)
	" Current lower element in hierarchy
	let index = index(s:levels, a:level)
	if index > 2 || index < 0
		echomsg 'Wheel referen lower : level index must be wheel, torus or circle.'
		return
	endif
	let index += 1
	return wheel#referen#{s:levels[index]} ()
endfun

fun! wheel#referen#upper_level_name (level)
	" Level name of upper element in hierarchy
	let index = index(s:levels, a:level)
	if index < 1 || index > 3
		echomsg 'Wheel referen upper level name : level must be torus, circle or location.'
		return
	endif
	let index -= 1
	return s:levels[index]
endfun

fun! wheel#referen#lower_level_name (level)
	" Level name of lower element in hierarchy
	let index = index(s:levels, a:level)
	if index > 2 || index < 0
		echomsg 'Wheel referen lower level name : level index must be wheel, torus or circle.'
		return
	endif
	let index += 1
	return s:levels[index]
endfun

" Emptiness

fun! wheel#referen#empty (level)
	" Whether current level element is empty
	" Wheel can be wheel, torus or circle
	let level = a:level
	let elem = wheel#referen#{level} ()
	let empty = empty(elem.glossary)
	return empty
endfun

fun! wheel#referen#empty_upper (level)
	" Whether upper level element is empty
	" Wheel can be torus, circle or location
	return empty(wheel#referen#{a:level}())
endfun

" Element lists

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
		echomsg 'Wheel referen elements : arg should be the wheel, a torus or a circle'
		return []
	endif
endfun
