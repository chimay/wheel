" vim: ft=vim fdm=indent:

" Status

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
	let cur_torus = {}
	let cur_circle = {}
	if a:0 > 0
		if a:1 ==# 'all' || a:1 ==# 'a' || a:1 == 1
			let all = 1
		endif
	endif
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
	let cur_torus = {}
	let cur_circle = {}
	let cur_location = {}
	if a:0 > 0
		if a:1 ==# 'all' || a:1 ==# 'a' || a:1 == 1
			let all = 1
		endif
	endif
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

fun! wheel#referen#names ()
	" Names of current torus, circle and location
	let [torus, circle, location] = wheel#referen#location('all')
	return [torus.name, circle.name, location.name]
endfun

fun! wheel#referen#elements (dict)
	" Elements of dict :
	" - toruses if dict is the wheel
	" - circles if dict is a torus
	" - locations if dict is a circle
	if has_key(dict, )
endfun
