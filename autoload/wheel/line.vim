" vim: set ft=vim fdm=indent iskeyword&:

" Action of the cursor line :
"
" - Going to an element
" - Paste
" - Undo & diff

" ---- script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" ---- target

fun! wheel#line#where (target)
	" Where to jump
	" Return value :
	"   - search-window : search for active buffer
	"                     in tabs & windows
	"   - here : load the buffer in current window,
	"            do not search in tabs & windows
	" See also vortex#jump
	" -- arguments
	let target = a:target
	" -- search for window is better with prompt functions
	"if target ==# 'current'
		"return 'search-window'
	"endif
	" -- coda
	return 'here'
endfun

fun! wheel#line#target (target)
	" Open target tab / win if needed before navigation
	let target = a:target
	if target ==# 'tab'
		noautocmd tabnew
	elseif target ==# 'horizontal_split'
		noautocmd split
	elseif target ==# 'vertical_split'
		noautocmd vsplit
	elseif target ==# 'horizontal_golden'
		call wheel#spiral#horizontal_split ()
	elseif target ==# 'vertical_golden'
		call wheel#spiral#vertical_split ()
	endif
endfun

" ---- applications of loop#selection, and sometimes loop#boomerang

" -- wheel applications

fun! wheel#line#switch (settings)
	" Switch to settings.selection element in wheel
	" settings keys :
	" - target : current, tab, horizontal_split, vertical_split
	" - level : torus, circle or location
	" - selection : place to jump to
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let level = settings.level
	let selection = settings.selection
	" ---- jump
	let where = wheel#line#where (target)
	call wheel#line#target (target)
	call wheel#vortex#switch(level, selection, where)
	return win_getid ()
endfun

fun! wheel#line#helix (settings)
	" Go to settings.selection = torus > circle > location
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let coordin = split(selection, s:level_separ)
	" ---- jump
	let where = wheel#line#where (target)
	call wheel#line#target (target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return win_getid ()
endfun

fun! wheel#line#grid (settings)
	" Go to settings.selection = torus > circle
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let coordin = split(selection, s:level_separ)
	" ---- jump
	let where = wheel#line#where (target)
	call wheel#line#target (target)
	call wheel#vortex#interval (coordin)
	call wheel#vortex#jump (where)
	return win_getid ()
endfun

fun! wheel#line#tree (settings)
	" Go to settings.selection in tree view
	" Possible vallues of selection :
	" - [torus]
	" - [torus, circle]
	" - [torus, circle, location]
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let coordin = settings.selection
	let length = len(coordin)
	" ---- jump
	let where = wheel#line#where (target)
	call wheel#line#target (a:settings.target)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#interval (coordin)
	elseif length == 1
		call wheel#vortex#tune('torus', coordin[0])
	else
		return v:false
	endif
	call wheel#vortex#jump (where)
	return win_getid ()
endfun

fun! wheel#line#history (settings)
	" Go to settings.selection history location
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let coordin = split(fields[1], s:level_separ)
	" ---- jump
	let where = wheel#line#where (target)
	call wheel#line#target (target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return win_getid ()
endfun

" -- non wheel applications

fun! wheel#line#buffers (settings)
	" Go to opened file given by selection
	" ---- settings
	let settings = a:settings
	let selection = settings.selection
	let fields = split(selection, s:field_separ, v:true)
	let bufnum = str2nr(fields[0])
	let filename = fnamemodify(fields[3], ':p')
	let is_context_menu = has_key(settings, 'menu') && settings.menu.kind == 'menu/context'
	if is_context_menu
		let action = settings.menu.action
	else
		let action = 'navigation'
	endif
	" ---- actions
	if action == 'navigation'
		let target = settings.target
		let coordin = wheel#projection#closest ('wheel', filename)
		if ! empty(coordin)
			let where = wheel#line#where (target)
			call wheel#line#target (target)
			call wheel#vortex#chord (coordin)
			call wheel#vortex#jump (where)
		else
			call wheel#line#target (target)
			execute 'buffer' bufnum
		endif
	elseif action == 'delete'
		execute 'silent bdelete' bufnum
		echomsg 'buffer' bufnum 'deleted'
	elseif action == 'unload'
		execute 'silent bunload' bufnum
		echomsg 'buffer' bufnum 'unloaded'
	elseif action == 'wipe'
		execute 'silent bwipe' bufnum
		echomsg 'buffer' bufnum 'wiped'
	endif
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#tabwins (settings)
	" Go to tab & win given by selection
	" ---- settings
	let settings = a:settings
	let selection = settings.selection
	let is_context_menu = has_key(settings, 'menu') && settings.menu.kind == 'menu/context'
	if is_context_menu
		let action = settings.menu.action
	else
		let action = 'open'
	endif
	" ---- actions
	if action == 'open'
		let fields = split(selection, s:field_separ)
		let tabnum = fields[0]
		let winum = fields[1]
		execute 'noautocmd tabnext' tabnum
		execute 'noautocmd' winum 'wincmd w'
		doautocmd WinEnter
	elseif action == 'tabclose'
		let fields = split(selection, s:field_separ)
		let tabnum = fields[0]
		if tabnum != tabpagenr()
			execute 'tabclose' tabnum
		else
			echomsg 'wheel line tabwins : will not close current tab page'
		endif
	endif
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#tabwins_tree (settings)
	" Go to tab & win given by selection
	" ---- settings
	let settings = a:settings
	let hierarchy = settings.selection
	let tabnum = hierarchy[0]
	let is_context_menu = has_key(settings, 'menu') && settings.menu.kind == 'menu/context'
	if is_context_menu
		let action = settings.menu.action
	else
		let action = 'open'
	endif
	" ---- actions
	if action == 'open'
		execute 'noautocmd tabnext' tabnum
		if len(hierarchy) > 1
			let winum = hierarchy[1]
			execute 'noautocmd' winum 'wincmd w'
		endif
		doautocmd WinEnter
	elseif action == 'tabnew'
		tabnew
	elseif action == 'tabclose'
		if tabnum != tabpagenr()
			execute 'tabclose' tabnum
		else
			echomsg 'wheel line tabwins_tree : will not close current tab page'
		endif
	endif
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#occur (settings)
	" Go to line given by selection
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let bufnum = a:settings.related_buffer
	" ---- go
	let fields = split(selection, s:field_separ)
	let line = str2nr(fields[0])
	call wheel#line#target (target)
	execute 'buffer' bufnum
	call cursor(line, 1)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#grep (settings)
	" Go to settings.selection quickfix line
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	" ---- go
	call wheel#line#target (target)
	" -- using error number
	let errnum = fields[0]
	execute 'cc' errnum
	" -- using buffer, line & col
	"let bufnum = fields[1]
	"let line = fields[3]
	"let col = fields[4]
	"execute 'buffer' bufnum
	"call cursor(line, col)
	" ---- coda
	return win_getid ()
endfun

fun! wheel#line#mru (settings)
	" Edit settings.selection MRU file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let filename = fields[1]
	" ---- go
	call wheel#line#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#locate (settings)
	" Edit settings.selection locate file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let filename = settings.selection
	" ---- go
	call wheel#line#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#find (settings)
	" Edit settings.selection locate file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let filename = settings.selection
	let filename = trim(filename, ' ')
	" ---- go
	call wheel#line#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#markers (settings)
	" Go to settings.selection marker
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let mark = fields[0]
	"let line = fields[1]
	"let column = fields[2]
	" ---- go
	call wheel#line#target (target)
	execute "normal `" .. mark
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#jumps (settings)
	" Go to element in jumps list given by selection
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let bufnum = fields[0]
	let linum = str2nr(fields[1])
	let colnum = str2nr(fields[2])
	" ---- go
	call wheel#line#target (target)
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#changes (settings)
	" Go to element in changes list given by selection
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	let bufnum = a:settings.related_buffer
	" ---- go
	call wheel#line#target (target)
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#tags (settings)
	" Go to settings.selection tag
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let fields = split(selection, s:field_separ)
	let file = fields[2]
	let search = fields[3][1:]
	" ---- go
	call wheel#line#target (target)
	execute 'edit' file
	let found = search(search, 'sw')
	if found == 0
		echomsg 'wheel : tag not found : maybe you should update your tag file'
	endif
	if &foldopen =~ 'jump'
		normal! zv
	endif
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#narrow_file (settings)
	" Go to settings.selection narrowed line of current file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	let bufnum = settings.bufnum
	let fields = split(selection, s:field_separ)
	let linum = str2nr(fields[0])
	" ---- go
	call wheel#line#target (target)
	execute 'buffer' bufnum
	call cursor(linum, 1)
	return win_getid ()
endfun

fun! wheel#line#narrow_circle (settings)
	" Go to settings.selection narrowed line in circle
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let selection = settings.selection
	"let index = selection.index
	let fields = split(selection, s:field_separ)
	let bufnum = str2nr(fields[0])
	let linum = str2nr(fields[1])
	" ---- go
	call wheel#line#target (a:settings.target)
	" -- using error number
	"let errnum = index + 1
	"execute 'cc' errnum
	" -- using buffer, line & col
	execute 'buffer' bufnum
	call cursor(linum, 1)
	" ---- coda
	return win_getid ()
endfun

" -- paste

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
	if wheel#pencil#is_selection_empty ()
		let line = getline('.')
		if empty(line)
			return v:false
		endif
		let content = eval(line)
	else
		let selection = wheel#pencil#selection ()
		let content = deepcopy(selection.addresses)
		eval content->map({ _, list_string -> eval(list_string) })
		eval content->map({ _, list -> join(list, "\n") })
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
		call wheel#cylinder#close ()
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
	if wheel#pencil#is_selection_empty ()
		let content = [ getline('.') ]
	else
		let selection = wheel#pencil#selection ()
		let content = deepcopy(selection.addresses)
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
	let @" = join(content)
	call wheel#cylinder#recall ()
	if close == 'close'
		call wheel#cylinder#close ()
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
		call wheel#cylinder#close ()
	endif
	return win_getid ()
endfun

" -- undo list

fun! wheel#line#undolist (bufnum)
	" Jump to change in settings.selection
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
