" vim: ft=vim fdm=indent:

" Undo & diff

" Script constants

if ! exists('s:diff_options')
	let s:diff_options = wheel#crystal#fetch('diff/options')
	lockvar s:diff_options
endif

" Diff options

fun! wheel#delta#save_options ()
	" Save options before activating diff
	let b:wheel_options = wheel#gear#save_options (s:diff_options)
endfun

fun! wheel#delta#diff_options ()
	" Activate diff options
	setlocal diff
	setlocal scrollbind
	setlocal cursorbind
	setlocal scrollopt+=hor
	setlocal nowrap
	setlocal foldmethod=diff
	setlocal foldcolumn=2
endfun

fun! wheel#delta#restore_options ()
	" Restore options to their state before diff
	call wheel#gear#restore_options (b:wheel_options)
endfun

" Maps

fun! wheel#delta#maps (winiden)
	" Maps for undo list mandala
	let map  =  'nnoremap <silent> <buffer> '
	let pre  = ' :call wheel#line#undolist('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(a:winiden) . post
endfun

" Undo list mandala

fun! wheel#delta#undolist ()
	" Undo list mandala
	let lines = wheel#perspective#undolist ()
	let winiden = win_getid ()
	call wheel#vortex#update ()
	call wheel#mandala#open('undo')
	call wheel#mandala#template ()
	call wheel#delta#maps (winiden)
	call wheel#mandala#fill(lines)
endfun
