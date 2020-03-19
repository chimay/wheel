" vim: set filetype=vim:

" Status

fun! wheel#referen#torus ()
	" Current torus
	let cur_torus = {}
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
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
		if a:1 == 'all' || a:1 == 'a' || a:1 == 1
			let all = 1
		endif
	endif
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
			let cur_circle = cur_torus.circles[cur_torus.current]
			if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations)
				let cur_location = cur_circle.locations[cur_circle.current]
			endif
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
		if a:1 == 'all' || a:1 == 'a' || a:1 == 1
			let all = 1
		endif
	endif
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
			let cur_circle = cur_torus.circles[cur_torus.current]
			if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations)
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
