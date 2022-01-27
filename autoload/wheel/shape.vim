" vim: set ft=vim fdm=indent iskeyword&:

" Organize non-wheel elements, dedicated buffers

" reorganize tabs

fun! wheel#shape#reorg_tabwins ()
	" Reorganize tabs & windows
	let lines = wheel#perspective#tabwins_tree ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorganize tabs & windows : empty lines'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorg/tabwins')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#yggdrasil#write ('reorg_tabwins')
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#shape#reorg_tabwins'
endfun
