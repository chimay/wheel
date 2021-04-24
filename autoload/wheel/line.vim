" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element
" - Paste

" Script constants

if ! exists('s:is_mandala')
	let s:is_mandala = wheel#crystal#fetch('is_mandala')
	lockvar s:is_mandala
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Address of current line

fun! wheel#line#default ()
	" If on filtering line, put the cursor in default line 2
	if wheel#mandala#has_filter() && line('.') == 1 && line('$') > 1
		call cursor(2, 1)
	endif
endfun

fun! wheel#line#address ()
	" Return address of element at line in plain or folded mandala buffer
	call wheel#line#default ()
	if ! &foldenable
		let cursor_line = getline('.')
		let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
		return cursor_line
	else
		let file = expand('%')
		if file =~ s:is_mandala . 'tree'
			return wheel#line#coordinates ()
		elseif file =~ s:is_mandala . 'tabwins/tree'
			return wheel#line#tabwin_hierarchy ()
		else
			return v:false
		endif
	endif
endfun

fun! wheel#line#coordinates ()
	" Return wheel coordinates of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		return []
	endif
	let level = wheel#origami#fold_level ()
	if level == 'torus'
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif level == 'circle'
		" circle line : search torus
		let circle = cursor_list[0]
		call wheel#origami#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle]
	elseif level == 'location'
		" location line : search circle & torus
		let location = cursor_line
		call wheel#origami#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let circle = fields[0]
		call wheel#origami#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle, location]
	else
		echomsg 'wheel line coordin : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun

fun! wheel#line#tabwin_hierarchy ()
	" Return tab & filename of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		return []
	endif
	let level = wheel#origami#tabwin_level ()
	if level == 'tab'
		" tab line
		let tabnum = str2nr(cursor_list[1])
		let coordin = [tabnum]
	elseif level == 'filename'
		" filename line
		let filename = cursor_list[0]
		let fileline = line('.')
		call wheel#origami#parent_tabwin ()
		let tabline = line('.')
		let winum = fileline - tabline
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let tabnum = str2nr(fields[1])
		let coordin = [tabnum, winum, filename]
	else
		echomsg 'tabwin hierarchy : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun

" Target

fun! wheel#line#target (target)
	" Open target tab / win before navigation
	let target = a:target
	if target ==# 'tab'
		tabnew
	elseif target ==# 'horizontal_split'
		split
	elseif target ==# 'vertical_split'
		vsplit
	elseif target ==# 'horizontal_golden'
		call wheel#spiral#horizontal ()
	elseif target ==# 'vertical_golden'
		call wheel#spiral#vertical ()
	endif
endfu

" Menu

fun! wheel#line#menu (settings)
	" Calls function given by the key = cursor line
	" settings is a dictionary, whose keys can be :
	" - dict : name of a dictionary variable in storage.vim
	" - close : whether to close mandala buffer
	" - travel : whether to go back to previous window before applying action
	let settings = a:settings
	let dict = wheel#crystal#fetch (settings.linefun, 'dict')
	let close = settings.ctx_close
	let travel = settings.ctx_travel
	" Cursor line
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	if empty(cursor_line)
		echomsg 'wheel line menu : you selected an empty line'
		return v:false
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		normal! zv
		call wheel#spiral#cursor ()
		echomsg 'wheel line menu : key not found'
		return v:false
	endif
	" Tab page of mandala before processing
	let elder_tab = tabpagenr()
	" Travel before processing ?
	" True for hub menus
	" False for context menus
	" In case of sailing, it's managed by wheel#line#sailing
	if travel
		wincmd p
	endif
	" Call
	let value = dict[key]
	let winiden = wheel#gear#call (value)
	if close
		" Close mandala
		" Go back to mandala
		call wheel#cylinder#recall ()
		" Close it
		call wheel#mandala#close ()
		" Go to last destination
		call wheel#gear#win_gotoid (winiden)
	else
		" Do not close mandala
		" Tab page changed ?
		call wheel#gear#win_gotoid (winiden)
		let new_tab = tabpagenr()
		if elder_tab != new_tab
			" Tab changed, move mandala to new tab
			" Go back to mandala
			call wheel#cylinder#recall()
			" Close it in elder tab
			silent call wheel#mandala#close ()
			" Go back in new tab
			exe 'tabnext' new_tab
			" Call mandala back in new tab
			call wheel#cylinder#recall()
		else
			" Same tab, just go to mandala window
			call wheel#cylinder#recall()
		endif
	endif
	return v:true
endfun

" Navigation

fun! wheel#line#sailing (settings)
	" Go to element(s) on cursor line or selected line(s)
	" settings keys :
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	" - close : whether to close mandala
	" - action : navigation function name or funcref
	let settings = copy(a:settings)
	if has_key(settings, 'target')
		let target = settings.target
	else
		let target = 'current'
		let settings.target = target
	endif
	if has_key(settings, 'close')
		let close = settings.close
	else
		let close = v:true
	endif
	if has_key(settings, 'action')
		let Fun = settings.action
	else
		let Fun = 'wheel#line#switch'
	endif
	if empty(b:wheel_selected)
		let selected = [wheel#line#address ()]
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'wheel line sailing : bad format for b:wheel_selected'
		return v:false
	endif
	if close
		call wheel#mandala#close ()
	else
		wincmd p
	endif
	if target != 'current'
		" open new split or tab, do not search for
		" match in visible buffers
		let settings.use = 'new'
		for elem in selected
			let settings.selected = elem
			call wheel#gear#call(Fun, settings)
			normal! zv
			call wheel#spiral#cursor ()
		endfor
	else
		" open in current window, search also
		" for match in visible buffers
		let settings.use = 'default'
		let settings.selected = selected[0]
		call wheel#gear#call(Fun, settings)
		normal! zv
		call wheel#spiral#cursor ()
	endif
	let winiden = win_getid ()
	if ! close
		call wheel#cylinder#recall ()
		" let the user clear the selection with <bar> if he chooses to
	else
		call win_gotoid (winiden)
	endif
	return winiden
endfun

" Applications of wheel#line#sailing

fun! wheel#line#switch (settings)
	" Switch to settings.selected element in wheel
	" settings keys :
	" - selected : where to switch
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	let settings = a:settings
	call wheel#line#target (settings.target)
	call wheel#vortex#switch(settings.level, settings.selected, settings.use)
	return win_getid ()
endfun

fun! wheel#line#helix (settings)
	" Go to settings.selected = torus > circle > location
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = split(a:settings.selected, ' > ')
	if len(coordin) < 3
		echomsg 'Helix line is too short'
		return v:false
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:settings.use)
	return win_getid ()
endfun

fun! wheel#line#grid (settings)
	" Go to settings.selected = torus > circle
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = split(a:settings.selected, ' > ')
	if len(coordin) < 2
		echomsg 'Grid line is too short'
		return v:false
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#tune('torus', coordin[0])
	call wheel#vortex#tune('circle', coordin[1])
	call wheel#vortex#jump (a:settings.use)
	return win_getid ()
endfun

fun! wheel#line#tree (settings)
	" Go to settings.selected in tree view
	" Possible vallues of selected :
	" - [torus]
	" - [torus, circle]
	" - [torus, circle, location]
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = a:settings.selected
	let length = len(coordin)
	call wheel#line#target (a:settings.target)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#tune('torus', coordin[0])
		call wheel#vortex#tune('circle', coordin[1])
	elseif length == 1
		call wheel#vortex#tune('torus', coordin[0])
	else
		return v:false
	endif
	call wheel#vortex#jump (a:settings.use)
	return win_getid ()
endfun

fun! wheel#line#history (settings)
	" Go to settings.selected history location
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 2
		echomsg 'History line is too short'
		return v:false
	endif
	let coordin = split(fields[1], ' > ')
	if len(coordin) < 3
		echomsg 'History : coordinates should contain 3 elements'
		return v:false
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:settings.use)
	return win_getid ()
endfun

fun! wheel#line#buffers (settings)
	" Go to opened file given by selected
	let settings = a:settings
	if ! has_key(settings, 'ctx_action') || settings.ctx_action == 'sailing'
		let fields = split(settings.selected, s:field_separ)
		let bufnum = fields[0]
		let filename = expand(fields[2])
		let filename = fnamemodify(filename, ':p')
		let coordin = wheel#projection#closest ('wheel', filename)
		if len(coordin) > 0
			call wheel#vortex#chord (coordin)
			call wheel#line#target (settings.target)
			call wheel#vortex#jump ()
		else
			exe 'buffer' bufnum
		endif
	elseif settings.ctx_action == 'delete'
		" Delete buffer
		let fields = split(settings.selected, s:field_separ)
		let bufnum = fields[0]
		execute 'bdelete' bufnum
	elseif settings.ctx_action == 'unload'
		" Unload buffer
		let fields = split(settings.selected, s:field_separ)
		let bufnum = fields[0]
		execute 'bunload' bufnum
	elseif settings.ctx_action == 'wipe'
		" Wipe buffer
		let fields = split(settings.selected, s:field_separ)
		let bufnum = fields[0]
		execute 'bwipe' bufnum
	endif
	return win_getid ()
endfun

fun! wheel#line#tabwins (settings)
	" Go to tab & win given by selected
	let settings = a:settings
	if ! has_key(settings, 'ctx_action') || settings.ctx_action == 'open'
		let fields = split(settings.selected, s:field_separ)
		let tabnum = fields[0]
		let winum = fields[1]
		execute 'tabnext' tabnum
		execute winum 'wincmd w'
	elseif settings.ctx_action == 'tabnew'
		tabnew
	elseif settings.ctx_action == 'tabclose'
		" Close tab
		let fields = split(settings.selected, s:field_separ)
		let tabnum = fields[0]
		if tabnum != tabpagenr()
			execute 'tabclose' tabnum
		else
			echomsg 'wheel line tabwins : will not close current tab page.'
		endif
	endif
	return win_getid ()
endfun

fun! wheel#line#tabwins_tree (settings)
	" Go to tab & win given by selected
	let settings = a:settings
	let hierarchy = a:settings.selected
	if empty(hierarchy)
		return v:false
	endif
	let tabnum = hierarchy[0]
	if ! has_key(settings, 'ctx_action') || settings.ctx_action == 'open'
		" Find matching tab
		execute 'tabnext' tabnum
		if len(hierarchy) > 1
			let winum = hierarchy[1]
			execute winum 'wincmd w'
		endif
	elseif settings.ctx_action == 'tabnew'
		tabnew
	elseif settings.ctx_action == 'tabclose'
		" Close tab
		if tabnum != tabpagenr()
			execute 'tabclose' tabnum
		else
			echomsg 'wheel line tabwins_tree : will not close current tab page.'
		endif
	endif
	return win_getid ()
endfun

fun! wheel#line#occur (settings)
	" Go to line given by selected
	let fields = split(a:settings.selected, s:field_separ)
	let line = fields[0]
	call wheel#line#target (a:settings.target)
	call cursor(line, 1)
	return win_getid ()
endfun

fun! wheel#line#grep (settings)
	" Go to settings.selected quickfix line
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 5
		echomsg 'Grep line is too short'
		return v:false
	endif
	"Using error number
	let errnum = fields[0]
	call wheel#line#target (a:settings.target)
	execute 'cc' errnum
	" Using buffer, line & col
	"let bufnum = fields[1]
	"let line = fields[3]
	"let col = fields[4]
	"call wheel#line#target (a:settings.target)
	"exe 'buffer' bufnum
	"call cursor(line, col)
	return win_getid ()
endfun

fun! wheel#line#mru (settings)
	" Edit settings.selected MRU file
	let fields = split(a:settings.selected)
	if len(fields) < 2
		echomsg 'MRU line is too short'
		return v:false
	endif
	let filename = fields[6]
	call wheel#line#target (a:settings.target)
	exe 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#locate (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	call wheel#line#target (a:settings.target)
	exe 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#find (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	let filename = trim(filename, ' ')
	call wheel#line#target (a:settings.target)
	exe 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#tags (settings)
	" Go to settings.selected tag
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 4
		echomsg 'Tag line is too short'
		return v:false
	endif
	let ident = fields[0]
	call wheel#line#target (a:settings.target)
	exe 'tag' ident
	return win_getid ()
endfun

fun! wheel#line#jumps (settings)
	" Go to element in jumps list given by selected
	let fields = split(a:settings.selected, s:field_separ)
	let delta = str2nr(fields[0])
	call wheel#line#target (a:settings.target)
	if delta > 0
		exe 'normal! ' . delta . "\<c-i>"
	else
		exe 'normal! ' . - delta . "\<c-o>"
	endif
	return win_getid ()
endfun

fun! wheel#line#changes (settings)
	" Go to element in changes list given by selected
	let fields = split(a:settings.selected)
	let delta = str2nr(fields[0])
	call wheel#line#target (a:settings.target)
	if delta > 0
		exe 'normal! ' . delta . 'g,'
	else
		exe 'normal! ' . - delta . 'g;'
	endif
	return win_getid ()
endfun

" Paste

fun! wheel#line#paste_list (...)
	" Paste elements in current line from yank buffer in fields mode
	if a:0 > 0
		let where = a:1
	else
		let where = 'after'
	endif
	if a:0 > 1
		let close = a:2
	else
		let close = 'close'
	endif
	if ! empty(b:wheel_selected)
		let content = eval(b:wheel_selected[0])
	else
		let line = getline('.')
		if empty(line)
			return v:false
		endif
		let content = eval(line)
	endif
	wincmd p
	if where == 'after'
		put =content
	elseif where == 'before'
		put! =content
	endif
	let @" = join(content, "\n")
	call wheel#cylinder#recall ()
	if close == 'close'
		call wheel#mandala#close ()
	endif
	return win_getid ()
endfun

fun! wheel#line#paste_plain (...)
	" Paste line from yank buffer in plain mode
	if a:0 > 0
		let where = a:1
	else
		let where = 'after'
	endif
	if a:0 > 1
		let close = a:2
	else
		let close = 'close'
	endif
	if ! empty(b:wheel_selected)
		let content = b:wheel_selected[0]
	else
		let content = getline('.')
	endif
	if empty(content)
		return v:false
	endif
	wincmd p
	if where == 'linewise_after'
		put =content
	elseif where == 'linewise_before'
		put! =content
	elseif where == 'character_after'
		let @" = content
		normal! p
	elseif where == 'character_before'
		let @" = content
		normal! P
	endif
	let @" = content
	call wheel#cylinder#recall ()
	if close == 'close'
		call wheel#mandala#close ()
	endif
	return win_getid ()
endfun

fun! wheel#line#paste_visual (...)
	" Paste visual selection from yank buffer in plain mode
	if a:0 > 0
		let where = a:1
	else
		let where = 'after'
	endif
	if a:0 > 1
		let close = a:2
	else
		let close = 'close'
	endif
	normal! gvy
	wincmd p
	if where == 'after'
		normal! p
	elseif where == 'before'
		normal! P
	endif
	call wheel#cylinder#recall ()
	if close == 'close'
		call wheel#mandala#close ()
	endif
	return win_getid ()
endfun

" Undo list

fun! wheel#line#undolist (bufnum)
	" Jump to change in settings.selected
	call wheel#line#default ()
	let line = getline('.')
	let fields = split(line)
	let iden = str2nr(fields[0])
	let winiden = win_findbuf(a:bufnum)[0]
	call wheel#gear#win_gotoid (winiden)
	exe 'undo' iden
	call wheel#cylinder#recall ()
endfun

fun! wheel#line#undo_diff (bufnum)
	" Visualize diff between last state & undo
	call wheel#line#default ()
	let line = getline('.')
	let fields = split(line)
	let iden = str2nr(fields[0])
	" original buffer
	let winiden = win_findbuf(a:bufnum)[0]
	call wheel#gear#win_gotoid (winiden)
	let save_filetype = &filetype
	" copy of original buffer
	vnew
	read #
	1 delete _
	let diff_buf = bufnr('%')
	let &filetype = save_filetype
	diffthis
	setlocal nomodifiable readonly
	" original buffer
	call wheel#gear#win_gotoid (winiden)
	exe 'undo' iden
	call wheel#delta#save_options ()
	diffthis
	" back to mandala
	call wheel#cylinder#recall ()
	let b:wheel_settings.diff_buf = diff_buf
endfun
