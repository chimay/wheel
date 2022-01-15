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
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear ()
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
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle ()
	" Toggle selection of current line
	let line = getline('.')
	if line !~ s:selected_pattern
		call wheel#pencil#select ()
	else
		call wheel#pencil#clear ()
	endif
	setlocal nomodified
	return v:true
endfun

" Visible, filtered lines

fun! wheel#pencil#select_visible ()
	" Select visible, filtered lines
	let begin = wheel#mandala#first_data_line ()
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
	let begin = wheel#mandala#first_data_line ()
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
	let begin = wheel#mandala#first_data_line ()
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
