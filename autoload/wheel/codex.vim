" vim: set ft=vim fdm=indent iskeyword&:

" Codex
"
" Yank ring
"
" Takes advantage of TextYankPost event

" codex were written by copists
"
" other names ideas for this file :
"
" scroll, coil, spool
" scriptorium

" ---- script constants

if ! exists('s:registers_symbols')
	let s:registers_symbols = wheel#crystal#fetch('registers-symbols')
	lockvar s:registers_symbols
endif

" ---- helpers

fun! wheel#codex#climb (content, register = 'default')
	" Move content at beginning of yank ring
	let content = a:content
	let register = a:register
	let yanks = g:wheel_yank[register]
	let index = yanks->index(content)
	if index < 0
		return v:false
	endif
	eval yanks->remove(index)
	eval yanks->insert(content)
	return v:true
endfun

" ---- register

fun! wheel#codex#register (register = 'default')
	" Add register to yank wheel
	let register = a:register
	" ---- ring
	let yanks = g:wheel_yank[register]
	" ---- vim symbol of register
	let symbol = s:registers_symbols[register]
	" ---- content
	let content = getreg(symbol)
	if strchars(content) > g:wheel_config.maxim.yank_size
		return
	endif
	let content = split(content, "\n")
	" ---- add
	let index = yanks->index(content)
	if index >= 0
		eval yanks->remove(index)
	endif
	eval yanks->insert(content)
	" ---- truncate if too big
	if register == 'default'
		let maxim = g:wheel_config.maxim.default_yanks
	else
		let maxim = g:wheel_config.maxim.other_yanks
	endif
	let yanks = yanks[:maxim - 1]
	return v:true
endfun

" --- add : for TextYankPost

fun! wheel#codex#add ()
	" Insert most used registers in yank wheel
	for register in keys(s:registers_symbols)
		call wheel#codex#register (register)
	endfor
endfun

" ---- prompt

fun! wheel#codex#yank_list (where = 'linewise-after')
	" Paste yank from yank ring in list mode
	let where = a:where
	let prompt = 'Yank list element (' .. where .. ') : '
	let complete = 'customlist,wheel#complete#yank_list'
	let line = input(prompt, '', complete)
	let content = eval(line)
	let @" = join(content, "\n")
	if where == 'linewise-after'
		put =content
	elseif where == 'linewise-before'
		put! =content
	elseif where == 'charwise-after'
		normal! p
	elseif where == 'charwise-before'
		normal! P
	endif
	call wheel#codex#climb(content)
endfun

fun! wheel#codex#yank_plain (where = 'linewise-after')
	" Paste yank from yank ring in plain mode
	let where = a:where
	let prompt = 'Yank element (' .. where .. ') : '
	let complete = 'customlist,wheel#complete#yank_plain'
	let content = input(prompt, '', complete)
	let @" = content
	if where == 'linewise-after'
		put =content
	elseif where == 'linewise-before'
		put! =content
	elseif where == 'charwise-after'
		normal! p
	elseif where == 'charwise-before'
		normal! P
	endif
	call wheel#codex#climb([ content ])
endfun

" ---- mandala

fun! wheel#codex#switch (mode, register = '')
	" Switch register in yank mandala
	let mode = a:mode
	let register = a:register
	if empty(register)
		let prompt = 'Switch to register : '
		let complete = 'customlist,wheel#complete#register'
		let register = input(prompt, '', complete)
	endif
	let lines = wheel#perspective#yank(mode, register)
	call wheel#teapot#reset ()
	call wheel#mandala#replace(lines)
	call wheel#mandala#set_var_lines ()
	" --- property
	let b:wheel_nature.yank.register = register
endfun

fun! wheel#codex#undo ()
	" Undo action in previous window
	call wheel#rectangle#goto_previous ()
	undo
	call wheel#cylinder#recall ()
endfun

fun! wheel#codex#redo ()
	" Redo action in previous window
	call wheel#rectangle#goto_previous ()
	redo
	call wheel#cylinder#recall ()
endfun

fun! wheel#codex#options (mode)
	" Set local yank options
	setlocal nowrap
	if a:mode == 'plain'
		setlocal nocursorline
	endif
endfun

fun! wheel#codex#mappings (mode)
	" Define local yank maps
	let nmap = 'nnoremap <buffer>'
	let mode = a:mode
	if mode == 'list'
		let paste = 'wheel#line#paste_list'
	elseif mode == 'plain'
		let paste = 'wheel#line#paste_plain'
	endif
	" ---- normal mode
	let nmap = 'nnoremap <buffer>'
	exe nmap '<cr>  <cmd>call' paste "('linewise-after', 'close')<cr>"
	exe nmap 'g<cr> <cmd>call' paste "('linewise-after', 'open')<cr>"
	exe nmap 'p     <cmd>call' paste "('linewise-after', 'open')<cr>"
	exe nmap 'P     <cmd>call' paste "('linewise-before', 'open')<cr>"
	exe nmap 'gp    <cmd>call' paste "('charwise-after', 'open')<cr>"
	exe nmap 'gP    <cmd>call' paste "('charwise-before', 'open')<cr>"
	" -- switch register
	exe nmap 's     <cmd>call wheel#codex#switch(' .. string(mode) .. ')<cr>'
	" ---- visual mode
	if mode == 'plain'
		let paste_visual = 'wheel#line#paste_visual'
		let vmap = 'vnoremap <silent> <buffer>'
		exe vmap '<cr>  :<c-u>call' paste_visual "('after', 'close')<cr>"
		exe vmap 'g<cr> :<c-u>call' paste_visual "('after', 'open')<cr>"
		exe vmap 'p     :<c-u>call' paste_visual "('after', 'open')<cr>"
		exe vmap 'P     :<c-u>call' paste_visual "('before', 'open')<cr>"
	endif
	" ---- undo, redo
	nnoremap <buffer> u <cmd>call wheel#codex#undo()<cr>
	nnoremap <buffer> <c-r> <cmd>call wheel#codex#redo()<cr>
	" ---- context menu
	let menu = 'yank/' .. mode
	call wheel#boomerang#launch_map (menu)
endfun

fun! wheel#codex#template (settings)
	" Template
	let settings = a:settings
	let mode = settings.mode
	call wheel#mandala#template (settings)
	call wheel#codex#options (mode)
	call wheel#codex#mappings (mode)
	" selection
	call wheel#pencil#mappings ()
endfun
