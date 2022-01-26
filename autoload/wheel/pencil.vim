" vim: set ft=vim fdm=indent iskeyword&:

" Selection in mandalas

" booleans

fun! wheel#pencil#has_selection ()
	" Whether mandala has selection
	return ! empty(b:wheel_nature.has_selection)
endfun

fun! wheel#pencil#is_selection_empty ()
	" Whether selection is empty
	if wheel#boomerang#is_context_menu ()
		return v:false
	endif
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

fun! wheel#pencil#has_select_mark (line)
	" Whether line has selection mark
	let selection_mark = g:wheel_config.display.selection
	let selection_pattern = '\m^' .. selection_mark
	return a:line =~ selection_pattern
endfun

" address at current line

fun! wheel#pencil#default_line ()
	" If on filter line, put the cursor on line 2 if possible
	" If on filtering line, put the cursor in default line 2
	let has_filter = wheel#teapot#has_filter()
	let is_filtered = wheel#teapot#is_filtered ()
	if line('$') == 1 && is_filtered
		call wheel#teapot#clear()
	endif
	if line('$') == 1
		echomsg 'wheel pencil default line : mandala is empty'
		return v:false
	endif
	let cur_line = line('.')
	let last_line = line('$')
	if has_filter && cur_line == 1 && last_line > 1
		call cursor(2, 1)
	endif
	return v:true
endfun

fun! wheel#pencil#address (...)
	" Return complete information of element at line
	" Returns [line index in b:wheel_lines, full line information]
	" Mandala can be :
	"   - plain : in ordinary mandala buffer
	"   - treeish : in folded mandala buffer
	" Optional argument :
	"   - line number
	"   - default : current line number
	" ---- default line if needed
	" ---- must come before : line('.')
	if ! wheel#pencil#default_line ()
		return []
	endif
	" ---- arguments
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	" ---- plain
	if ! &foldenable
		let cursor_line = getline(linum)
		let line_index = wheel#teapot#line_index (linum)
		let content = wheel#pencil#erase (cursor_line)
		let cursor_selection = [line_index, content]
		return cursor_selection
	endif
	" ---- treeish
	let position = getcurpos()
	call cursor(linum, 1)
	let type = wheel#mandala#type ()
	if type == 'index/tree'
		let address = wheel#origami#chord ()
	elseif type == 'tabwins/tree'
		let address = wheel#origami#tabwin ()
	else
		let address = []
	endif
	call wheel#gear#restore_cursor (position)
	return [linum, address]
endfun

" add / remove mark

fun! wheel#pencil#draw (line)
	" Return marked line
	let line = a:line
	if wheel#pencil#has_select_mark (line)
		return line
	endif
	let selection_mark = g:wheel_config.display.selection
	return substitute(line, '\m^', selection_mark, '')
endfun

fun! wheel#pencil#erase (line)
	" Return unmarked line
	let line = a:line
	if ! wheel#pencil#has_select_mark (line)
		return line
	endif
	let selection_mark = g:wheel_config.display.selection
	let selection_pattern = '\m^' .. selection_mark
	return substitute(line, selection_pattern, '', '')
endfun

" one line

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
	let address = wheel#pencil#address (linum)
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
	let address = wheel#pencil#address (linum)
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

" all visible lines in the mandala
" they may be filtered or not

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
	" Remove selection mark from all visible lines
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
	" Add selection mark to all selected lines
	" This does not alter the selection
	if ! wheel#pencil#has_selection ()
		return v:false
	endif
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

" selection

fun! wheel#pencil#selection ()
	" Return selection or line & address of current line
	" If context menu, look in previous leaf
	if wheel#boomerang#is_context_menu ()
		return wheel#upstream#selection ()
	endif
	if wheel#pencil#is_selection_empty ()
		let cursor_selection = wheel#pencil#address ()
		let index = cursor_selection[0]
		let address = cursor_selection[1]
		let selection = {}
		let selection.indexes = [ index ]
		let selection.addresses = [ address ]
	else
		let selection = b:wheel_selection
	endif
	return selection
endfun

" mappings

fun! wheel#pencil#mappings ()
	" Define selection maps & set property
	" -- selection property
	let b:wheel_nature.has_selection = v:true
	" -- normal mode
	nnoremap <buffer> <space> <cmd>call wheel#pencil#toggle()<cr>
	nnoremap <buffer> & <cmd>call wheel#pencil#toggle_visible()<cr>
	nnoremap <buffer> * <cmd>call wheel#pencil#select_visible()<cr>
	nnoremap <buffer> <bar> <cmd>call wheel#pencil#clear_visible()<cr>
endfun
