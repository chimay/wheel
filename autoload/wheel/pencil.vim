" vim: ft=vim fdm=indent:

" Selection in mandalas

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" Helpers

fun! wheel#pencil#sync_select ()
	" Sync b:wheel_selected to buffer lines
	let position = getcurpos()
	for linum in range(line('$'))
		call cursor(linum, 1)
		let line = getline('.')
		if empty(line)
			continue
		endif
		if line !~ s:selected_pattern
			let record = line
		else
			let record = substitute(line, s:selected_pattern, '', '')
		endif
		let address = wheel#line#address ()
		let index = index(b:wheel_selected, address)
		if index >= 0
			let selected_line = substitute(record, '\m^', s:selected_mark, '')
			call setline('.', selected_line)
			" Mark line as selected in b:wheel_lines
			let pos = index(b:wheel_lines, line)
			let b:wheel_lines[pos] = selected_line
		else
			call setline('.', record)
			" Unmark line in b:wheel_lines
			let pos = index(b:wheel_lines, line)
			let b:wheel_lines[pos] = record
		endif
	endfor
	call wheel#gear#restore_cursor (position)
endfun

" Selection

fun! wheel#pencil#select ()
	" Select current line
endfun

fun! wheel#pencil#deselect ()
	" Deselect current line
endfun

fun! wheel#pencil#toggle ()
	" Toggle selection of current line
	let line = getline('.')
	if empty(line)
		return v:false
	endif
	if line !~ s:selected_pattern
		let record = line
	else
		let record = substitute(line, s:selected_pattern, '', '')
	endif
	let address = wheel#line#address ()
	let index = index(b:wheel_selected, address)
	if index < 0
		" select
		call add(b:wheel_selected, address)
		let selected_line = substitute(line, '\m^', s:selected_mark, '')
		call setline('.', selected_line)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = selected_line
	else
		" deselect
		call remove(b:wheel_selected, index)
		call setline('.', record)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = record
	endif
endfun

fun! wheel#pencil#invert_all ()
	" Invert selection of all lines
endfun

fun! wheel#pencil#select_visible ()
	" Deselect all selected lines
	let buflines = getline(2,'$')
	" Cursor position
	let position = getcurpos()
	" Select current buffer lines
	for index in range(len(buflines))
		let linum = index + 1
		call cursor(linum, 1)
		" select current line
	endfor
	" Update buffer
	silent! 2,$ delete _
	put =buflines
	call wheel#gear#restore_cursor (position)
endfun

fun! wheel#pencil#deselect_all ()
	" Deselect all selected lines
	let b:wheel_selected = []
	let buflines = getline(2,'$')
	" Cursor position
	let position = getcurpos()
	" Deselect current buffer lines
	for index in range(len(buflines))
		let line = buflines[index]
		if line =~ s:selected_pattern
			let buflines[index] = substitute(line, s:selected_pattern, '', '')
		endif
	endfor
	" Deselect original buffer lines, without filter
	for index in range(len(b:wheel_lines))
		let line = b:wheel_lines[index]
		if line =~ s:selected_pattern
			let b:wheel_lines[index] = substitute(line, s:selected_pattern, '', '')
		endif
	endfor
	" Update buffer
	silent! 2,$ delete _
	put =buflines
	call wheel#gear#restore_cursor (position)
endfun

fun! wheel#pencil#all_or_nothing ()
	" Toggle select all / nothing
endfun

