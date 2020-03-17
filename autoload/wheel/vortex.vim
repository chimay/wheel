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
	let cur_torus = g:wheel.toruses[g:wheel.current]
	let cur_circle = cur_torus.circles[cur_torus.current]
	let cur_location = cur_circle.locations[cur_circle.current]
	exe 'edit ' . cur_location.file
	exe cur_location.line
	exe 'normal ' . cur_location.col . '|'
endfun

fun! wheel#vortex#next_torus ()
endfun

fun! wheel#vortex#prev_torus ()
endfun

fun! wheel#vortex#next_circle ()
endfun

fun! wheel#vortex#prev_circle ()
endfun

fun! wheel#vortex#next_location ()
endfun

fun! wheel#vortex#prev_location ()
endfun
