" vim: set ft=vim fdm=indent iskeyword&:

" Yank ring
"
" Takes advantage of TextYankPost event

" codex were rewritten by copists
"
" other names ideas for this file :
"
" scroll, coil, spool
" scriptorium

fun! wheel#codex#register (register, move = 'dont-move')
	" Add register to yank wheel
	" Optional argument :
	"   - dont-move : register content
	"   - begin : register and, if register content is already in yank wheel,
	"             move it at the beginning of the list
	let move = a:move
	let yanks = g:wheel_yank
	let content = getreg(a:register)
	if strchars(content) > g:wheel_config.maxim.yank_size
		return
	endif
	let content = split(content, "\n")
	let index = yanks->index(content)
	if index < 0
		eval yanks->insert(content)
	else
		if move == 'begin'
			eval yanks->remove(, index)
			eval yanks->insert(, content)
		endif
	endif
endfun

fun! wheel#codex#add ()
	" Insert most used registers in yank wheel
	call wheel#codex#register ('.')
	call wheel#codex#register ('+')
	call wheel#codex#register ('*')
	call wheel#codex#register ('"', 'begin')
	let max = g:wheel_config.maxim.yanks
	let g:wheel_yank = g:wheel_yank[:max - 1]
endfun

fun! wheel#codex#yank_list (...)
	" Paste yank from yank ring in list mode
	let prompt = 'Yank element (list mode) : '
	let complete = 'customlist,wheel#complete#yank_list'
	let line = input(prompt, '', complete)
	let content = eval(line)
	put =content
endfun

fun! wheel#codex#yank_plain (...)
	" Paste yank from yank ring in plain mode
	let prompt = 'Yank element (plain mode) : '
	let complete = 'customlist,wheel#complete#yank_plain'
	let content = input(prompt, '', complete)
	put =content
endfun
