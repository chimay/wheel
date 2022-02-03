" vim: set ft=vim fdm=indent iskeyword&:

" Shape
"
" Organize non-wheel elements, dedicated buffers

" reorganize tabs

fun! wheel#shape#reorg_tabwin ()
	" Reorganize tabs & windows
	let lines = wheel#perspective#tabwin_tree ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorganize tabs & windows : empty lines'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorg/tabwin')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#mandala#folding_options ('tabwin_folding_text')
	call wheel#cuboctahedron#write ('reorg_tabwin')
	call wheel#mandala#fill(lines)
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#shape#reorg_tabwin'
endfun
