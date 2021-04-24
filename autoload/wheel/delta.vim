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
