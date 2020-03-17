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
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if has_key(cur_torus, 'circles') && len(cur_torus.circles) > 0
			let cur_circle = cur_torus.circles[cur_torus.current]
			if has_key(cur_circle, 'locations') && len(cur_circle.locations) > 0
				let cur_location = cur_circle.locations[cur_circle.current]
				exe 'edit ' . cur_location.file
				exe cur_location.line
				exe 'normal ' . cur_location.col . '|'
			endif
		endif
	endif
endfun

fun! wheel#vortex#next_torus ()
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let current = g:wheel.current
		let g:wheel.current = float2nr(fmod(current + 1, len(g:wheel.toruses)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#prev_torus ()
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let current = g:wheel.current
		let g:wheel.current = float2nr(fmod(current - 1, len(g:wheel.toruses)))
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next_circle ()
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if has_key(cur_torus, 'circles') && len(cur_torus.circles) > 0
			let current = cur_torus.current
			let cur_torus.current = float2nr(fmod(current + 1, len(cur_torus.circles)))
			call wheel#vortex#jump()
		endif
	endif
endfun

fun! wheel#vortex#prev_circle ()
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let cur_torus = g:wheel.toruses[g:wheel.current]
		if has_key(cur_torus, 'circles') && len(cur_torus.circles) > 0
			let current = cur_torus.current
			let cur_torus.current = float2nr(fmod(current - 1, len(cur_torus.circles)))
			call wheel#vortex#jump()
		endif
	endif
endfun

fun! wheel#vortex#next_location ()
endfun

fun! wheel#vortex#prev_location ()
endfun
