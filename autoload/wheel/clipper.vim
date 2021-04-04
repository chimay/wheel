" vim: ft=vim fdm=indent:

" Yank wheel special buffers

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
		nnoremap <buffer> <cr> :call wheel#line#paste_list ('after', 'close')<cr>
		nnoremap <buffer> g<cr> :call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> P :call wheel#line#paste_list ('before', 'open')<cr>
	elseif a:mode == 'plain'
		" normal mode
		nnoremap <buffer> <cr> :call wheel#line#paste_plain ('linewise_after', 'close')<cr>
		nnoremap <buffer> g<cr> :call wheel#line#paste_plain ('linewise_after', 'open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_plain ('linewise_after', 'open')<cr>
		nnoremap <buffer> P :call wheel#line#paste_plain ('linewise_before', 'open')<cr>
		nnoremap <buffer> gp :call wheel#line#paste_plain ('character_after', 'open')<cr>
		nnoremap <buffer> gP :call wheel#line#paste_plain ('character_before', 'open')<cr>
		" Visual mode
		vnoremap <buffer> <cr> :<c-u>call wheel#line#paste_visual('after', 'close')<cr>
		vnoremap <buffer> g<cr> :<c-u>call wheel#line#paste_visual('after', 'open')<cr>
		vnoremap <buffer> p :<c-u>call wheel#line#paste_visual('after', 'open')<cr>
		vnoremap <buffer> P :<c-u>call wheel#line#paste_visual('before', 'open')<cr>
	endif
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('yank')<cr>
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
	call wheel#mandala#open ('yank/' . mode)
	let settings = {'mode' : mode}
	call wheel#clipper#template(settings)
	call wheel#mandala#fill (lines)
	setlocal nomodified
	call cursor(1,1)
endfun
