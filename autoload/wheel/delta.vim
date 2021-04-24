" vim: ft=vim fdm=indent:

" Undo & diff

" Script constants

if ! exists('s:diff_options')
	let s:diff_options = wheel#crystal#fetch('diff/options')
	lockvar s:diff_options
endif

" Helpers

fun! wheel#delta#save_options ()
	" Save options before activating diff
	let ampersands = {}
	for optname in s:diff_options
		let runme = 'let ampersands.' . optname . '=' . '&' . optname
		execute runme
	endfor
	return ampersands
endfun
