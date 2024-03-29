" vim: set ft=vim fdm=indent iskeyword&:

" Mirror
"
" Organize native elements, dedicated buffers

fun! wheel#mirror#reorg_tabwin ()
	" Reorganize tabs & windows
	let lines = wheel#perspective#tabwin_tree ()
	" ---- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorganize tabs & windows : empty lines'
		return v:false
	endif
	" ---- mandala
	call wheel#mandala#blank ('reorg/tabwin')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#origami#folding_options ('tabwin_folding_text')
	call wheel#polyphony#score ('reorg_tabwin')
	call wheel#mandala#fill(lines)
	" ---- reload
	call wheel#mandala#set_reload('wheel#mirror#reorg_tabwin')
endfun
