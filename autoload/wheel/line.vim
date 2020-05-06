" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element
" - Paste

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
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

fun! wheel#line#address ()
	" Return address of element at line in plain or folded wheel buffer
	if ! &foldenable
		let cursor_line = getline('.')
		let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
		return cursor_line
	else
		return wheel#line#coordinates ()
	endif
endfun

fun! wheel#line#coordinates ()
	" Return coordinates of line in folded wheel buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		echomsg 'Wheel line coordin : empty line'
		return
	endif
	let level = wheel#gear#fold_level ()
	if level == 'torus'
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif level == 'circle'
		" circle line : search torus
		let circle = cursor_list[0]
		call wheel#gear#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle]
	elseif level == 'location'
		" location line : search circle & torus
		let location = cursor_line
		call wheel#gear#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let circle = fields[0]
		call wheel#gear#parent_fold ()
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle, location]
	else
		echomsg 'Wheel line coordin : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun

" Selection

fun! wheel#line#toggle ()
	" Toggle selection of current line
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
	let line = getline('.')
	if empty(line)
		return
	endif
	if line !~ s:selected_pattern
		let record = line
	else
		let record = substitute(line, s:selected_pattern, '', '')
	endif
	let coordin = wheel#line#address ()
	let index = index(b:wheel_selected, coordin)
	if index < 0
		call add(b:wheel_selected, coordin)
		let selected_line = substitute(line, '\m^', s:selected_mark, '')
		call setline('.', selected_line)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = selected_line
	else
		call remove(b:wheel_selected, index)
		call setline('.', record)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = record
	endif
endfun

fun! wheel#line#sync_select ()
	" Sync buffer lines from b:wheel_selected
	if ! exists('b:wheel_selected')
		return
	endif
	let position = getcurpos()
	for linum in range(line('$'))
		call cursor(linum, 1)
		let line = getline('.')
		if empty(line)
			continue
		endif
		if line !~ s:selected_pattern
			let record = line
		else
			let record = substitute(line, s:selected_pattern, '', '')
		endif
		let coordin = wheel#line#address ()
		let index = index(b:wheel_selected, coordin)
		if index >= 0
			let selected_line = substitute(record, '\m^', s:selected_mark, '')
			call setline('.', selected_line)
			if exists('b:wheel_lines')
				" Update b:wheel_lines
				let pos = index(b:wheel_lines, line)
				let b:wheel_lines[pos] = selected_line
			endif
		else
			call setline('.', record)
			if exists('b:wheel_lines')
				" Update b:wheel_lines
				let pos = index(b:wheel_lines, line)
				let b:wheel_lines[pos] = record
			endif
		endif
	endfor
	call wheel#gear#restore_cursor (position)
endfun

fun! wheel#line#deselect ()
	" Deselect all selected lines
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
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

" Filter

fun! wheel#line#filter ()
	" Return lines matching words of first line
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	let linelist = copy(b:wheel_lines)
	let first = getline(1)
	let wordlist = split(first)
	if empty(wordlist)
		return linelist
	endif
	call wheel#scroll#record(first)
	let Matches = function('wheel#gear#tree_filter', [wordlist])
	let candidates = filter(linelist, Matches)
	" two times : cleans a level each time
	let filtered = wheel#gear#fold_filter(wordlist, candidates)
	let filtered = wheel#gear#fold_filter(wordlist, filtered)
	" Return
	return filtered
endfu

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
	" - close : whether to close wheel buffer
	" - travel : whether to apply action in previous buffer
	let settings = a:settings
	let dict = wheel#crystal#fetch (settings.linefun)
	let close = settings.close
	let travel = settings.travel
	" Cursor line
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	if empty(cursor_line)
		echomsg 'Wheel layer call : you selected an empty line'
		return
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		normal! zv
		call wheel#spiral#cursor ()
		echomsg 'Wheel layer call : key not found'
		return
	endif
	" Close & travel
	if close
		call wheel#mandala#close ()
	elseif travel
		let mandala = win_getid()
		wincmd p
	endif
	" Call
	let value = dict[key]
	if value =~ '\m)'
		exe 'call ' . value
	else
		call {value}()
	endif
	" Goto mandala if needed
	if ! close && travel
		call win_gotoid (mandala)
	endif
endfun

" Navigation

fun! wheel#line#sailing (settings)
	" Go to element(s) on current or selected line(s)
	" settings keys :
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	" - close : whether to close special buffer
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
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		let selected = [wheel#line#address ()]
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'Wheel line navigation : bad format for b:wheel_selected'
	endif
	if len(selected) == 1
		let settings.use = 'default'
	else
		let settings.use = 'new'
	endif
	if close
		call wheel#mandala#close ()
	else
		let position = getcurpos()
		let mandala = win_getid()
		wincmd p
	endif
	if type(Fun) == v:t_func
		if target != 'current'
			for elem in selected
				let settings.selected = elem
				call Fun (settings)
				normal! zv
				call wheel#spiral#cursor ()
			endfor
		else
			let settings.selected = selected[0]
			call Fun (settings)
			normal! zv
			call wheel#spiral#cursor ()
		endif
	elseif type(Fun) == v:t_string
		if target != 'current'
			for elem in selected
				let settings.selected = elem
				call {Fun} (settings)
				normal! zv
				call wheel#spiral#cursor ()
			endfor
		else
			let settings.selected = selected[0]
			call {Fun} (settings)
			normal! zv
			call wheel#spiral#cursor ()
		endif
	else
		echomsg 'Wheel line navigation : bad function'
	endif
	if ! close
		call win_gotoid(mandala)
		call wheel#line#deselect ()
		call wheel#gear#restore_cursor (position)
	endif
endfun

fun! wheel#line#switch (settings)
	" Switch to settings.selected element in wheel
	" settings keys :
	" - selected : where to switch
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	let settings = a:settings
	call wheel#line#target (settings.target)
	call wheel#vortex#switch(settings.level, settings.selected, settings.use)
endfun

fun! wheel#line#helix (settings)
	" Go to settings.selected = torus > circle > location
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = split(a:settings.selected, ' > ')
	if len(coordin) < 3
		echomsg 'Helix line is too short'
		return
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:settings.use)
endfun

fun! wheel#line#grid (settings)
	" Go to settings.selected = torus > circle
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = split(a:settings.selected, ' > ')
	if len(coordin) < 2
		echomsg 'Grid line is too short'
		return
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#tune('torus', coordin[0])
	call wheel#vortex#tune('circle', coordin[1])
	call wheel#vortex#jump (a:settings.use)
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
	endif
	call wheel#vortex#jump (a:settings.use)
endfun

fun! wheel#line#history (settings)
	" Go to settings.selected history location
	" settings keys :
	" - selected : where to go
	" - target : current, tab, horizontal_split, vertical_split
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 2
		echomsg 'History line is too short'
		return
	endif
	let coordin = split(fields[1], ' > ')
	if len(coordin) < 3
		echomsg 'History : coordinates should contain 3 elements'
		return
	endif
	call wheel#line#target (a:settings.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:settings.use)
endfun

fun! wheel#line#occur (settings)
	" Go to line given by selected
	let fields = split(a:settings.selected, s:field_separ)
	let line = fields[0]
	call wheel#line#target (a:settings.target)
	call cursor(line, 1)
endfun

fun! wheel#line#grep (settings)
	" Go to settings.selected quickfix line
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 5
		echomsg 'Grep line is too short'
		return
	endif
	let bufnum = fields[0]
	let line = fields[2]
	let col = fields[3]
	call wheel#line#target (a:settings.target)
	exe 'buffer ' . bufnum
	call cursor(line, col)
endfun

fun! wheel#line#attic (settings)
	" Edit settings.selected MRU file
	let fields = split(a:settings.selected)
	if len(fields) < 2
		echomsg 'MRU line is too short'
		return
	endif
	let filename = fields[6]
	call wheel#line#target (a:settings.target)
	exe 'edit ' . filename
endfun

fun! wheel#line#locate (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	call wheel#line#target (a:settings.target)
	exe 'edit ' . filename
endfun

fun! wheel#line#find (settings)
	" Edit settings.selected locate file
	let filename = a:settings.selected
	let filename = trim(filename, ' ')
	call wheel#line#target (a:settings.target)
	exe 'edit ' . filename
endfun

fun! wheel#line#symbol (settings)
	" Go to settings.selected tag
	let fields = split(a:settings.selected, s:field_separ)
	if len(fields) < 4
		echomsg 'Tag line is too short'
		return
	endif
	let ident = fields[0]
	call wheel#line#target (a:settings.target)
	exe 'tag ' . ident
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
	if exists('b:wheel_selected') && ! empty(b:wheel_selected)
		let content = eval(b:wheel_selected[0])
	else
		let line = getline('.')
		if empty(line)
			return
		endif
		let content = eval(line)
	endif
	let mandala = win_getid()
	wincmd p
	if where == 'after'
		put =content
	elseif where == 'before'
		put! =content
	endif
	let @" = join(content, "\n")
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
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
	if exists('b:wheel_selected') && ! empty(b:wheel_selected)
		let content = b:wheel_selected[0]
	else
		let content = getline('.')
	endif
	if empty(content)
		return
	endif
	let mandala = win_getid()
	wincmd p
	if where == 'after'
		put =content
	elseif where == 'before'
		put! =content
	endif
	let @" = content
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
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
	let mandala = win_getid()
	wincmd p
	if where == 'after'
		put "
	elseif where == 'before'
		put! "
	endif
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
endfun
