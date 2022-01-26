" vim: set ft=vim fdm=indent iskeyword&:

" Non-wheel action of the cursor line :
"
" - going to an element
" - paste
" - undo & diff
"
" called by loop#selection, and sometimes loop#boomerang

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" -- applications

fun! wheel#line#buffers (settings)
	" Go to buffer
	" ---- settings
	let settings = a:settings
	let component = settings.selection.component
	let fields = split(component, s:field_separ, v:true)
	let bufnum = str2nr(fields[0])
	let filename = fnamemodify(fields[3], ':p')
	let is_context_menu = has_key(settings, 'menu') && settings.menu.class == 'menu/context'
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
			let where = wheel#curve#where (target)
			call wheel#curve#target (target)
			call wheel#vortex#chord (coordin)
			call wheel#vortex#jump (where)
		else
			call wheel#curve#target (target)
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
	" Go to tab & win
	" ---- settings
	let settings = a:settings
	let component = settings.selection.component
	let is_context_menu = has_key(settings, 'menu') && settings.menu.class == 'menu/context'
	if is_context_menu
		let action = settings.menu.action
	else
		let action = 'open'
	endif
	" ---- actions
	if action == 'open'
		let fields = split(component, s:field_separ)
		let tabnum = fields[0]
		let winum = fields[1]
		execute 'noautocmd tabnext' tabnum
		execute 'noautocmd' winum 'wincmd w'
		doautocmd WinEnter
	elseif action == 'tabclose'
		let fields = split(component, s:field_separ)
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
	" Go to tab & win in tree fold
	" ---- settings
	let settings = a:settings
	let hierarchy = settings.selection.component
	let tabnum = hierarchy[0]
	let is_context_menu = has_key(settings, 'menu') && settings.menu.class == 'menu/context'
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
	" Go to buffer line matching pattern
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let bufnum = a:settings.related_buffer
	" ---- go
	let fields = split(component, s:field_separ)
	let line = str2nr(fields[0])
	call wheel#curve#target (target)
	execute 'buffer' bufnum
	call cursor(line, 1)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#grep (settings)
	" Go to grep quickfix line
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	" ---- go
	call wheel#curve#target (target)
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
	" Edit Most Recently Used file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let filename = fields[1]
	" ---- go
	call wheel#curve#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#locate (settings)
	" Find file with locate command
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let filename = settings.selection.component
	" ---- go
	call wheel#curve#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#find (settings)
	" Find file with find command
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let filename = settings.selection.component
	let filename = trim(filename, ' ')
	" ---- go
	call wheel#curve#target (target)
	execute 'edit' filename
	return win_getid ()
endfun

fun! wheel#line#markers (settings)
	" Go to vim marker
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let mark = fields[0]
	"let line = fields[1]
	"let column = fields[2]
	" ---- go
	call wheel#curve#target (target)
	execute "normal `" .. mark
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

fun! wheel#line#jumps (settings)
	" Go to element in jumps list
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let bufnum = fields[0]
	let linum = str2nr(fields[1])
	let colnum = str2nr(fields[2])
	" ---- go
	call wheel#curve#target (target)
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
	" Go to element in changes list
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	let bufnum = a:settings.related_buffer
	" ---- go
	call wheel#curve#target (target)
	execute 'buffer' bufnum
	call cursor(linum, colnum)
	if &foldopen =~ 'jump'
		normal! zv
	endif
	return win_getid ()
endfun

fun! wheel#line#tags (settings)
	" Go to tag
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let file = fields[2]
	let search = fields[3][1:]
	" ---- go
	call wheel#curve#target (target)
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
	" Go to narrowed line of current file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let bufnum = settings.bufnum
	let fields = split(component, s:field_separ)
	let linum = str2nr(fields[0])
	" ---- go
	call wheel#curve#target (target)
	execute 'buffer' bufnum
	call cursor(linum, 1)
	return win_getid ()
endfun

fun! wheel#line#narrow_circle (settings)
	" Go to narrowed line in circle
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let index = settings.selection.index
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let bufnum = str2nr(fields[0])
	let linum = str2nr(fields[1])
	" ---- go
	call wheel#curve#target (a:settings.target)
	" -- using error number
	let errnum = index + 1
	execute 'cc' errnum
	" -- using buffer, line & col
	"execute 'buffer' bufnum
	"call cursor(linum, 1)
	" ---- coda
	if settings.follow
		call wheel#projection#follow ()
	endif
	return win_getid ()
endfun

" -- paste

fun! wheel#line#paste_list (...)
	" Paste line(s) from yank buffer in list mode
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
		let content = deepcopy(selection.components)
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
	" Paste line(s) from yank buffer in plain mode
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
		let content = deepcopy(selection.components)
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
	" Apply change in undo list
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
