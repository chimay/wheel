" vim: set ft=vim fdm=indent iskeyword&:

" Pencil
"
" Selection in mandalas

" booleans

fun! wheel#pencil#has_selection ()
	" Whether mandala has selection
	return b:wheel_nature.has_selection
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

" add / remove mark

fun! wheel#pencil#marked (line)
	" Return marked line
	let line = a:line
	if wheel#pencil#has_select_mark (line)
		return line
	endif
	let selection_mark = g:wheel_config.display.selection
	return substitute(line, '\m^', selection_mark, '')
endfun

fun! wheel#pencil#unmarked (line)
	" Return unmarked line
	let line = a:line
	if ! wheel#pencil#has_select_mark (line)
		return line
	endif
	let selection_mark = g:wheel_config.display.selection
	let selection_pattern = '\m^' .. selection_mark
	return substitute(line, selection_pattern, '', '')
endfun

" virtual selection at current line

fun! wheel#pencil#default_line ()
	" If on filter line, put the cursor on line 2 if possible
	let is_filtered = wheel#teapot#is_filtered ()
	let has_filter = wheel#teapot#has_filter()
	if is_filtered && line('$') == 1
		call wheel#teapot#clear()
	endif
	if has_filter && line('$') == 1
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

fun! wheel#pencil#cursor (...)
	" Return dict containing index & component at cursor line
	" Optional argument :
	"   - line number
	"   - default : current line number
	" Mandala can be :
	"   - plain : in ordinary mandala buffer
	"   - treeish : in folded mandala buffer
	" ---- default line if needed
	" ---- must come before : line('.')
	if ! wheel#pencil#default_line ()
		return {}
	endif
	" ---- arguments
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	" ---- line index
	let index = wheel#teapot#line_index (linum)
	" ---- component
	if wheel#cuboctahedron#is_treeish ()
		let component = copy(b:wheel_full[index])
	else
		let cursor_line = getline(linum)
		let component = wheel#pencil#unmarked (cursor_line)
	endif
	" ---- coda
	let info = {}
	let info.index = index
	let info.component = component
	return info
endfun

fun! wheel#pencil#virtual (...)
	" Return selection as if cursor line was selected
	" Optional argument :
	"   - line number
	"   - default : current line number
	let info = wheel#pencil#cursor ()
	if empty(info)
		return #{ indexes : [], components : []}
	endif
	let cursor_selection = {}
	let cursor_selection.indexes = [ info.index ]
	let cursor_selection.components = [ info.component ]
	return cursor_selection
endfun

" one line

fun! wheel#pencil#select (...)
	" Select line
	" Optional argument : line number
	" Default : current line number
	if ! wheel#pencil#has_selection ()
		return v:false
	endif
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
	let cursor_info = wheel#pencil#cursor (linum)
	let index = cursor_info.index
	let component = cursor_info.component
	eval selection.indexes->add(index)
	eval selection.components->add(component)
	" ---- update buffer line
	let marked_line = wheel#pencil#marked (line)
	call wheel#mandala#unlock ()
	call setline(linum, marked_line)
	call wheel#mandala#post_edit ()
	" ---- coda
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#clear (...)
	" Deselect line
	" Optional argument : line number
	" Default : current line number
	if ! wheel#pencil#has_selection ()
		return v:false
	endif
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
	let cursor_info = wheel#pencil#cursor (linum)
	" -- indexes
	let index = cursor_info.index
	let found = selection.indexes->index(index)
	eval selection.indexes->remove(found)
	eval selection.components->remove(found)
	" ---- update buffer line
	let unmarked_line = wheel#pencil#unmarked (line)
	call wheel#mandala#unlock ()
	call setline(linum, unmarked_line)
	call wheel#mandala#post_edit ()
	" ---- coda
	setlocal nomodified
	return v:true
endfun

fun! wheel#pencil#toggle (...)
	" Toggle selection of line
	" Optional argument : line number
	" Default : current line number
	if ! wheel#pencil#has_selection ()
		return v:false
	endif
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
	call wheel#mandala#unlock ()
	for linum in range(start, lastline)
		let line = getline(linum)
		let unmarked = wheel#pencil#unmarked (line)
		call setline(linum, unmarked)
	endfor
	setlocal nomodified
	call wheel#mandala#post_edit ()
	return v:true
endfun

fun! wheel#pencil#show ()
	" Add selection mark to all selected lines
	" This does not alter the selection
	if ! wheel#pencil#has_selection ()
		" avoid useless computing
		return v:false
	endif
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	let linelist = getline(start, '$')
	let reference = b:wheel_selection.indexes
	call wheel#mandala#unlock ()
	for linum in range(start, lastline)
		let index = wheel#teapot#line_index (linum)
		let inside = index->wheel#chain#is_inside(reference)
		if inside
			let line = getline(linum)
			let marked = wheel#pencil#marked (line)
			call setline(linum, marked)
		endif
	endfor
	setlocal nomodified
	call wheel#mandala#post_edit ()
	return v:true
endfun

fun! wheel#pencil#syncdown ()
	" Sync selection variable -> visible lines
	if ! wheel#pencil#has_selection ()
		" avoid useless computing
		return v:false
	endif
	let start = wheel#teapot#first_data_line ()
	let lastline = line('$')
	let linelist = getline(start, '$')
	let reference = b:wheel_selection.indexes
	call wheel#mandala#unlock ()
	for linum in range(start, lastline)
		let index = wheel#teapot#line_index (linum)
		let inside = index->wheel#chain#is_inside(reference)
		if inside
			let line = getline(linum)
			let marked = wheel#pencil#marked (line)
			call setline(linum, marked)
		else
			let line = getline(linum)
			let unmarked = wheel#pencil#unmarked (line)
			call setline(linum, unmarked)
		endif
	endfor
	setlocal nomodified
	call wheel#mandala#post_edit ()
	return v:true
endfun

" selection

fun! wheel#pencil#selection ()
	" Return selection or, if empty, virtual selection at cursor line
	" If context menu, look in previous leaf
	if wheel#boomerang#is_context_menu ()
		return wheel#upstream#selection ()
	endif
	if wheel#pencil#is_selection_empty ()
		return wheel#pencil#virtual ()
	endif
	return b:wheel_selection
endfun

" mappings

fun! wheel#pencil#mappings ()
	" Define selection maps & set property
	" -- selection property
	let b:wheel_nature.has_selection = v:true
	" -- normal mode
	nnoremap <buffer> <space> <cmd>call wheel#pencil#toggle()<cr>
	nnoremap <buffer> =       <cmd>call wheel#pencil#toggle()<cr>
	nnoremap <buffer> #       <cmd>call wheel#pencil#toggle_visible()<cr>
	nnoremap <buffer> *       <cmd>call wheel#pencil#select_visible()<cr>
	nnoremap <buffer> <bar>   <cmd>call wheel#pencil#clear_visible()<cr>
endfun
