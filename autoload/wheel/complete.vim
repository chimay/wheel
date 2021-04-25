" vim: ft=vim fdm=indent:

" Completion functions
" Return string where each element occupies a line

" Helpers

fun! wheel#complete#layer_list ()
	" Return layer types list
	" layers types
	let filenames = wheel#layer#stack ('filename')
	if empty(filenames)
		return []
	endif
	let Fun = function('wheel#mandala#type')
	let types = map(copy(filenames), {_,v->Fun(v)})
	" current mandala type
	let title = wheel#mandala#type ()
	let top = b:wheel_stack.top
	call insert(types, title, top)
	" reverse to have previous on the left and next on the right
	call reverse(types)
	return types
endfun

fun! wheel#complete#mandala_list ()
	" Return mandala list
	let bufnums = g:wheel_mandalas.stack
	if empty(bufnums)
		return []
	endif
	let current = g:wheel_mandalas.current
	let types = []
	for index in range(len(bufnums))
		let num = bufnums[index]
		let title = bufname(num)
		call add(types, title)
	endfor
	return types
endfun

" Wheel elements

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

" Mandalas

fun! wheel#complete#layer (arglead, cmdline, cursorpos)
	" Complete layer in stack
	let layers = wheel#complete#layer_list ()
	return join(layers, "\n")
endfun

fun! wheel#complete#mandala (arglead, cmdline, cursorpos)
	" Complete mandala in stack
	let mandalas = wheel#complete#mandala_list ()
	return join(mandalas, "\n")
endfun
