" vim: ft=vim fdm=indent:

" Tags

fun! wheel#symbol#files ()
	" Tags file(s) related to current directory
	" All built in
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
	if file =~ '\m/'
		" If tagfile is not in project root dir, we need the full path
		let tagdir = fnamemodify(file, ':p:h') . '/'
	else
		let tagdir = ''
	endif
	call filter(lines, {_,val -> val !~ '\m^!'})
	let table = []
	let regex =  '\m\t/\zs[^/]\+\ze/\(;"\)\?\t'
	let to_replace =  '\m\t\zs/[^/]\+/\(;"\)\?\t\ze'
	for record in lines
		let pattern = matchstr(record, regex)
		let record = substitute(record, to_replace, '', '')
		let fields = split(record, "\t")
		let fields[1] = tagdir . fields[1]
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

fun! wheel#symbol#mandala ()
	" Lines to be displayed in special buffer
	let table = wheel#symbol#table ()
	let lines = []
	for record in table
		let suit = join(record, ' | ')
		call add(lines, suit)
	endfor
	return lines
endfun
