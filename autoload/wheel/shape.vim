" vim: ft=vim fdm=indent:

" Reshaping buffers

" Write commands

fun! wheel#shape#reorder_write (level)
	" Define reorder autocommands
	setlocal buftype=
	let autocommand = "autocmd BufWriteCmd <buffer> call wheel#cuboctahedron#reorder ('"
	let autocommand .= a:level . "')"
	augroup wheel
		autocmd!
		exe autocommand
	augroup END
endfun

fun! wheel#shape#reorganize_write ()
	" Define reorganize autocommands
	setlocal buftype=
	let autocommand = "autocmd BufWriteCmd <buffer> call wheel#cuboctahedron#reorganize ()"
	" Need a name when writing, even with BufWriteCmd
	augroup wheel
		autocmd!
		exe autocommand
	augroup END
endfun

" Reorder

fun! wheel#shape#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder-' . level)
	call wheel#mandala#common_maps ()
	call wheel#shape#reorder_write (level)
	let lines = wheel#perspective#switch (level)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
		silent global /^$/ delete
		setlocal nomodified
	else
		echomsg 'Wheel mandala reorder : empty or incomplete' level
	endif
endfun

" Reorganize

fun! wheel#shape#reorganize ()
	" Reorganize the wheel tree
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorganize')
	call wheel#mandala#common_maps ()
	call wheel#shape#reorganize_write ()
	call wheel#mandala#folding_options ()
	let lines = wheel#perspective#reorganize ()
	call wheel#mandala#fill(lines)
	silent global /^$/ delete
	setlocal nomodified
endfun
