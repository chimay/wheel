" vim: set ft=vim fdm=indent iskeyword&:

" Attic
"
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
			eval g:wheel_attic->wheel#chain#remove_element(elem)
		endif
	endfor
endfun

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
	" ---- do not add empty filenames
	if empty(filename)
		return v:false
	endif
	" ---- only add non wheel files
	if wheel#referen#is_in_wheel ()
		return v:false
	endif
	" ---- do not add mandala buffer
	let bufnum = bufnr('%')
	let mandalas = g:wheel_bufring.mandalas
	if wheel#chain#is_inside(bufnum, mandalas)
		return v:false
	endif
	" ---- do not add mandala filename
	if filename =~ s:is_mandala_file
		return v:false
	endif
	" ---- do not add term buffer
	if filename =~ '^term://'
		return v:false
	endif
	" ---- record file
	let attic = g:wheel_attic
	let entry = {}
	let entry.file = filename
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#attic#remove_if_present (entry)
	let g:wheel_attic = insert(g:wheel_attic, entry)
	let max = g:wheel_config.maxim.mru
	let g:wheel_attic = g:wheel_attic[:max - 1]
	return v:true
endfun
