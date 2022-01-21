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

fun! wheel#boomerang#is_parent_selection_empty ()
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

fun! wheel#boomerang#selection ()
	" Return selection of parent leaf
	" If empty, return index & address parent line
	if wheel#boomerang#is_parent_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		let linum = cursor.position[1]
		let parent_line_index = wheel#branch#line_index (linum)
		let selection = {}
		let selection.indexes = [ line_index ]
		let selection.addresses = [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous('selection'))
	endif
	return selection
endfun

fun! wheel#boomerang#addresses ()
	" Return selected addresses of parent leaf
	" If empty, return address of parent line
	if wheel#pencil#is_selection_empty ()
		echomsg 'wheel boomerang addresses : selection should not be empty'
		call wheel#boomerang#sync_from_parent ()
	endif
	return b:wheel_selection.addresses
endfun
