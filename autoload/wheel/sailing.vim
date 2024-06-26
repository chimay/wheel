" vim: set ft=vim fdm=indent iskeyword&:

" Sailing
"
" Native navigation, prompt functions
"
" Like vortex.vim, but does not involve wheel elements

" ---- script constants

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- main

fun! wheel#sailing#find (...)
	" Add file to circle
	if a:0 > 0
		let file = a:1
	else
		let prompt = 'Find file to edit ? '
		let complete = 'customlist,wheel#complete#file'
		let file = input(prompt, '', complete)
	endif
	if empty(file)
		return -1
	endif
	execute 'hide edit' file
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#mru ()
	" Switch to most recently used non-wheel file
	let prompt = 'Switch to mru file : '
	let complete = 'customlist,wheel#complete#mru'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let filename = fields[1]
	execute 'hide edit' filename
	normal! '"
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#occur ()
	" Switch to line
	let prompt = 'Switch to line : '
	let complete = 'customlist,wheel#complete#line'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	call cursor(linum, 1)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#buffer ()
	" Switch to buffer
	let prompt = 'Switch to buffer : '
	let complete = 'customlist,wheel#complete#buffer'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let bufnum = fields[0]
	execute 'hide buffer' bufnum
	let linum = str2nr(fields[1])
	call cursor(linum, 1)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#tabwin ()
	" Switch to tab & window of visible buffer
	let prompt = 'Switch to visible buffer : '
	let complete = 'customlist,wheel#complete#visible_buffer'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let tabnum = fields[0]
	let winum = fields[1]
	doautocmd BufLeave
	execute 'noautocmd tabnext' tabnum
	execute 'noautocmd' winum 'wincmd w'
	doautocmd WinEnter
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#marker ()
	" Switch to marker
	let prompt = 'Switch to marker : '
	let complete = 'customlist,wheel#complete#marker'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let mark = fields[0]
	execute "normal `" .. mark
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#jump ()
	" Switch to jump
	let prompt = 'Switch to jump : '
	let complete = 'customlist,wheel#complete#jump'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let bufnum = fields[0]
	let linum = str2nr(fields[1])
	let colnum = str2nr(fields[2])
	execute 'hide buffer' bufnum
	call cursor(linum, colnum)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#change ()
	" Switch to change
	let prompt = 'Switch to change : '
	let complete = 'customlist,wheel#complete#change'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	call cursor(linum, colnum)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#tag ()
	" Switch to tag
	let prompt = 'Switch to tag : '
	let complete = 'customlist,wheel#complete#tag'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	if len(fields) < 4
		echomsg 'Tag line is too short'
		return v:false
	endif
	let ident = fields[0]
	let file = fields[1]
	let line = fields[2][1:]
	execute 'hide edit' file
	let found = search(line, 'sw')
	if found == 0
		echomsg 'wheel : tag not found : maybe you should update your tag file'
	endif
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#sailing#outline ()
	" Go to outline
	let filetype = &filetype
	let modedict = { 1 : 'folds', 2 : 'markdown', 3 : 'org', 4 : 'vimwiki' }
	if filetype == 'markdown'
		let mode = 2
	elseif filetype == 'org'
		let mode = 3
	elseif filetype == 'vimwiki'
		let mode = 4
	else
		let mode = 1
		"let prompt = 'Outline mode ? '
		"let mode = confirm(prompt, "&Folds\n&Markdown\n&Org mode\nVimwiki", 1)
	endif
	let prompt = 'Go to outline : '
	let complete = 'customlist,wheel#complete#outline_' .. modedict[mode]
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	if len(fields) < 5
		echomsg 'Outline line is too short'
		return v:false
	endif
	let line = str2nr(fields[1])
	let col  = str2nr(fields[2])
	let file = fields[3]
	execute 'silent hide edit' file
	call cursor(line, col)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun
