" vim: set ft=vim fdm=indent iskeyword&:

" Most recently used files

" Script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

" Helpers

fun! wheel#attic#remove_if_present (entry)
	" Remove entry from mru if file is already there
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
		return v:false
	endif
	if wheel#referen#is_in_wheel ()
		" Only add non wheel files
		return v:false
	endif
	if filename =~ s:is_mandala_file
		" Do not add mandala buffer
		return v:false
	endif
	if filename =~ '^term://'
		" Do not add term buffer
		return v:false
	endif
	let attic = g:wheel_attic
	let entry = {}
	let entry.file = filename
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#attic#remove_if_present (entry)
	let g:wheel_attic = insert(g:wheel_attic, entry)
	let max = g:wheel_config.maxim.mru
	let g:wheel_attic = g:wheel_attic[:max - 1]
	return v:true
endfu
