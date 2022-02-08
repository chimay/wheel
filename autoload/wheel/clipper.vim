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
	setlocal nomodified
	" --- property
	let b:wheel_nature.yank = {}
	let b:wheel_nature.yank.register = 'default'
	" ---- reload
	let b:wheel_reload = 'wheel#clipper#yank(' .. string(mode) .. ')'
endfun
