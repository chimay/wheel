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
	call filter(lines, {_,val -> val !~ '\m^!'})
	let table = []
	for record in lines
		let fields = split(record, "\t")
		let start = match(fields, '\m^/')
		let end = match(fields, '\m/;"$')
		if end < 0
			let end = match(fields, '\m/$')
		endif
		let pattern = [join(fields[start:end])]
		let fused = fields[0:start - 1] + pattern + fields[end+1:]
		" title, file, type, search pattern
		let entry = fused[0:1] + [fused[3]] + [fused[2]]
		call add(table, entry)
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
