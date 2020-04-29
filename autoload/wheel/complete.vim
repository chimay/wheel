" vim: ft=vim fdm=indent:

" Completion functions
" Return string where each element occupies a line

fun! wheel#complete#torus (arglead, cmdline, cursorpos)
	" Complete torus name
	if has_key(g:wheel, 'glossary')
		let toruses = g:wheel.glossary
		return join(toruses, "\n")
	else
		return ''
	endif
endfu

fun! wheel#complete#circle (arglead, cmdline, cursorpos)
	" Complete circle name
	let cur_torus = wheel#referen#torus ()
	if has_key(cur_torus, 'glossary')
		let circles = cur_torus.glossary
		return join(circles, "\n")
	else
		return ''
	endif
endfu

fun! wheel#complete#location (arglead, cmdline, cursorpos)
	" Complete location name
	let cur_circle = wheel#referen#circle ()
	if has_key(cur_circle, 'glossary')
		let locations = cur_circle.glossary
		return join(locations, "\n")
	else
		return ''
	endif
endfu
