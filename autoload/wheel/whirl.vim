" vim: set ft=vim fdm=indent iskeyword&:

" Move to file & cursor position

" Like vortex.vim, but does not involve wheel elements
" switch to tag

" script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" main

fun! wheel#whirl#tags ()
	" Switch to tag
	let prompt = 'Switch to tag : '
	let complete =  'customlist,wheel#completelist#tags'
	let record = input(prompt, '', complete)
	let fields = split(record, s:field_separ)
	if len(fields) < 4
		echomsg 'Tag line is too short'
		return v:false
	endif
	let ident = fields[0]
	let file = fields[1]
	let line = fields[2][1:]
	execute 'edit' file
	" keep old position in mark '
	mark '
	call cursor(1,1)
	call search(line)
	return win_getid ()
endfun
