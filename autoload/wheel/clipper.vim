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
		nnoremap <buffer> <cr> :call wheel#line#paste_list ('close')<cr>
		nnoremap <buffer> <tab> :call wheel#line#paste_list ('open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_list ('open')<cr>
	elseif a:mode == 'plain'
		nnoremap <buffer> <cr> :call wheel#line#paste_plain ('close')<cr>
		nnoremap <buffer> <tab> :call wheel#line#paste_plain ('open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_plain ('open')<cr>
		" Visual mode
		vnoremap <buffer> <cr> :<c-u>call wheel#line#paste_visual('close')<cr>
		vnoremap <buffer> <tab> :<c-u>call wheel#line#paste_visual('open')<cr>
		vnoremap <buffer> p :<c-u>call wheel#line#paste_visual('open')<cr>
	endif
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
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-yank-' . mode)
	let settings = {'mode' : mode}
	call wheel#clipper#template(settings)
	let lines = wheel#perspective#yank (mode)
	call wheel#mandala#fill (lines)
	setlocal nomodified
	call cursor(1,1)
endfun
