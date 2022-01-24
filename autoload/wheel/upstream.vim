" vim: set ft=vim fdm=indent iskeyword&:

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
	" Return selection of parent leaf
	" If empty, return index & address parent line
	if wheel#upstream#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		let linum = cursor.position[1]
		let line_index = wheel#upstream#line_index (linum)
		let selection = {}
		let selection.indexes = [ line_index ]
		let selection.addresses = [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous('selection'))
	endif
	return selection
endfun

fun! wheel#upstream#addresses ()
	" Return selection addresses of parent leaf
	" If empty, return address of parent line
	if wheel#upstream#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		return [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous('selection'))
		return selection.addresses
	endif
endfun

" remove selection & related lines

fun! wheel#upstream#remove_selection ()
	" Parent leaf : remove selection & related lines
	" removed = selection lines or cursor address
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
	let selection.addresses = []
endfun
