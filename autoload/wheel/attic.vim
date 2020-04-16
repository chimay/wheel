" vim: ft=vim fdm=indent:

" Most recently used files

fun! wheel#attic#remove_if_present (entry)
	let entry = a:entry
	let attic = g:wheel_attic
	for elem in g:wheel_attic
		if elem.file ==# entry.file
			let g:wheel_attic = wheel#chain#remove_element(elem, attic)
		endif
	endfor
endfu

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
		let filename = expand('%:p:h')
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
