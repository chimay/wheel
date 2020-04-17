" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element
" - Paste

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = '* '
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = '\m^\* '
	lockvar s:selected_pattern
endif

" Helpers

fun! wheel#line#coordin ()
	" Return coordin of line in plain or folded special buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		echomsg 'Wheel line coordin : empty line'
		return
	endif
	if foldlevel('.') == 2 && len(cursor_list) == 1
		" location line : search circle & torus
		let location = cursor_line
		normal! [z
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let circle = fields[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle, location]
	elseif foldlevel('.') == 2
		" circle line : search torus
		let circle = cursor_list[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, s:selected_pattern, '', '')
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle]
	elseif foldlevel('.') == 1
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif foldlevel('.') == 0
		" Can be used as :
		" - simple name line of level depending of buffer
		" - generic line (grep, mru, ...) with :setlocal nofoldenable
		let coordin = cursor_line
	else
		echomsg 'Wheel line coordin : wrong fold level'
	endif
	call setpos('.', position)
	return coordin
endfun

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
		let name = line
	else
		let name = substitute(line, s:selected_pattern, '', '')
	endif
	let coordin = wheel#line#coordin ()
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
		call setline('.', name)
		" Update b:wheel_lines
		let pos = index(b:wheel_lines, line)
		let b:wheel_lines[pos] = name
	endif
endfun

fun! wheel#line#deselect ()
	" Deselect all selected lines
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let b:wheel_lines = getline(2, '$')
	endif
	let b:wheel_selected = []
	let buflines = getline(2,'$')
	for index in range(len(buflines))
		let line = buflines[index]
		if line =~ s:selected_pattern
			let buflines[index] = substitute(line, s:selected_pattern, '', '')
		endif
	endfor
	for index in range(len(b:wheel_lines))
		let line = b:wheel_lines[index]
		if line =~ s:selected_pattern
			let b:wheel_lines[index] = substitute(line, s:selected_pattern, '', '')
		endif
	endfor
	2,$ delete _
	put =buflines
	call cursor(1, 1)
endfun

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
	let Matches = function('wheel#gear#filter', [wordlist])
	let candidates = filter(linelist, Matches)
	" two times : cleans a level each time
	let filtered = wheel#gear#fold_filter(wordlist, candidates)
	let filtered = wheel#gear#fold_filter(wordlist, filtered)
	" Return
	return filtered
endfu

fun! wheel#line#target (target)
	" Open target tab / win before switching
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

" Switch

fun! wheel#line#switch (dict)
	" Switch to element(s) on current or selected line(s)
	" dict keys :
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	" - close : whether to close special buffer
	" - action : switch function or name of switch function
	let dict = copy(a:dict)
	if has_key(dict, 'target')
		let target = dict.target
	else
		let target = 'current'
		let dict.target = target
	endif
	if has_key(dict, 'close')
		let close = dict.close
	else
		let close = v:true
	endif
	if has_key(dict, 'action')
		let Fun = dict.action
	else
		let Fun = 'wheel#line#name'
	endif
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		let selected = [wheel#line#coordin ()]
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'Wheel line switch : bad format for b:wheel_selected'
	endif
	if len(selected) == 1
		let dict.use = 'default'
	else
		let dict.use = 'new'
	endif
	if close
		call wheel#mandala#close ()
	else
		let mandala = win_getid()
		wincmd p
	endif
	if type(Fun) == v:t_func
		if target != 'current'
			for elem in selected
				let dict.selected = elem
				call Fun (dict)
			endfor
		else
			let dict.selected = selected[0]
			call Fun (dict)
		endif
	elseif type(Fun) == v:t_string
		if target != 'current'
			for elem in selected
				let dict.selected = elem
				call {Fun} (dict)
			endfor
		else
			let dict.selected = selected[0]
			call {Fun} (dict)
		endif
	else
		echomsg 'Wheel line switch : bad switch function'
	endif
	if ! close
		call win_gotoid(mandala)
		call wheel#line#deselect ()
	endif
endfun

fun! wheel#line#name (dict)
	" Switch to dict.selected by name
	" dict keys :
	" - selected : where to switch
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	call wheel#line#target (a:dict.target)
	call wheel#vortex#switch(a:dict.level, a:dict.selected, a:dict.use)
endfun

fun! wheel#line#helix (dict)
	" Switch to dict.selected = torus > circle > location
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let fields = split(a:dict.selected)
	if len(fields) < 5
		echomsg 'Helix line is too short'
		return
	endif
	let coordin = [fields[0], fields[2], fields[4]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:dict.use)
endfun

fun! wheel#line#grid (dict)
	" Switch to dict.selected = torus > circle
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let fields = split(a:dict.selected)
	if len(fields) < 3
		echomsg 'Grid line is too short'
		return
	endif
	let coordin = [fields[0], fields[2]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#tune('torus', coordin[0])
	call wheel#vortex#tune('circle', coordin[1])
	call wheel#vortex#jump (a:dict.use)
endfun

fun! wheel#line#tree (dict)
	" Switch to dict.selected
	" Possible vallues of selected :
	" - [torus]
	" - [torus, circle]
	" - [torus, circle, location]
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let coordin = a:dict.selected
	let length = len(coordin)
	call wheel#line#target (a:dict.target)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#tune('torus', coordin[0])
		call wheel#vortex#tune('circle', coordin[1])
	elseif length == 1
		call wheel#vortex#tune('torus', coordin[0])
	endif
	call wheel#vortex#jump (a:dict.use)
endfun

fun! wheel#line#history (dict)
	" Switch to dict.selected history location
	" dict keys :
	" - selected : where to switch
	" - target : current, tab, horizontal_split, vertical_split
	let fields = split(a:dict.selected)
	if len(fields) < 11
		echomsg 'History line is too short'
		return
	endif
	let coordin = [fields[6], fields[8], fields[10]]
	call wheel#line#target (a:dict.target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (a:dict.use)
endfun

fun! wheel#line#grep (dict)
	" Switch to current quickfix line
	let fields = split(a:dict.selected)
	if len(fields) < 9
		echomsg 'Grep line is too short'
		return
	endif
	let bufnr = fields[0]
	let line = fields[4]
	let col = fields[6]
	call wheel#line#target (a:dict.target)
	exe 'buffer ' . bufnr
	call cursor(line, col)
endfun

fun! wheel#line#attic (dict)
	" Edit dict.selected MRU file
	let fields = split(a:dict.selected)
	if len(fields) < 7
		echomsg 'MRU line is too short'
		return
	endif
	let filename = fields[6]
	call wheel#line#target (a:dict.target)
	exe 'edit ' . filename
endfun

fun! wheel#line#locate (dict)
	" Edit dict.selected MRU file
	let filename = a:dict.selected
	call wheel#line#target (a:dict.target)
	exe 'edit ' . filename
endfun

" Paste

fun! wheel#line#paste_list (...)
	" Paste elements in current line from yank buffer in fields mode
	if a:0 > 0
		let close = a:1
	else
		let close = 'close'
	endif
	let line = getline('.')
	let runme = 'let content = ' . line
	exe runme
	let mandala = win_getid()
	wincmd p
	put =content
	let @" = join(content, "\n")
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
endfun

fun! wheel#line#paste_plain (...)
	" Paste line from yank buffer in plain mode
	if a:0 > 0
		let close = a:1
	else
		let close = 'close'
	endif
	let content = getline('.')
	let mandala = win_getid()
	wincmd p
	put =content
	let @" = content
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
endfun

fun! wheel#line#paste_visual (...)
	" Paste visual selection from yank buffer in plain mode
	if a:0 > 0
		let close = a:1
	else
		let close = 'close'
	endif
	normal! gvy
	let mandala = win_getid()
	wincmd p
	put "
	call win_gotoid(mandala)
	if close == 'close'
		call wheel#mandala#close ()
	endif
endfun
