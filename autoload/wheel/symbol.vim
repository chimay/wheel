" vim: set ft=vim fdm=indent iskeyword&:

" Symbol
"
" Tags

fun! wheel#symbol#files ()
	" Tags file(s) related to current directory
	let files = tagfiles ()
	" no emacs TAGS
	eval files->filter({ _, val -> val !=# 'TAGS' })
	return files
endfun

fun! wheel#symbol#read (file)
	" Read tags file
	let file = fnamemodify(a:file, ':p')
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
	eval lines->filter({ _,val -> val !~ '\m^!_TAG_' })
	let table = []
	let regex = '\m^[^\t]\+\t[^\t]\+\t\zs.\+\ze'
	let final = '\m/\%(;"\)\?\zs[^/;"]*\ze$'
	let remove = '\m/\%(;"\)\?[^/;"]*$'
	for record in lines
		let pattern = matchstr(record, regex)
		let optional = matchstr(pattern, final)
		let optional = substitute(optional, '\m^\t', '', '')
		let pattern = substitute(pattern, remove, '', '')
		let pattern = escape(pattern, '*')
		let record = substitute(record, regex, '', '')
		let fields = split(record, "\t")
		let fields[1] = tagdir .. fields[1]
		eval fields->add(pattern)
		eval fields->add(optional)
		eval table->add(fields)
	endfor
	return table
endfun

fun! wheel#symbol#table ()
	" Table containing all records in tags file(s)
	let tagsfiles = wheel#symbol#files ()
	let table = []
	for file in tagsfiles
		let grid = wheel#symbol#read (file)
		call extend(table, grid)
	endfor
	return table
endfun
