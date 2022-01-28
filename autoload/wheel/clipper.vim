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
		let paste = 'wheel#line#paste_list'
	elseif a:mode == 'plain'
		let paste = 'wheel#line#paste_plain'
	endif
	" -- normal mode
	let nmap = 'nnoremap <buffer>'
	exe nmap '<cr>  <cmd>call' paste "('linewise_after', 'close')<cr>"
	exe nmap 'g<cr> <cmd>call' paste "('linewise_after', 'open')<cr>"
	exe nmap 'p     <cmd>call' paste "('linewise_after', 'open')<cr>"
	exe nmap 'P     <cmd>call' paste "('linewise_before', 'open')<cr>"
	exe nmap 'gp    <cmd>call' paste "('charwise_after', 'open')<cr>"
	exe nmap 'gP    <cmd>call' paste "('charwise_before', 'open')<cr>"
	" -- visual mode
	if a:mode == 'plain'
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
