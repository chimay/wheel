" vim: ft=vim fdm=indent:

" Yank wheel buffers

" Helpers

fun! wheel#clipper#options ()
	" Set local yank options
	setlocal nowrap
endfun

fun! wheel#clipper#maps (mode)
	" Define local yank maps
	if a:mode == 'list'
		nnoremap <buffer> <cr> :call wheel#line#paste_list ('after', 'close')<cr>
		nnoremap <buffer> g<cr> :call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_list ('after', 'open')<cr>
		nnoremap <buffer> P :call wheel#line#paste_list ('before', 'open')<cr>
	elseif a:mode == 'plain'
		nnoremap <buffer> <cr> :call wheel#line#paste_plain ('after', 'close')<cr>
		nnoremap <buffer> g<cr> :call wheel#line#paste_plain ('after', 'open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_plain ('after', 'open')<cr>
		nnoremap <buffer> P :call wheel#line#paste_plain ('before', 'open')<cr>
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
	call wheel#clipper#options ()
	call wheel#clipper#maps (settings.mode)
endfun

" Buffer

fun! wheel#clipper#yank (mode)
	" Choose yank and paste
	let mode = a:mode
	let lines = wheel#perspective#yank (mode)
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-yank-' . mode)
	let settings = {'mode' : mode}
	call wheel#clipper#template(settings)
	call wheel#mandala#fill (lines)
	setlocal nomodified
	call cursor(1,1)
endfun
