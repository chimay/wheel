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

fun! wheel#clipper#maps (mode)
	" Define local yank maps
	if a:mode == 'list'
		nnoremap <buffer> <cr> <cmd>call wheel#line#paste_list ('after', 'close')<cr>
		nnoremap <buffer> g<cr> <cmd>call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> p <cmd>call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> P <cmd>call wheel#line#paste_list ('before', 'open')<cr>
	elseif a:mode == 'plain'
		" normal mode
		nnoremap <buffer> <cr> <cmd>call wheel#line#paste_plain ('linewise_after', 'close')<cr>
		nnoremap <buffer> g<cr> <cmd>call wheel#line#paste_plain ('linewise_after', 'open')<cr>
		nnoremap <buffer> p <cmd>call wheel#line#paste_plain ('linewise_after', 'open')<cr>
		nnoremap <buffer> P <cmd>call wheel#line#paste_plain ('linewise_before', 'open')<cr>
		nnoremap <buffer> gp <cmd>call wheel#line#paste_plain ('charwise_after', 'open')<cr>
		nnoremap <buffer> gP <cmd>call wheel#line#paste_plain ('charwise_before', 'open')<cr>
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
	let pre = 'nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('
	let post = ')<cr>'
	let menu = 'yank/' .. a:mode
	execute pre .. string(menu) .. post
endfun

fun! wheel#clipper#template (settings)
	" Template
	let settings = a:settings
	call wheel#mandala#template (settings)
	call wheel#clipper#options (settings.mode)
	call wheel#clipper#maps (settings.mode)
endfun

" Buffer

fun! wheel#clipper#yank (mode)
	" Choose yank and paste
	let mode = a:mode
	let lines = wheel#perspective#yank (mode)
	call wheel#vortex#update ()
	call wheel#mandala#open ('yank/' .. mode)
	let settings = {'mode' : mode}
	call wheel#clipper#template(settings)
	call wheel#mandala#fill (lines)
	setlocal nomodified
	call cursor(1,1)
	" reload
	let b:wheel_reload = 'wheel#clipper#yank(' .. string(mode) .. ')'
endfun
