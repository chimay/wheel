" vim: set ft=vim fdm=indent iskeyword&:

" Move to file & cursor position

" Like vortex.vim, but does not involve wheel elements
" switch to tag

fun! wheel#whirl#switch ()
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
	let type = fields[2]
	let line = fields[3][1:]
	execute 'edit' file
	" keep old position in mark '
	mark '
	call cursor(1,1)
	call search(line)
	return win_getid ()
endfun
