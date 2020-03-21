" vim: set filetype=vim:

" Move to elements
" Move elements

fun! wheel#vortex#here ()
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	let location.name = fnamemodify(location.file, ':t:r')
	return location
endfun

fun! wheel#vortex#update ()
	let location = wheel#referen#location()
	if ! empty(location) && location.file == expand('%:p')
		let location.line = line('.')
		let location.col  = col('.')
	endif
endfun

fun! wheel#vortex#jump ()
	let cur_location = wheel#referen#location()
	if ! empty(cur_location)
		exe 'edit ' . cur_location.file
		exe cur_location.line
		exe 'normal ' . cur_location.col . '|'
		call wheel#status#dashboard()
	endif
endfun

fun! wheel#vortex#prev_torus ()
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
		call wheel#vortex#update ()
		let current = g:wheel.current
		let length = len(g:wheel.toruses)
		let g:wheel.current = wheel#gear#circular_minus(current, length)
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_torus ()
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
		call wheel#vortex#update ()
		let current = g:wheel.current
		let length = len(g:wheel.toruses)
		let g:wheel.current = wheel#gear#circular_plus(current, length)
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#prev_circle ()
	let cur_torus = wheel#referen#torus()
	if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
		call wheel#vortex#update ()
		let current = cur_torus.current
		let length = len(cur_torus.circles)
		let cur_torus.current = wheel#gear#circular_minus(current, length)
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_circle ()
	let cur_torus = wheel#referen#torus()
	if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
		call wheel#vortex#update ()
		let current = cur_torus.current
		let length = len(cur_torus.circles)
		let cur_torus.current = wheel#gear#circular_plus(current, length)
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#prev_location ()
	let cur_circle = wheel#referen#circle()
	if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations) > 0
		call wheel#vortex#update ()
		let current = cur_circle.current
		let length = len(cur_circle.locations)
		let cur_circle.current = wheel#gear#circular_minus(current, length)
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_location ()
	let cur_circle = wheel#referen#circle()
	if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations) > 0
		call wheel#vortex#update ()
		let current = cur_circle.current
		let length = len(cur_circle.locations)
		let cur_circle.current = wheel#gear#circular_plus(current, length)
		call wheel#vortex#jump()
	endif
endfun

