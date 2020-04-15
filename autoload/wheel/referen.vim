" vim: ft=vim fdm=indent:

" Reference to objects in wheel

if ! exists('s:levels')
	if exists(':const')
		const s:levels = ['wheel', 'torus', 'circle', 'location']
	else
		let s:levels = ['wheel', 'torus', 'circle', 'location']
		lockvar s:levels
	endif
endif

if ! exists('s:coordin')
	if exists(':const')
		const s:coordin = [ 'torus', 'circle', 'location']
	else
		let s:coordin = [ 'torus', 'circle', 'location']
		lockvar s:coordin
	endif
endif

if ! exists('s:list_keys')
	if exists(':const')
		const s:list_keys =
					\{ 'wheel' : 'toruses',
					\ 'torus' : 'circles',
					\ 'circle' : 'locations'}
	else
		let s:list_keys =
					\{ 'wheel' : 'toruses',
					\ 'torus' : 'circles',
					\ 'circle' : 'locations'}
		lockvar s:list_keys
	endif
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
	return index(s:coordin, a:level)
endfun

fun! wheel#referen#names ()
	" Names of current torus, circle and location
	let [torus, circle, location] = wheel#referen#location('all')
	return [torus.name, circle.name, location.name]
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
