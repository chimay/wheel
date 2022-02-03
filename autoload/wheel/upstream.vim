" vim: set ft=vim fdm=indent iskeyword&:

" Upstream
"
" Parent leaf properties for context menus
"
" See also boomerang

fun! wheel#upstream#has_filter ()
	" Whether parent leaf has filter
	let nature = wheel#book#previous('nature')
	return nature.has_filter
endfun

fun! wheel#upstream#is_filtered ()
	" Whether parent leaf is filtered
	let filter = wheel#book#previous('filter')
	return ! empty(filter.words)
endfun

fun! wheel#upstream#first_data_line ()
	" First data line of parent leaf
	" Return 1 if parent leaf has no filter, 2 otherwise
	if wheel#upstream#has_filter ()
		return 2
	else
		return 1
	endif
endfun

fun! wheel#upstream#is_selection_empty ()
	" Whether parent leaf has empty selection
	let selection = wheel#book#previous('selection')
	return empty(selection.indexes)
endfun

fun! wheel#upstream#line_index (linum)
	" Return index of parent line number in parent b:wheel_lines
	let linum = a:linum
	let shift = wheel#upstream#first_data_line ()
	let index = linum - shift
	let filter = wheel#book#previous('filter')
	if wheel#upstream#is_filtered ()
		let indexlist = filter.indexes
		return indexlist[index]
	else
		return index
	endif
endfun

fun! wheel#upstream#selection ()
	" Return selection of parent leaf or parent index & component if empty
	if wheel#upstream#is_selection_empty ()
		let cursor = wheel#book#previous('cursor')
		return cursor.selection
	endif
	return wheel#book#previous('selection')
endfun

" remove selection & related lines

fun! wheel#upstream#remove_selection ()
	" Parent leaf : remove selection & related lines
	" removed = selection lines or cursor component
	" e.g. : deleted buffers, closed tabs
	let lines = wheel#book#previous ('lines')
	let filter = wheel#book#previous ('filter')
	let selection = wheel#book#previous ('selection')
	let selection_or_cursor = wheel#upstream#selection ()
	" -- remove selection in lines & filter
	let indexlist = sort(copy(selection_or_cursor.indexes))
	let indexlist = reverse(indexlist)
	for index in indexlist
		eval lines->remove(index)
		if ! empty(filter.indexes)
			let where = filter.indexes->index(index)
			eval filter.indexes->remove(where)
			eval filter.lines->remove(where)
		endif
	endfor
	" -- clear selection
	let selection.indexes = []
	let selection.components = []
endfun
