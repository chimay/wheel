" vim: set ft=vim fdm=indent iskeyword&:

" Folding in mandalas

" Script constants

if ! exists('s:selection_pattern')
	let s:selection_pattern = wheel#crystal#fetch('selection/pattern')
	lockvar s:selection_pattern
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Fold for torus, circle and location

fun! wheel#origami#chord_level ()
	" Wheel level of fold line : torus, circle or location
	if ! &foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return v:false
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'torus'
	elseif line =~ s:fold_2
		return 'circle'
	else
		return 'location'
	endif
endfun

fun! wheel#origami#chord_parent ()
	" Go to line of parent fold in wheel tree
	let level = wheel#origami#chord_level ()
	if level == 'circle'
		let pattern = '\m' .. s:fold_1 .. '$'
	elseif level == 'location'
		let pattern = '\m' .. s:fold_2 .. '$'
	else
		" torus line : we stay there
		return
	endif
	call search(pattern, 'b')
endfun

fun! wheel#origami#chord ()
	" Return wheel coordinates of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = wheel#pencil#erase (cursor_line)
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		return []
	endif
	let level = wheel#origami#chord_level ()
	if level == 'torus'
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif level == 'circle'
		" circle line : search torus
		let circle = cursor_list[0]
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#erase (line)
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle]
	elseif level == 'location'
		" location line : search circle & torus
		let location = cursor_line
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#erase (line)
		let fields = split(line)
		let circle = fields[0]
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#erase (line)
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle, location]
	else
		echomsg 'wheel line coordin : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun

" Fold for tabs & windows

fun! wheel#origami#tabwin_level ()
	" Tab & window : level of fold line, tab or filename
	if ! &foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return v:false
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'tab'
	else
		return 'filename'
	endif
endfun

fun! wheel#origami#tabwin_parent ()
	" Go to line of parent fold in tabwin tree
	let level = wheel#origami#tabwin_level ()
	if level == 'filename'
		let pattern = '\m' .. s:fold_1 .. '$'
		call search(pattern, 'b')
	else
		" tab line : we stay there
		return
	endif
endfun

fun! wheel#origami#tabwin ()
	" Return tab & filename of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = wheel#pencil#erase (cursor_line)
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
		" filename line : find window tab-local number & tab index
		let filename = cursor_list[0]
		let fileline = line('.')
		call wheel#origami#tabwin_parent ()
		let tabline = line('.')
		let winum = fileline - tabline
		let line = getline('.')
		let line = wheel#pencil#erase (line)
		let fields = split(line)
		let tabnum = str2nr(fields[1])
		let coordin = [tabnum, winum, filename]
	else
		echomsg 'tabwin hierarchy : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun
