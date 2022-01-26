" vim: set ft=vim fdm=indent iskeyword&:

" Organize non-wheel elements, dedicated buffers

" reorganize tabs

fun! wheel#shape#reorg_tabwins ()
	" Reorganize tabs & windows
	let lines = wheel#perspective#tabwins_tree ()
	if empty(lines)
		echomsg 'wheel shape reorganize tabs & windows : empty lines'
		return v:false
	endif
	call wheel#mandala#blank ('reorg/tabwins')
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('reorg_tabwins')
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill(lines, 'delete-first')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#shape#reorg_tabwins'
endfun
