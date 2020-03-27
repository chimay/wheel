" vim: ft=vim fdm=indent:

" History

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	let history = g:wheel_history
	let [torus, circle, location] = wheel#referen#location('all')
	let coordin = [torus.name, circle.name, location.name]
	if index(history, coordin) >= 0
		let g:wheel_history = wheel#chain#remove_element(coordin, history)
	endif
	let g:wheel_history = insert(g:wheel_history, coordin, 0)
	let max = g:wheel_config.max_history
	let g:wheel_history = g:wheel_history[:max - 1]
endfu

fun! wheel#pendulum#newer ()
	" Go to newer entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_right (history)
	let coordin = g:wheel_history[0]
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#older ()
	" Go to older entry in history
	call wheel#vortex#update ()
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_left (history)
	let coordin = g:wheel_history[0]
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#alternate ()
	" Alternate last two entries in history
	" If outside the wheel, just jump inside
	let files = wheel#helix#files ()
	let filename = expand('%:p')
	if index(files, filename) >= 0
		call wheel#vortex#update ()
		let history = g:wheel_history
		let g:wheel_history = wheel#chain#swap (history)
		let coordin = g:wheel_history[0]
		call wheel#vortex#tune(coordin)
	endif
	call wheel#vortex#jump ()
endfun

fun! wheel#pendulum#alternate_same_torus ()
	" Alternate entries in same torus
endfun

fun! wheel#pendulum#alternate_same_circle ()
	" Alternate entries in same circle
endfun

fun! wheel#pendulum#alternate_other_torus ()
	" Alternate last two toruses
endfun

fun! wheel#pendulum#alternate_other_circle ()
	" Alternate last two circles
endfun

fun! wheel#pendulum#alternate_same_torus_other_circle ()
	" Alternate in same torus but other circle
endfun

