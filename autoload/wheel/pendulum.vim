" vim: ft=vim fdm=indent:

" History

fun! wheel#pendulum#add ()
	" Add current torus, circle, location to history
	let [torus, circle, location] = wheel#referen#location()
	let entry = [torus.name, circle.name, location.name]
endfu
