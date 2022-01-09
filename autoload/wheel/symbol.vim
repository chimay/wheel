" vim: set ft=vim fdm=indent iskeyword&:

" Tags

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" functions

fun! wheel#symbol#files ()
	" Tags file(s) related to current directory
	let files = tagfiles ()
	" no emacs TAGS
	call filter(files, {_, val -> val !=# 'TAGS' })
	return files
endfun

fun! wheel#symbol#read (file)
	" Read tags file
	let file = expand(a:file)
	if filereadable(file)
		let lines = readfile(file)
	else
		echomsg 'wheel symbol read : tags file non readable'
	endif
	if file =~ '\m/'
		" if tagfile is not in project root dir, we need the full path
		let tagdir = fnamemodify(file, ':p:h') .. '/'
	else
		let tagdir = ''
	endif
	call filter(lines, {_,val -> val !~ '\m^!_TAG_'})
	let table = []
	let regex =  '\m^[^\t]\+\t[^\t]\+\t\zs.\+\ze'
	let final = '\m/\%(;"\)\?\zs[^/;"]*\ze$'
	let remove = '\m/\%(;"\)\?[^/;"]*$'
	for record in lines
		let pattern = matchstr(record, regex)
		let optional = matchstr(pattern, final)
		let optional = substitute(optional, '\m^\t', '', '')
		let pattern = substitute(pattern, remove, '', '')
		let record = substitute(record, regex, '', '')
		let fields = split(record, "\t")
		let fields[1] = tagdir .. fields[1]
		call add(fields, pattern)
		call add(fields, optional)
		call add(table, fields)
	endfor
	return table
endfun

fun! wheel#symbol#table ()
	" Table containing all records in tags file(s)
	let tagfiles = wheel#symbol#files ()
	let table = []
	for file in tagfiles
		let grid = wheel#symbol#read (file)
		call extend(table, grid)
	endfor
	return table
endfun

" switch to tag

fun! wheel#symbol#switch ()
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
