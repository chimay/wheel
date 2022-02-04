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
		return v:true
	endif
	if move == 'begin'
		eval yanks->remove(index)
		eval yanks->insert(content)
	endif
	return v:true
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

fun! wheel#codex#climb (content)
	" Move content at beginning of yank ring
	let content = a:content
	let yanks = g:wheel_yank
	let index = yanks->index(content)
	if index < 0
		return v:false
	endif
	eval yanks->remove(index)
	eval yanks->insert(content)
	return v:true
endfun

" prompt

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

" mandala

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
	" -- normal mode
	let nmap = 'nnoremap <buffer>'
	exe nmap '<cr>  <cmd>call' paste "('linewise-after', 'close')<cr>"
	exe nmap 'g<cr> <cmd>call' paste "('linewise-after', 'open')<cr>"
	exe nmap 'p     <cmd>call' paste "('linewise-after', 'open')<cr>"
	exe nmap 'P     <cmd>call' paste "('linewise-before', 'open')<cr>"
	exe nmap 'gp    <cmd>call' paste "('charwise-after', 'open')<cr>"
	exe nmap 'gP    <cmd>call' paste "('charwise-before', 'open')<cr>"
	" -- visual mode
	if mode == 'plain'
		let paste_visual = 'wheel#line#paste_visual'
		let vmap = 'vnoremap <silent> <buffer>'
		exe vmap '<cr>  :<c-u>call' paste_visual "('after', 'close')<cr>"
		exe vmap 'g<cr> :<c-u>call' paste_visual "('after', 'open')<cr>"
		exe vmap 'p     :<c-u>call' paste_visual "('after', 'open')<cr>"
		exe vmap 'P     :<c-u>call' paste_visual "('before', 'open')<cr>"
	endif
	" -- undo, redo
	nnoremap <buffer> u <cmd>call wheel#mandala#undo()<cr>
	nnoremap <buffer> <c-r> <cmd>call wheel#mandala#redo()<cr>
	" -- context menu
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
