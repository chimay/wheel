" vim: set filetype=vim:

" Move to elements
" Move elements

fun! wheel#vortex#here ()
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	return location
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
		let current = g:wheel.current
		let g:wheel.current = float2nr(fmod(current - 1, len(g:wheel.toruses)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_torus ()
	if has_key(g:wheel, 'toruses') && ! empty(g:wheel.toruses)
		let current = g:wheel.current
		let g:wheel.current = float2nr(fmod(current + 1, len(g:wheel.toruses)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#prev_circle ()
	let cur_torus = wheel#referen#torus()
	if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
		let current = cur_torus.current
		let cur_torus.current = float2nr(fmod(current - 1, len(cur_torus.circles)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_circle ()
	let cur_torus = wheel#referen#torus()
	if has_key(cur_torus, 'circles') && ! empty(cur_torus.circles)
		let current = cur_torus.current
		let cur_torus.current = float2nr(fmod(current + 1, len(cur_torus.circles)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#prev_location ()
	let cur_circle = wheel#referen#circle()
	if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations) > 0
		let current = cur_circle.current
		let cur_circle.current = float2nr(fmod(current - 1, len(cur_circle.locations)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_location ()
	let cur_circle = wheel#referen#circle()
	if has_key(cur_circle, 'locations') && ! empty(cur_circle.locations) > 0
		let current = cur_circle.current
		let cur_circle.current = float2nr(fmod(current + 1, len(cur_circle.locations)))
		call wheel#vortex#jump()
	endif
endfun

