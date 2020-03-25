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
