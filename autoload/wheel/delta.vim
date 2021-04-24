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
	let ampersands = {}
	for optname in s:diff_options
		let runme = 'let ampersands.' . optname . '=' . '&' . optname
		execute runme
	endfor
	return ampersands
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

fun! wheel#delta#restore_options (optdict)
	" Restore options to their state before diff
	let ampersands = a:optdict
	for optname in keys(ampersands)
		let runme = 'let &' . optname . '=' . string(ampersands[optname])
		execute runme
	endfor
	return ampersands
endfun
