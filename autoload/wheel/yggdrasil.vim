" vim: set ft=vim fdm=indent iskeyword&:

" Yggdrasil
"
" Organize the wheel, dedicated buffers

" ---- reorder

fun! wheel#yggdrasil#reorder (level)
	" Reorder level elements
	let level = a:level
	let lines = wheel#flower#element (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorder : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorder/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#polyphony#score ('reorder', level)
	call wheel#mandala#fill(lines)
	" -- reload
	call wheel#mandala#set_reload('wheel#yggdrasil#reorder', level)
	" -- additional maps
	" sort
	nnoremap <buffer> <m-s> <cmd>2,$sort<cr>
	" reverse sort
	nnoremap <buffer> <m-r> <cmd>2,$sort!<cr>
endfun

" ---- rename

fun! wheel#yggdrasil#rename (level)
	" Rename level elements
	let level = a:level
	let lines = wheel#flower#element (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape rename : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('rename/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#polyphony#score ('rename', level)
	call wheel#mandala#fill(lines)
	setlocal nomodified
	" reload
	call wheel#mandala#set_reload('wheel#yggdrasil#rename', level)
endfun

fun! wheel#yggdrasil#rename_file ()
	" Rename locations & files of current circle
	" -- lines
	let lines = wheel#flower#rename_file ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape rename_file : empty or incomplete circle'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('rename/loc_files')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#polyphony#score ('rename_file')
	call wheel#mandala#fill(lines)
	setlocal nomodified
	" reload
	call wheel#mandala#set_reload('wheel#yggdrasil#rename_file')
	return v:true
endfun

" ---- delete

fun! wheel#yggdrasil#delete (level)
	" Copy or move elements at level
	let level = a:level
	let lines = wheel#flower#element (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape copy / move : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('delete/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#pencil#mappings ()
	call wheel#polyphony#score ('delete', level)
	call wheel#mandala#fill(lines)
	setlocal nomodified
	" reload
	call wheel#mandala#set_reload('wheel#yggdrasil#delete', level)
endfun

" ---- copy / move

fun! wheel#yggdrasil#copy_move (level)
	" Copy or move elements at level
	let level = a:level
	let lines = wheel#flower#element (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape copy / move : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('copy_move/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#pencil#mappings ()
	call wheel#polyphony#score ('copy_move', level)
	call wheel#mandala#fill(lines)
	setlocal nomodified
	" reload
	call wheel#mandala#set_reload('wheel#yggdrasil#copy_move', level)
endfun

" ---- reorganize

fun! wheel#yggdrasil#reorganize ()
	" Reorganize the wheel tree
	let lines = wheel#flower#reorganize ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorganize : empty wheel'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorganize')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#origami#folding_options ()
	call wheel#polyphony#score ('reorganize')
	call wheel#mandala#fill(lines)
	setlocal nomodified
	setlocal nocursorline
	" reload
	call wheel#mandala#set_reload('wheel#yggdrasil#reorganize')
endfun
