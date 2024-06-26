" vim: set ft=vim fdm=indent iskeyword&:

" Line
"
" Native action on the cursor line :
"
" - going to an element
" - paste
" - undo & diff
"
" called by loop#navigation

" ---- script constants

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- buffers, tabs, wins

fun! wheel#line#buffer (settings)
	" Go to buffer
	" ---- settings
	let settings = a:settings
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let bufnum = str2nr(fields[0])
	let filename = fnamemodify(fields[3], ':p')
	let target = settings.target
	" ---- navigation
	let coordin = wheel#projection#closest ('wheel', filename)
	if ! empty(coordin)
		call wheel#vortex#chord (coordin)
		call wheel#vortex#jump (target)
	else
		call wheel#vortex#target (target)
		execute 'silent hide buffer' bufnum
	endif
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#tabwin (settings)
	" Go to tab & win
	" ---- settings
	let settings = a:settings
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let tabnum = fields[0]
	let winum = fields[1]
	" ---- navigation
	execute 'noautocmd tabnext' tabnum
	execute 'noautocmd' winum 'wincmd w'
	doautocmd WinEnter
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#tabwin_tree (settings)
	" Go to tab & win in tree fold
	" ---- settings
	let settings = a:settings
	let hierarchy = settings.selection.component
	let tabnum = hierarchy[0]
	" ---- actions
	execute 'noautocmd tabnext' tabnum
	if len(hierarchy) > 1
		let winum = hierarchy[1]
		execute 'noautocmd' winum 'wincmd w'
	endif
	doautocmd WinEnter
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

" ---- search file

fun! wheel#line#mru (settings)
	" Edit Most Recently Used file
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let filename = fields[1]
	" ---- go
	call wheel#vortex#target (target)
	execute 'silent hide edit' filename
	normal! '"
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	return win_getid ()
endfun

fun! wheel#line#locate (settings)
	" Find file with locate command
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let filename = settings.selection.component
	" ---- go
	call wheel#vortex#target (target)
	execute 'silent hide edit' filename
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
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
	call wheel#vortex#target (target)
	execute 'silent hide edit' filename
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

" ---- search in file

fun! wheel#line#occur (settings)
	" Go to buffer line matching pattern
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let bufnum = a:settings.related.bufnum
	" ---- go
	let fields = split(component, s:field_separ)
	let line = str2nr(fields[0])
	call wheel#vortex#target (target)
	execute 'silent hide buffer' bufnum
	call cursor(line, 1)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
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
	call wheel#vortex#target (target)
	" -- using error number
	let errnum = fields[0]
	execute 'cc' errnum
	" -- using buffer, line & col
	"let bufnum = str2nr(fields[1])
	"let line = str2nr(fields[3])
	"let col = str2nr(fields[4])
	"execute 'silent hide buffer' bufnum
	"call cursor(line, col)
	" ---- coda
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#marker (settings)
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
	call wheel#vortex#target (target)
	execute "normal! `" .. mark
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#jump (settings)
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
	call wheel#vortex#target (target)
	execute 'silent hide buffer' bufnum
	call cursor(linum, colnum)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#change (settings)
	" Go to element in changes list
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let linum = str2nr(fields[0])
	let colnum = str2nr(fields[1])
	let bufnum = a:settings.related.bufnum
	" ---- go
	call wheel#vortex#target (target)
	execute 'silent hide buffer' bufnum
	call cursor(linum, colnum)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#tag (settings)
	" Go to tag
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let file = fields[2]
	let search = fields[3][1:]
	let search = escape(search, '*')
	" ---- go
	call wheel#vortex#target (target)
	execute 'silent hide edit' file
	let found = search(search, 'sw')
	if found == 0
		echomsg 'wheel : tag not found : maybe you should update your tag file'
	endif
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
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
	call wheel#vortex#target (target)
	execute 'silent hide buffer' bufnum
	call cursor(linum, 1)
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

fun! wheel#line#narrow_circle (settings)
	" Go to narrowed line in circle
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let pattern = settings.pattern
	let index = settings.selection.index
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let bufnum = str2nr(fields[0])
	let linum = str2nr(fields[1])
	let destination = [bufnum, linum]
	if len(fields) == 4
		let content = fields[3]
	else
		let content = ''
	endif
	" ---- go
	call wheel#vortex#target (a:settings.target)
	if content =~ pattern
		" grep result
		let pairs = getqflist()->map({ _, val -> [ val.bufnr, val.lnum ] })
		let index = pairs->index(destination)
		let errnum = index + 1
		execute 'cc' errnum
	else
		" context line
		execute 'silent hide buffer' bufnum
		call cursor(linum, 1)
	endif
	" ---- coda
	call wheel#origami#view_cursor ()
	call wheel#chakra#place_native ()
	silent doautocmd User WheelAfterNative
	return win_getid ()
endfun

" ---- paste

fun! wheel#line#paste_plain (where = 'linewise-after', close = 'close')
	" Paste line(s) from yank buffer in plain mode
	let where = a:where
	let close = a:close
	" ---- format selection
	let selection = wheel#pencil#selection ()
	let content = deepcopy(selection.components)
	if empty(content)
		return v:false
	endif
	" --- climbing content
	call wheel#codex#climb(content)
	" --- clipboard option registers
	let clipreg = substitute(&clipboard, 'unnamedplus', '+', '')
	let clipreg = substitute(clipreg, 'unnamed', '*', '')
	let clipboard = [ '"' ]->extend(split(clipreg, ','))
	" ---- paste
	call wheel#rectangle#goto_previous ()
	if where ==# 'linewise-after'
		for register in clipboard
			call setreg(register, content, 'l')
		endfor
		silent put =content
	elseif where ==# 'linewise-before'
		for register in clipboard
			call setreg(register, content, 'l')
		endfor
		silent put! =content
	elseif where ==# 'charwise-after'
		for register in clipboard
			call setreg(register, content, 'c')
		endfor
		silent normal! p
	elseif where ==# 'charwise-before'
		for register in clipboard
			call setreg(register, content, 'c')
		endfor
		silent normal! P
	endif
	" ---- coda
	call wheel#cylinder#recall ()
	if close ==# 'close'
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
	call wheel#rectangle#goto_previous ()
	if where ==# 'after'
		silent normal! p
	elseif where ==# 'before'
		silent normal! P
	endif
	call wheel#cylinder#recall ()
	if close ==# 'close'
		call wheel#cylinder#close ()
	endif
	return win_getid ()
endfun

fun! wheel#line#paste_list (where = 'linewise-after', close = 'close')
	" Paste line(s) from yank buffer in list mode
	let where = a:where
	let close = a:close
	" ---- format selection
	let selection = wheel#pencil#selection ()
	let content = deepcopy(selection.components)
	eval content->map({ _, list_string -> eval(list_string) })
	eval content->map({ _, list -> join(list, "\n") })
	" --- climbing content
	call wheel#codex#climb(content)
	" --- clipboard option registers
	let clipreg = substitute(&clipboard, 'unnamedplus', '+', '')
	let clipreg = substitute(clipreg, 'unnamed', '*', '')
	let clipboard = [ '"' ]->extend(split(clipreg, ','))
	" ---- paste
	call wheel#rectangle#goto_previous ()
	if where ==# 'linewise-after'
		for register in clipboard
			call setreg(register, content, 'l')
		endfor
		silent put =content
	elseif where ==# 'linewise-before'
		for register in clipboard
			call setreg(register, content, 'l')
		endfor
		silent put! =content
	elseif where ==# 'charwise-after'
		for register in clipboard
			call setreg(register, content, 'c')
		endfor
		silent normal! p
	elseif where ==# 'charwise-before'
		for register in clipboard
			call setreg(register, content, 'c')
		endfor
		silent normal! P
	endif
	" ---- coda
	call wheel#cylinder#recall ()
	if close ==# 'close'
		call wheel#cylinder#close ()
	endif
	return win_getid ()
endfun

" ---- undo list

fun! wheel#line#undolist (bufnum)
	" Apply change in undo list
	let iden = wheel#delta#undo_iden ()
	call wheel#rectangle#find_or_load (a:bufnum)
	execute 'undo' iden
	call wheel#cylinder#recall ()
endfun

fun! wheel#line#undo_diff (bufnum)
	" Visualize diff between last state & undo
	let iden = wheel#delta#undo_iden ()
	" ---- original buffer
	call wheel#rectangle#find_or_load (a:bufnum)
	let save = {}
	let save.name = expand('%')
	let save.filetype = &l:filetype
	" ---- copy of original buffer
	vnew
	silent read #
	call wheel#gear#delete (1)
	let diff_buf = bufnr('%')
	setlocal buftype=nofile
	execute 'silent file' 'wheel/diff/' .. save.name
	let &l:filetype = save.filetype
	diffthis
	setlocal nomodifiable readonly
	" ---- original buffer
	call wheel#rectangle#find_or_load (a:bufnum)
	execute 'undo' iden
	diffthis
	" ---- back to mandala
	call wheel#cylinder#recall ()
	let b:wheel_settings.diff_buf = diff_buf
endfun
