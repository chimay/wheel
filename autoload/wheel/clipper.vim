" vim: set ft=vim fdm=indent iskeyword&:

" Clipper
"
" Yank dedicated buffers

fun! wheel#clipper#yank (mode)
	" Choose yank and paste
	let mode = a:mode
	let lines = wheel#perspective#yank (mode)
	call wheel#mandala#blank ('yank/' .. mode)
	let settings = {'mode' : mode}
	call wheel#codex#template(settings)
	call wheel#mandala#fill (lines)
	" yank ring is not related to any particular buffer
	let b:wheel_related_buffer = 'undefined'
	setlocal nomodified
	" reload
	let b:wheel_reload = 'wheel#clipper#yank(' .. string(mode) .. ')'
endfun
