" vim: ft=vim fdm=indent:

" Most recently used files

" Helpers

fun! wheel#attic#remove_if_present (entry)
	let entry = a:entry
	let attic = g:wheel_attic
	for elem in g:wheel_attic
		if elem.file ==# entry.file
			let g:wheel_attic = wheel#chain#remove_element(elem, attic)
		endif
	endfor
endfu

" Operations

fun! wheel#attic#record (...)
	" Add file path to most recently used file list
	" Optional argument :
	" - full path of file
	" - current file by default
	" Add new entry at the beginning of the list
	" Move existing entry at the beginning of the list
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%:p')
	endif
	if empty(filename)
		" Do not add empty filenames
		return
	endif
	let wheel_files = wheel#helix#files ()
	let in_wheel = index(wheel_files, filename)
	if in_wheel >= 0
		" Only add non wheel files
		return
	endif
	let attic = g:wheel_attic
	let entry = {}
	let entry.file = filename
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#attic#remove_if_present (entry)
	let g:wheel_attic = insert(g:wheel_attic, entry, 0)
	let max = g:wheel_config.maxim.mru
	let g:wheel_attic = g:wheel_attic[:max - 1]
endfu

" Presentation

fun! wheel#attic#sorted ()
	" Sorted most recenty used files index
	" Each entry is a string : date hour | filename
	let attic = deepcopy(g:wheel_attic)
	let Compare = function('wheel#pendulum#compare')
	let attic = sort(attic, Compare)
	let strings = []
	for entry in attic
		let filename = entry.file
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour . ' | '
		let entry .= filename
		let strings = add(strings, entry)
	endfor
	return strings
endfu

