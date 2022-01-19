" vim: set ft=vim fdm=indent iskeyword&:

" Selection in mandalas

" Script constants

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" helpers

fun! wheel#pencil#is_selection_empty ()
	" Whether selection is empty
	return empty(b:wheel_selection.indexes)
endfun

fun! wheel#pencil#is_selected (...)
	" Whether line is selected
	" Optional argument : line number
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let index = wheel#teapot#line_index (linum)
	let reference = b:wheel_selection.indexes
	return index->wheel#chain#is_inside(reference)
endfun

fun! wheel#pencil#has_selection_mark (line)
	" Whether line has selection mark
	return a:line =~ s:selected_pattern
endfun

" add / remove mark

fun! wheel#pencil#draw (line)
	" Return marked line
	let line = a:line
	if wheel#pencil#has_selection_mark (line)
		return line
	endif
	return substitute(line, '\m^', s:selected_mark, '')
endfun

fun! wheel#pencil#erase (line)
	" Return unmarked line
	let line = a:line
	if ! wheel#pencil#has_selection_mark (line)
		return line
	endif
	return substitute(line, s:selected_pattern, '', '')
endfun

" selection addresses

fun! wheel#pencil#selected ()
	" Return selected addresses
	" If empty, return address of current line
	let addresses = b:wheel_selection.addresses
	if empty(addresses)
		return [ wheel#line#address () ]
	elseif type(addresses) == v:t_list
		return addresses
	else
		echomsg 'wheel pencil selected : bad selection addresses'
		return []
	endif
endfun

" current line

fun! wheel#pencil#select (...)
	" Select line
	" Optional argument : line number
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let line = getline(linum)
	if empty(line)
		return v:false
	endif
	if wheel#pencil#is_selected (linum)
		return v:false
	endif
	" ---- update b:wheel_selection
	let selection = b:wheel_selection
	let address = wheel#line#address (linum)
	" -- shift between b:wheel_lines indexes and buffer line numbers
	let shift = wheel#teapot#first_data_line ()
	" -- global index of current line in b:wheel_lines
	let index = wheel#teapot#line_index (linum)
	eval selection.indexes->add(index)
	" -- address
	eval selection.addresses->add(address)
	" ---- update buffer line
	let marked_line = wheel#pencil#draw (line)
	call setline(linum, marked_line)
	" ---- coda
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear (...)
	" Deselect line
	" Optional argument : line number
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let line = getline(linum)
	if empty(line)
		return v:false
	endif
	if ! wheel#pencil#is_selected (linum)
		return v:false
	endif
	" ---- update b:wheel_selection
	let selection = b:wheel_selection
	let address = wheel#line#address (linum)
	" -- indexes
	let index = wheel#teapot#line_index (linum)
	let found = selection.indexes->index(index)
	eval selection.indexes->remove(found)
	eval selection.addresses->remove(found)
	" ---- update buffer line
	let unmarked_line = wheel#pencil#erase (line)
	call setline(linum, unmarked_line)
	" ---- coda
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle (...)
	" Toggle selection of line
	" Optional argument : line number
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	if wheel#pencil#is_selected (linum)
		call wheel#pencil#clear (linum)
	else
		call wheel#pencil#select (linum)
	endif
	setlocal nomodified
	return v:true
endfun

" visible lines in the mandala, filtered or not

fun! wheel#pencil#select_visible ()
	" Select all visible, filtered lines
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	for linum in range(start, lastline)
		call wheel#pencil#select (linum)
	endfor
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear_visible ()
	" Deselect all visible, filtered lines
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	for linum in range(start, lastline)
		call wheel#pencil#clear (linum)
	endfor
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle_visible ()
	" Toggle all visible, filtered lines
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	for linum in range(start, lastline)
		call wheel#pencil#toggle (linum)
	endfor
	setlocal nomodified
	return v:true
endfun

" hide & show

fun! wheel#pencil#hide ()
	" Remove selected mark from all visible lines
	" This does not clear the selection
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	let linelist = getline(start, '$')
	for linum in range(start, lastline)
		let line = getline(linum)
		let cleared = wheel#pencil#erase (line)
		call setline(linum, cleared)
	endfor
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#show ()
	" Add selected mark to all selected lines
	" This does not alter the selection
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	let linelist = getline(start, '$')
	let reference = b:wheel_selection.indexes
	for linum in range(start, lastline)
		let index = wheel#teapot#line_index (linum)
		let inside = index->wheel#chain#is_inside(reference)
		if inside
			let line = getline(linum)
			let drawed = wheel#pencil#draw (line)
			call setline(linum, drawed)
		endif
	endfor
	setlocal nomodified
	return v:true
endfun
