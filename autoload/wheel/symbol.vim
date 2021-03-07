" vim: ft=vim fdm=indent:

" Tags

fun! wheel#symbol#files ()
	" Tags file(s) related to current directory
	let files = tagfiles ()
	" No emacs TAGS
	call filter(files, {_, val -> val !=# 'TAGS' })
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
	if file =~ '\m/'
		" If tagfile is not in project root dir, we need the full path
		let tagdir = fnamemodify(file, ':p:h') . '/'
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
		let optional = matchstr(pattern, final, '', '')
		let optional = substitute(optional, '\m^\t', '', '')
		let pattern = substitute(pattern, remove, '', '')
		let record = substitute(record, regex, '', '')
		let fields = split(record, "\t")
		let fields[1] = tagdir . fields[1]
		call add(fields, optional)
		call add(fields, pattern)
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
