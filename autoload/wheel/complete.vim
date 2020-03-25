" vim: ft=vim fdm=indent:

fun! wheel#complete#torus (arglead, cmdline, cursorpos)
	" Complete torus name
	let toruses = g:wheel.glossary
	return join(toruses, "\n")
endfu

fun! wheel#complete#circle (arglead, cmdline, cursorpos)
	" Complete circle name
	let cur_torus = wheel#referen#torus ()
	let circles = cur_torus.glossary
	return join(circles, "\n")
endfu

fun! wheel#complete#location (arglead, cmdline, cursorpos)
	" Complete location name
	let cur_circle = wheel#referen#circle ()
	let locations = cur_circle.glossary
	return join(locations, "\n")
endfu
