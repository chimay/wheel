" vim: ft=vim fdm=indent:

fun! wheel#status#print ()
	" Print global variables
	echo g:wheel
endfu

fun! wheel#status#dashboard ()
	" Display dashboard, summary of current wheel status
	let [cur_torus, cur_circle, cur_location] = wheel#referen#location('all')
	let chaine = cur_torus.name . ' >> '
	let chaine .= cur_circle.name . ' > '
	let chaine .= cur_location.name . ' : '
	let chaine .= cur_location.file . ':' . cur_location.line . ':' . cur_location.col
	echomsg chaine
endfun
