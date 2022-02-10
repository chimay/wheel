" vim: set ft=vim fdm=indent iskeyword&:

" Clipper
"
" Yank dedicated buffers

" ---- script constants

if ! exists('s:registers_symbols')
	let s:registers_symbols = wheel#crystal#fetch('registers-symbols')
	lockvar s:registers_symbols
endif

" ---- functions

fun! wheel#clipper#yank (mode)
	" Choose yank and paste
	let mode = a:mode
	let default_register = g:wheel_shelve.yank.default_register
	let lines = wheel#perspective#yank (mode, default_register)
	" ---- type from mode & register
	if mode ==# 'plain'
		let type = 'yank/'
	elseif mode ==# 'list'
		let type = 'yank/list/'
	endif
	if default_register ==# 'overview'
		let type ..= 'overview'
	elseif default_register ==# 'file'
		let type ..= '%%'
	else
		let symbols_dict = wheel#matrix#items2dict(s:registers_symbols)
		let type ..= symbols_dict[default_register]
	endif
	" ---- mandala
	call wheel#mandala#blank (type)
	let settings = {'mode' : mode}
	call wheel#codex#template(settings)
	call wheel#mandala#fill (lines)
	setlocal nomodified
	" --- property
	let b:wheel_nature.yank = {}
	let b:wheel_nature.yank.register = default_register
	" ---- reload
	let b:wheel_reload = 'wheel#clipper#yank(' .. string(mode) .. ')'
endfun
