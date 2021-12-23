" vim: ft=vim fdm=indent:

" Completion functions
"
" Return newline separated entries in string
" vim filters automatically the entries
" based on used input

" wheel

" fun! wheel#complete#torus (arglead, cmdline, cursorpos)
" 	" Complete torus name
" 	let toruses = wheel#completelist#torus (a:arglead, a:cmdline, a:cursorpos)
" 	return join(toruses, "\n")
" endfu

" fun! wheel#complete#circle (arglead, cmdline, cursorpos)
" 	" Complete circle name
" 	let cur_torus = wheel#referen#torus ()
" 	let circles = wheel#completelist#circle (a:arglead, a:cmdline, a:cursorpos)
" 	return join(circles, "\n")
" endfu

" fun! wheel#complete#location (arglead, cmdline, cursorpos)
" 	" Complete location name
" 	let cur_circle = wheel#referen#circle ()
" 	if has_key(cur_circle, 'glossary')
" 		let locations = wheel#completelist#location (a:arglead, a:cmdline, a:cursorpos)
" 		return join(locations, "\n")
" 	else
" 		return ''
" 	endif
" endfu

" mandalas

" fun! wheel#complete#mandala (arglead, cmdline, cursorpos)
" 	" Complete mandalas pseudo filenames
" 	let mandalas = wheel#completelist#mandala (a:arglead, a:cmdline, a:cursorpos)
" 	return join(mandalas, "\n")
" endfun

" fun! wheel#complete#layer (arglead, cmdline, cursorpos)
" 	" Complete current mandala layers
" 	let layers = wheel#completelist#layer (a:arglead, a:cmdline, a:cursorpos)
" 	return join(layers, "\n")
" endfun

" buffers

" fun! wheel#complete#visible_buffers (arglead, cmdline, cursorpos)
" 	" Complete visible buffers
" 	let buffers = wheel#completelist#visible_buffers (a:arglead, a:cmdline, a:cursorpos)
" 	return join(buffers, "\n")
" endfun

" files & dirs

" fun! wheel#complete#link_copy (arglead, cmdline, cursorpos)
" 	" Complete link or copy command to generate tree in
" 	" wheel#disc#tree_script
" 	let mandalas = ['ln -s', 'cp -n']
" 	return join(mandalas, "\n")
" endfun
