" vim: ft=vim fdm=indent:

" Tags

fun! wheel#symbol#files ()
	" Tags file(s) related to current directory
	let files = tagfiles ()
	return files
endfun

fun! wheel#symbol#read (file)
	" Read tags file
	let file = expand(a:file)
	if filereadable(file)
		let lines = readfile(file)
	else
		echomsg 'Wheel symbol read : tags file non readable'
	endif
	call filter(lines, {_,val -> val !~ '\m^!'})
	let table = []
	for record in lines
		let fields = split(record, "\t")
		call add(table, fields)
	endfor
	return table
endfun

fun! wheel#symbol#load ()
	" Load tags file(s)
	let tagfiles = wheel#symbol#files ()
	let table = []
	for file in tagfiles
		let grid = wheel#symbol#read (file)
		call extend(table, grid)
	endfor
	return table
endfun
