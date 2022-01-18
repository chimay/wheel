" vim: set ft=vim fdm=indent iskeyword&:

" Filter routines for mandalas

fun! wheel#teapot#has_filter ()
	" Return true if mandala has filter in first line, false otherwise
	return b:wheel_nature.has_filter
endfun

fun! wheel#teapot#index ()
	" Return index of line number in b:wheel_lines
	" Default : current line number
	if a:0 > 1
		let linum = a:1
	else
		let linum = line('.')
	endif
	let shift = wheel#mandala#first_data_line ()
	let index = linum - shift
	if wheel#mandala#is_filtered ()
		let indexlist = b:wheel_filter.indexes
		return indexlist[index]
	else
		return index
	endif
endfun

