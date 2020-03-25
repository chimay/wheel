" vim: ft=vim fdm=indent:

" History

fun! wheel#pendulum#record ()
	" Add current torus, circle, location to history
	let [torus, circle, location] = wheel#referen#location('all')
	let coordin = [torus.name, circle.name, location.name]
	return insert(g:wheel_history, coordin, 0)
endfu
