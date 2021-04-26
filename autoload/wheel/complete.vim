" vim: ft=vim fdm=indent:

" Completion functions
" Return string where each element occupies a line

" Return entries as list
" ---------------------------------------------

fun! wheel#complete#layer_list ()
	" Return layer types
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
	" Return mandala buffers names
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

fun! wheel#complete#filename (arglead, cmdline, cursorpos)
	" Complete different flavours or current filename, or filename in cmdline
	let basis = expand('%')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" relative path
	let cwd = getcwd() . '/'
	let relative = substitute(basis, cwd, '', '')
	" abolute path
	let absolute = fnamemodify(basis, ':p')
	let simple = fnamemodify(basis, ':t')
	let root = fnamemodify(basis, ':t:r')
	" list
	let filenames = [root, simple, relative, absolute]
	" newline separated entries in string
	return filenames
endfun

" Return newline separated entries in string
" ---------------------------------------------

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

fun! wheel#complete#layer (arglead, cmdline, cursorpos)
	" Complete current mandala layers
	let layers = wheel#complete#layer_list ()
	return join(layers, "\n")
endfun

fun! wheel#complete#mandala (arglead, cmdline, cursorpos)
	" Complete mandalas pseudo filenames
	let mandalas = wheel#complete#mandala_list ()
	return join(mandalas, "\n")
endfun
