" vim: ft=vim fdm=indent:

" History

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	let [torus, circle, location] = wheel#referen#location('all')
	let coordin = [torus.name, circle.name, location.name]
	let g:wheel_history = insert(g:wheel_history, coordin, 0)
	let max = g:wheel_config.max_history
	let g:wheel_history = g:wheel_history[:max - 1]
endfu

fun! wheel#pendulum#newer ()
	" Go to newer entry in history
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_right (history)
	let coordin = g:wheel_history[0]
	call wheel#vortex#switch_torus(coordin[0])
	call wheel#vortex#switch_circle(coordin[1])
	call wheel#vortex#switch_location(coordin[2])
endfun

fun! wheel#pendulum#older ()
	" Go to older entry in history
	let history = g:wheel_history
	let g:wheel_history = wheel#chain#rotate_left (history)
	let coordin = g:wheel_history[0]
	call wheel#vortex#switch_torus(coordin[0])
	call wheel#vortex#switch_circle(coordin[1])
	call wheel#vortex#switch_location(coordin[2])
endfun
