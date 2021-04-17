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

" Current line

fun! wheel#pencil#select ()
	" Select current line
	let line = getline('.')
	if empty(line)
		return v:false
	endif
	if line =~ s:selected_pattern
		return v:false
	endif
	" update buffer line
	let marked_line = substitute(line, '\m^', s:selected_mark, '')
	call setline('.', marked_line)
	" update b:wheel_lines
	let index = index(b:wheel_lines, line)
	if index < 0
		return v:false
	endif
	let b:wheel_lines[index] = marked_line
	" update b:wheel_selected
	let address = wheel#line#address ()
	let index = index(b:wheel_selected, address)
	if index >= 0
		return v:false
	endif
	call add(b:wheel_selected, address)
	return v:true
endfun

fun! wheel#pencil#deselect ()
	" Deselect current line
	let line = getline('.')
	if empty(line)
		return v:false
	endif
	if line !~ s:selected_pattern
		return v:false
	endif
	" update buffer line
	let unmarked_line = substitute(line, s:selected_pattern, '', '')
	call setline('.', unmarked_line)
	" update b:wheel_lines
	let index = index(b:wheel_lines, line)
	if index < 0
		return v:false
	endif
	let b:wheel_lines[index] = unmarked_line
	" update b:wheel_selected
	let address = wheel#line#address ()
	let index = index(b:wheel_selected, address)
	if index < 0
		return v:false
	endif
	call remove(b:wheel_selected, index)
	return v:true
endfun

fun! wheel#pencil#toggle ()
	" Toggle selection of current line
	let line = getline('.')
	if line !~ s:selected_pattern
		call wheel#pencil#select ()
	else
		call wheel#pencil#deselect ()
	endif
endfun

" Visible, filtered lines

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

" All

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

fun! wheel#pencil#toggle_all ()
	" Toggle selection of all lines
endfun

fun! wheel#pencil#all_or_nothing ()
	" Toggle select all / nothing
endfun
