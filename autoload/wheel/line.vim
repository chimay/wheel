" vim: set ft=vim fdm=indent iskeyword&:

" Action of the cursor line :
" - Going to an element
" - Paste
" - Undo & diff

" Script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" Default data line

fun! wheel#line#default ()
	" If on filtering line, put the cursor in default line 2
	if wheel#teapot#has_filter() && line('.') == 1 && line('$') > 1
		call cursor(2, 1)
	endif
endfun

" Address of current line

fun! wheel#line#address (...)
	" Return complete information of element at line
	" This can be :
	"   - plain : in ordinary mandala buffer
	"   - treeish : in folded mandala buffer
	" Optional argument : line number
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	call wheel#line#default ()
	if ! &foldenable
		let cursor_line = getline(linum)
		return wheel#pencil#erase (cursor_line)
	else
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
		return address
	endif
endfun

" Target

fun! wheel#line#target (target)
	" Open target tab / win before navigation
	let target = a:target
	" jump mode : if new, do not search for match
	" in visible buffers
	let mode = 'new'
	if target ==# 'current'
		let mode = 'default'
	elseif target ==# 'tab'
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
	return mode
endfun

" Applications of loop#sailing

fun! wheel#line#switch (settings)
	" Switch to settings.selected element in wheel
	" settings keys :
	" - selected : where to switch
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	let settings = a:settings
	let mode = wheel#line#target (settings.target)
	call wheel#vortex#switch(settings.level, settings.selected, mode)
	return win_getid ()
endfun

fun! wheel#line#helix (settings)
	" Go to settings.selected = torus > circle > location
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = split(a:settings.selected, s:level_separ)
	if len(coordin) < 3
		echomsg 'Helix line is too short'
		return v:false
	endif
	let mode = wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (mode)
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
	let mode = wheel#line#target (a:settings.target)
	call wheel#vortex#interval (coordin)
	call wheel#vortex#jump (mode)
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
	let mode = wheel#line#target (a:settings.target)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#interval (coordin)
	elseif length == 1
		call wheel#vortex#tune('torus', coordin[0])
	else
		return v:false
	endif
	call wheel#vortex#jump (mode)
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
	let mode = wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (mode)
	return win_getid ()
endfun

fun! wheel#line#buffers (settings)
	" Go to opened file given by selected
	let settings = a:settings
	if ! has_key(settings, 'ctx_action') || settings.ctx_action == 'sailing'
		let fields = split(settings.selected, s:field_separ)
		let bufnum = fields[0]
		let filename = expand(fields[3])
		let filename = fnamemodify(filename, ':p')
		let coordin = wheel#projection#closest ('wheel', filename)
		if ! empty(coordin)
			let mode = wheel#line#target (settings.target)
			call wheel#vortex#chord (coordin)
			call wheel#vortex#jump (mode)
		else
			execute 'buffer' bufnum
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
		execute 'noautocmd tabnext' tabnum
		execute 'noautocmd' winum 'wincmd w'
		doautocmd WinEnter
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
		execute 'noautocmd tabnext' tabnum
		if len(hierarchy) > 1
			let winum = hierarchy[1]
			execute 'noautocmd' winum 'wincmd w'
		endif
		doautocmd WinEnter
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
	let line = str2nr(fields[0])
	let bufnum = a:settings.related_buffer
	call wheel#line#target (a:settings.target)
	execute 'buffer' bufnum
	call cursor(line, 1)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#grep (settings)
	" Go to settings.selected quickfix line
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 5
		echomsg 'Grep line is too short'
		return v:false
	endif
	" -- using error number
	let errnum = fields[0]
	call wheel#line#target (a:settings.target)
	execute 'cc' errnum
	" -- using buffer, line & col
	"let bufnum = fields[1]
	"let line = fields[3]
	"let col = fields[4]
	"call wheel#line#target (a:settings.target)
	"execute 'buffer' bufnum
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
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#locate (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	call wheel#line#target (a:settings.target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#find (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	let filename = trim(filename, ' ')
	call wheel#line#target (a:settings.target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#markers (settings)
	" Go to settings.selected marker
	let fields = split(a:settings.selected, s:field_separ)
	let mark = fields[0]
	"let line = fields[1]
	"let column = fields[2]
	call wheel#line#target (a:settings.target)
	execute "normal `" .. mark
	return win_getid ()
endfun

fun! wheel#line#jumps (settings)
	" Go to element in jumps list given by selected
	let fields = split(a:settings.selected, s:field_separ)
	let bufnum = fields[0]
	let linum = str2nr(fields[1])
	let colnum = str2nr(fields[2])
	call wheel#line#target (a:settings.target)
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#changes (settings)
	" Go to element in changes list given by selected
	let fields = split(a:settings.selected)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	let bufnum = a:settings.related_buffer
	call wheel#line#target (a:settings.target)
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#tags (settings)
	" Go to settings.selected tag
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 4
		echomsg 'Tag line is too short'
		return v:false
	endif
	let file = fields[2]
	let search = fields[3][1:]
	call wheel#line#target (a:settings.target)
	execute 'edit' file
	let found = search(search, 'sw')
	if found == 0
		echomsg 'wheel : tag not found : maybe you should update your tag file'
	endif
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#narrow_file (settings)
	" Go to settings.selected narrowed line of current file
	let bufnum = a:settings.bufnum
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 2
		echomsg 'Narrow file : line is too short'
		return v:false
	endif
	execute 'buffer' bufnum
	let linum = str2nr(fields[0])
	call wheel#line#target (a:settings.target)
	call cursor(linum, 1)
	return win_getid ()
endfun

fun! wheel#line#narrow_circle (settings)
	" Go to settings.selected narrowed line in circle
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 4
		echomsg 'Narrow circle : line is too short'
		return v:false
	endif
	" -- bufnum & linum
	let bufnum = str2nr(fields[0])
	let linum = str2nr(fields[1])
	call wheel#line#target (a:settings.target)
	"execute 'buffer' bufnum
	"call cursor(linum, 1)
	" -- error number
	let quickfix = getqflist()
	for index in range(len(quickfix))
		let elem = quickfix[index]
		if bufnum == elem.bufnr && linum == elem.lnum
			break
		endif
	endfor
	let errnum = index + 1
	execute 'cc' errnum
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
	if ! wheel#pencil#is_selection_empty ()
		let addresses = deepcopy(b:wheel_selection.addresses)
		eval addresses->map({ _, list_string -> eval(list_string) })
		eval addresses->map({ _, list -> join(list, "\n") })
		let content = join(addresses, "\n")
	else
		let line = getline('.')
		if empty(line)
			return v:false
		endif
		let content = eval(line)
	endif
	call wheel#mandala#related ()
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
		let where = 'linewise_after'
	endif
	if a:0 > 1
		let close = a:2
	else
		let close = 'close'
	endif
	if ! wheel#pencil#is_selection_empty ()
		let addresses = b:wheel_selection.addresses
		let content = join(addresses, "\n")
	else
		let content = getline('.')
	endif
	if empty(content)
		return v:false
	endif
	call wheel#mandala#related ()
	if where == 'linewise_after'
		put =content
	elseif where == 'linewise_before'
		put! =content
	elseif where == 'charwise_after'
		let @" = content
		normal! p
	elseif where == 'charwise_before'
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
	call wheel#mandala#related ()
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
	let iden = wheel#delta#undo_iden ()
	call wheel#rectangle#goto_or_load (a:bufnum)
	execute 'undo' iden
	call wheel#cylinder#recall ()
endfun

fun! wheel#line#undo_diff (bufnum)
	" Visualize diff between last state & undo
	let iden = wheel#delta#undo_iden ()
	" original buffer
	call wheel#rectangle#goto_or_load (a:bufnum)
	let save = {}
	let save.name = expand('%')
	let save.filetype = &filetype
	" copy of original buffer
	vnew
	read #
	1 delete _
	let diff_buf = bufnr('%')
	set buftype=nofile
	execute 'file' 'wheel diff : ' save.name
	let &filetype = save.filetype
	diffthis
	setlocal nomodifiable readonly
	" original buffer
	call wheel#rectangle#goto_or_load (a:bufnum)
	execute 'undo' iden
	call wheel#delta#save_options ()
	diffthis
	" back to mandala
	call wheel#cylinder#recall ()
	let b:wheel_settings.diff_buf = diff_buf
endfun
