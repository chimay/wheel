" vim: set ft=vim fdm=indent iskeyword&:

" Parent leaf properties for context menus
"
" See also boomerang

fun! wheel#branch#has_filter ()
	" Whether parent leaf has filter
	let nature = wheel#book#previous('nature')
	return nature.has_filter
endfun

fun! wheel#branch#is_filtered ()
	" Whether parent leaf is filtered
	let filter = wheel#book#previous('filter')
	return ! empty(filter.words)
endfun

fun! wheel#branch#first_data_line ()
	" First data line of parent leaf
	" Return 1 if parent leaf has no filter, 2 otherwise
	if wheel#branch#has_filter ()
		return 2
	else
		return 1
	endif
endfun

fun! wheel#branch#is_selection_empty ()
	" Whether parent leaf has empty selection
	let selection = wheel#book#previous('selection')
	return empty(selection.indexes)
endfun

fun! wheel#branch#line_index (linum)
	" Return index of parent line number in parent b:wheel_lines
	let linum = a:linum
	let shift = wheel#branch#first_data_line ()
	let index = linum - shift
	let filter = wheel#book#previous('filter')
	if wheel#branch#is_filtered ()
		let indexlist = filter.indexes
		return indexlist[index]
	else
		return index
	endif
endfun

fun! wheel#branch#selection ()
	" Return selection of parent leaf
	" If empty, return index & address parent line
	if wheel#branch#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		let linum = cursor.position[1]
		let line_index = wheel#branch#line_index (linum)
		let selection = {}
		let selection.indexes = [ line_index ]
		let selection.addresses = [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous('selection'))
	endif
	return selection
endfun

fun! wheel#branch#addresses ()
	" Return selected addresses of parent leaf
	" If empty, return address of parent line
	if wheel#branch#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		return [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous('selection'))
		return selection.addresses
	endif
endfun

" remove selection & related lines

fun! wheel#branch#remove_selection ()
	" Parent leaf : remove selection & related lines, reset filter
	" removed = selected lines or cursor address
	" e.g. : deleted buffers, closed tabs
	let lines = wheel#book#previous ('lines')
	let filter = wheel#book#previous ('filter')
	let selection = wheel#book#previous ('selection')
	let selection_or_cursor = wheel#branch#selection ()
	" -- clear lines in parent leaf
	let indexlist = sort(copy(selection_or_cursor.indexes))
	let indexlist = reverse(indexlist)
	for index in indexlist
		eval lines->remove(index)
	endfor
	" -- clear selection
	let selection.indexes = []
	let selection.addresses = []
	" -- clear filter
	let filter.words = []
	let filter.indexes = []
	let filter.lines = []
endfun
