" vim: set ft=vim fdm=indent iskeyword&:

" Dedicated buffers to organize & refactor

" script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

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

" grep edit

fun! wheel#shape#grep_edit (...)
	" Reorder level elements in a buffer
	" -- arguments
	if a:0 > 0
		let pattern = a:1
	else
		let file = expand('%')
		if file =~ s:is_mandala_file .. 'context/grep'
			" called from context menu
			" original pattern is in the previous leaf of the ring
			let settings = wheel#book#previous ('settings')
			" old layer stack implementation
			"let settings = wheel#layer#top_field ('settings')
			let pattern = settings.pattern
		else
			let pattern = input('Grep circle files for pattern [edit mode] : ')
		endif
	endif
	if a:0 > 1
		let sieve = a:2
	else
		if file =~ s:is_mandala_file .. 'context/grep'
			let settings = wheel#book#previous ('settings')
			" old layer stack implementation
			"let settings = wheel#layer#top_field ('settings')
			let sieve = settings.sieve
		else
			let sieve = '\m.'
		endif
	endif
	" -- lines
	let lines = wheel#perspective#grep (pattern, sieve)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel sailing grep edit : no match found'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('grep/edit')
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('wheel#vector#write_quickfix')
	call wheel#mandala#fill (lines, 'delete-first')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" copy of original lines
	let b:wheel_lines = copy(lines)
	" reload
	let b:wheel_reload = "wheel#shape#grep_edit('" .. pattern .. "', '" .. sieve .. "')"
	" info
	echomsg 'adding or removing lines is not supported'
	return lines
endfun
