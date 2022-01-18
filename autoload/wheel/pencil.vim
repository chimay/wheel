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

fun! wheel#pencil#is_selected (line)
	" Whether line is selected
	return a:line =~ s:selected_pattern
endfun

fun! wheel#pencil#draw (line)
	" Return marked line
	let line = a:line
	if wheel#pencil#is_selected (line)
		return line
	endif
	return substitute(line, '\m^', s:selected_mark, '')
endfun

fun! wheel#pencil#erase (line)
	" Return unmarked line
	let line = a:line
	if ! wheel#pencil#is_selected (line)
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
		return [wheel#line#address ()]
	elseif type(addresses) == v:t_list
		return addresses
	else
		echomsg 'wheel mandala selected : bad format for b:wheel_selected'
		return []
	endif
endfun

" current line

fun! wheel#pencil#select ()
	" Select current line
	let line = getline('.')
	if empty(line)
		return v:false
	endif
	if wheel#pencil#is_selected (line)
		return v:false
	endif
	" ---- update buffer line
	let marked_line = wheel#pencil#draw (line)
	call setline('.', marked_line)
	" ---- update b:wheel_selection
	let selection = b:wheel_selection
	let linum = line('.')
	let address = wheel#line#address ()
	" -- shift between b:wheel_lines indexes and buffer line numbers
	let shift = wheel#teapot#first_data_line ()
	" -- indexes
	let index = wheel#teapot#index ()
	eval selection.indexes->add(index)
	" -- address
	eval selection.addresses->add(address)
	" -- coda
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear ()
	" Deselect current line
	let line = getline('.')
	if empty(line)
		return v:false
	endif
	if ! wheel#pencil#is_selected (line)
		return v:false
	endif
	" ---- update buffer line
	let unmarked_line = wheel#pencil#erase (line)
	call setline('.', unmarked_line)
	" ---- update b:wheel_selection
	let selection = b:wheel_selection
	let linum = line('.')
	let address = wheel#line#address ()
	" -- indexes
	let index = wheel#teapot#index ()
	let found = selection.indexes->index(index)
	eval selection.indexes->remove(found)
	eval selection.addresses->remove(found)
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle ()
	" Toggle selection of current line
	let line = getline('.')
	if wheel#pencil#is_selected (line)
		call wheel#pencil#clear ()
	else
		call wheel#pencil#select ()
	endif
	setlocal nomodified
	return v:true
endfun

" visible, filtered lines

fun! wheel#pencil#select_visible ()
	" Select visible, filtered lines
	let begin = wheel#teapot#first_data_line ()
	let buflines = getline(begin, '$')
	" save cursor position
	let position = getcurpos()
	" select
	for index in range(len(buflines))
		let linum = index + begin
		call cursor(linum, 1)
		call wheel#pencil#select ()
	endfor
	call wheel#gear#restore_cursor (position)
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear_visible ()
	" Deselect visible, filtered lines
	let begin = wheel#teapot#first_data_line ()
	let buflines = getline(begin, '$')
	" save cursor position
	let position = getcurpos()
	" select
	for index in range(len(buflines))
		let linum = index + begin
		call cursor(linum, 1)
		call wheel#pencil#clear ()
	endfor
	call wheel#gear#restore_cursor (position)
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle_visible ()
	" Toggle visible, filtered lines
	let begin = wheel#teapot#first_data_line ()
	let buflines = getline(begin, '$')
	" save cursor position
	let position = getcurpos()
	" select
	for index in range(len(buflines))
		let linum = index + begin
		call cursor(linum, 1)
		call wheel#pencil#toggle ()
	endfor
	call wheel#gear#restore_cursor (position)
	setlocal nomodified
	return v:true
endfun
