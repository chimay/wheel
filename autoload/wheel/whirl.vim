" vim: set ft=vim fdm=indent iskeyword&:

" Switch with native (neo)vim functions
"
" Move to file & cursor position

" Like vortex.vim, but does not involve wheel elements

" script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" main

fun! wheel#whirl#marker ()
	" Switch to marker
	let prompt = 'Switch to marker : '
	let complete =  'customlist,wheel#completelist#markers'
	let record = input(prompt, '', complete)
	let fields = split(record, s:field_separ)
	let mark = fields[0][1:]
	execute "normal `" .. mark
	return win_getid ()
endfun

fun! wheel#whirl#jump ()
	" Switch to jump
	let prompt = 'Switch to jump : '
	let complete =  'customlist,wheel#completelist#jumps'
	let record = input(prompt, '', complete)
	let fields = split(record, s:field_separ)
	let bufnum = fields[0]
	let linum = str2nr(fields[1])
	let colnum = str2nr(fields[2])
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	return win_getid ()
endfun

fun! wheel#whirl#change ()
	" Switch to change
	let prompt = 'Switch to change : '
	let complete =  'customlist,wheel#completelist#changes'
	let record = input(prompt, '', complete)
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	call cursor(linum, colnum)
	return win_getid ()
endfun

fun! wheel#whirl#tag ()
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
