" vim: set ft=vim fdm=indent iskeyword&:

" Yank mandala buffers

" Helpers

fun! wheel#clipper#options (mode)
	" Set local yank options
	setlocal nowrap
	if a:mode == 'plain'
		setlocal nocursorline
	endif
endfun

fun! wheel#clipper#mappings (mode)
	" Define local yank maps
	let nmap = 'nnoremap <buffer>'
	if a:mode == 'list'
		let function = 'wheel#line#paste_list'
	elseif a:mode == 'plain'
		let function = 'wheel#line#paste_plain'
	endif
	" normal mode
	exe 'nmap <cr> <cmd>call' function "('linewise_after', 'close')<cr>"
	exe 'nmap g<cr> <cmd>call' function "('linewise_after', 'open')<cr>"
	exe 'nmap p <cmd>call' function "('linewise_after', 'open')<cr>"
	exe 'nmap P <cmd>call' function "('linewise_before', 'open')<cr>"
	exe 'nmap gp <cmd>call' function "('charwise_after', 'open')<cr>"
	exe 'nmap gP <cmd>call' function "('charwise_before', 'open')<cr>"
	if a:mode == 'plain'
		" Visual mode
		vnoremap <silent> <buffer> <cr> :<c-u>call wheel#line#paste_visual('after', 'close')<cr>
		vnoremap <silent> <buffer> g<cr> :<c-u>call wheel#line#paste_visual('after', 'open')<cr>
		vnoremap <silent> <buffer> p :<c-u>call wheel#line#paste_visual('after', 'open')<cr>
		vnoremap <silent> <buffer> P :<c-u>call wheel#line#paste_visual('before', 'open')<cr>
	endif
	" Undo, redo
	nnoremap <buffer> u <cmd>call wheel#mandala#undo()<cr>
	nnoremap <buffer> <c-r> <cmd>call wheel#mandala#redo()<cr>
	" Context menu
	let menu = 'yank/' .. a:mode
	call wheel#boomerang#launch_map (menu)
endfun

fun! wheel#clipper#template (settings)
	" Template
	let settings = a:settings
	let mode = settings.mode
	call wheel#mandala#template (settings)
	call wheel#clipper#options (mode)
	call wheel#clipper#mappings (mode)
	" selection
	call wheel#pencil#mappings ()
endfun

" Buffer

fun! wheel#clipper#yank (mode)
	" Choose yank and paste
	let mode = a:mode
	let lines = wheel#perspective#yank (mode)
	call wheel#mandala#blank ('yank/' .. mode)
	let settings = {'mode' : mode}
	call wheel#clipper#template(settings)
	call wheel#mandala#fill (lines)
	" yank ring is not related to any particular buffer
	let b:wheel_related_buffer = 'undefined'
	setlocal nomodified
	call cursor(1, 1)
	" reload
	let b:wheel_reload = 'wheel#clipper#yank(' .. string(mode) .. ')'
endfun
