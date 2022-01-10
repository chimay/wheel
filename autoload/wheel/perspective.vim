" vim: set ft=vim fdm=indent iskeyword&:

" Content generators for :
"
"   - completion of prompting function
"   - dedicated buffers (mandalas)

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

if ! exists('s:is_mandala')
	let s:is_mandala = wheel#crystal#fetch('is_mandala')
	lockvar s:is_mandala
endif

if ! exists('s:is_buffer_tabs')
	let s:is_buffer_tabs = wheel#crystal#fetch('is_buffer/tabs')
	lockvar s:is_buffer_tabs
endif

if ! exists('s:is_mandala_tabs')
	let s:is_mandala_tabs = wheel#crystal#fetch('is_mandala/tabs')
	lockvar s:is_mandala_tabs
endif

" Helpers

fun! wheel#perspective#execute (runme, ...)
	" Ex or system command
	if a:0 > 0
		let Execute = a:1
	else
		let Execute = function('execute')
	endif
	let runme = a:runme
	if type(Execute) == v:t_func
		let lines = Execute(runme)
	elseif type(Execute) == v:t_string
		let lines = {Execute}(runme)
	else
		echomsg 'wheel perspective execute : bad function argument'
	endif
	let lines = split(lines, "\n")
	return lines
endfun

" Wheel elements

" from referen

fun! wheel#perspective#switch (level)
	" Switch level = torus, circle or location
	let level = a:level
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		return upper.glossary
	else
		return []
	endif
endfun

" from helix

fun! wheel#perspective#helix ()
	" Locations index
	" Each coordinate is a string torus > circle > location
	let helix = wheel#helix#helix ()
	let lines = []
	for coordin in helix
		let entry = join(coordin, s:level_separ)
		let lines = add(lines, entry)
	endfor
	return lines
endfu

fun! wheel#perspective#grid ()
	" Circle index
	" Each coordinate is a string torus > circle
	let grid = wheel#helix#grid ()
	let lines = []
	for coordin in grid
		let entry = join(coordin, s:level_separ)
		let lines = add(lines, entry)
	endfor
	return lines
endfu

fun! wheel#perspective#tree ()
	" Tree representation of the wheel
	let lines = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			let lines = add(lines, entry)
			for location in circle.locations
				let entry = location.name
				let lines = add(lines, entry)
			endfor
		endfor
	endfor
	return lines
endfu

fun! wheel#perspective#reorganize ()
	" Content for reorganize buffer
	let lines = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		let lines = add(lines, entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			let lines = add(lines, entry)
			for location in circle.locations
				let entry = string(location)
				let lines = add(lines, entry)
			endfor
		endfor
	endfor
	return lines
endfu

" from pendulum

fun! wheel#perspective#history ()
	" Sorted history index
	" Each entry is a string : date hour | torus > circle > location
	let history = deepcopy(g:wheel_history)
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let history = sort(history, Compare)
	let strings = []
	for entry in history
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ
		let entry ..= coordin[0] .. s:level_separ .. coordin[1] .. s:level_separ .. coordin[2]
		let strings = add(strings, entry)
	endfor
	return strings
endfu

" Search file

fun! wheel#perspective#find (pattern)
	" Find files in current directory using **/*pattern* glob
	let pattern = a:pattern
	return glob(pattern, v:false, v:true)
endfun

fun! wheel#perspective#locate (pattern)
	" Locate
	let pattern = a:pattern
	let database = g:wheel_config.locate_db
	if empty(database)
		let runme = 'locate ' .. pattern
	else
		let runme = 'locate -d ' .. expand(database) .. ' ' .. pattern
	endif
	let lines = systemlist(runme)
	return lines
endfun

" from attic

fun! wheel#perspective#mru ()
	" Sorted most recenty used files
	" Each entry is a string : date hour | filename
	let attic = deepcopy(g:wheel_attic)
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let attic = sort(attic, Compare)
	let strings = []
	for entry in attic
		let filename = entry.file
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ
		let entry ..= filename
		let strings = add(strings, entry)
	endfor
	return strings
endfu

" Buffers

fun! wheel#perspective#buffers (...)
	" Buffers
	" Optional argument mode :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	" Exceptions :
	"   - buffers without name
	"   - wheel dedicated buffers (mandalas)
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'listed'
	endif
	if mode == 'listed'
		let buflist = getbufinfo({'buflisted' : 1})
	elseif mode == 'all'
		let buflist = getbufinfo()
	else
		echomsg 'wheel perspective buffers : bad optional argument'
		return []
	endif
	let lines = []
	let mandalas = g:wheel_mandalas.ring
	for buffer in buflist
		let bufnum = printf('%3d', buffer.bufnr)
		let linum = printf('%5d', buffer.lnum)
		let filename = buffer.name
		" indicator
		let indicator = ''
		if buffer.listed
			let indicator ..= ' '
		else
			let indicator ..= 'u'
		endif
		if buffer.loaded
			if ! buffer.hidden
				let indicator ..= 'a'
			else
				let indicator ..= 'h'
			endif
		else
			let indicator ..= ' '
		endif
		if buffer.changed
			let indicator ..= ' +'
		else
			let indicator ..= ' '
		endif
		" add to the lines
		let is_without_name = empty(filename)
		let is_wheel_buffer = wheel#chain#is_inside(bufnum, mandalas)
		if ! is_without_name && ! is_wheel_buffer
			let entry = [bufnum, indicator, linum, filename]
			let record = join(entry, s:field_separ)
			call add(lines, record)
		endif
	endfor
	return lines
endfun

" Tab & windows

fun! wheel#perspective#tabwins ()
	" Buffers visible in tabs & wins
	let lines = []
	let last_tab = tabpagenr('$')
	let mandalas = g:wheel_mandalas.ring
	for tabnum in range(1, last_tab)
		let buflist = tabpagebuflist(tabnum)
		let winum = 0
		for bufnum in buflist
			if wheel#chain#is_inside (bufnum, mandalas)
				continue
			endif
			let winum += 1
			let filename = bufname(bufnum)
			let entry = []
			call add(entry, printf('%3d', tabnum))
			call add(entry, printf('%3d', winum))
			call add(entry, filename)
			let record = join(entry, s:field_separ)
			call add(lines, record)
		endfor
	endfor
	return lines
endfun

fun! wheel#perspective#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	let lines = []
	let last_tab = tabpagenr('$')
	let mandalas = g:wheel_mandalas.ring
	for tabnum in range(1, last_tab)
		let record = 'tab ' .. tabnum .. s:fold_1
		call add(lines, record)
		let buflist = tabpagebuflist(tabnum)
		let winum = 0
		for bufnum in buflist
			if wheel#chain#is_inside (bufnum, mandalas)
				continue
			endif
			let winum += 1
			let filename = bufname(bufnum)
			let record = filename
			call add(lines, record)
		endfor
	endfor
	return lines
endfun

" Search inside file

fun! wheel#perspective#occur (pattern)
	" Occur
	let pattern = a:pattern
	let position = getcurpos()
	let runme = 'global /' .. pattern .. '/number'
	let lines = execute(runme)
	let lines = split(lines, "\n")
	for index in range(len(lines))
		let elem = lines[index]
		let fields = split(elem)
		let linum = fields[0]
		let content = join(fields[1:])
		let linum = printf('%5d', linum)
		let entry = [linum, content]
		let elem = join(entry, s:field_separ)
		let lines[index] = elem
	endfor
	call wheel#gear#restore_cursor(position)
	return lines
endfun

fun! wheel#perspective#markers ()
	" Markers
	let lines = []
	let bufnum = bufnr('%')
	let marklist = getmarklist(bufnum)
	call extend(marklist, getmarklist())
	for marker in marklist
		let mark = marker.mark[1:]
		if has_key(marker, 'file')
			let filename = marker.file
		else
			let filename = expand('%')
		endif
		let position = marker.pos
		let linum = position[1]
		let colnum = position[2]
		let bufnum = bufnr(filename)
		if bufnum > 0 && bufloaded(bufnum)
			let content = getbufline(bufnum, linum)[0]
		else
			let content = ' '
		endif
		let linum = printf('%5d', linum)
		let colnum = printf('%2d', colnum)
		let entry = [mark, linum, colnum, filename, content]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	return lines
endfun

fun! wheel#perspective#jumps ()
	" Jumps
	let lines = []
	let mandalas = g:wheel_mandalas.ring
	let jumplist = getjumplist()[0]
	for jump in jumplist
		let bufnum = jump.bufnr
		let linum = jump.lnum
		let colnum = jump.col
		if has_key(jump, 'filename')
			let filename = jump.filename
		else
			let filename = bufname(bufnum)
		endif
		let is_without_name = empty(filename)
		let is_wheel_buffer = wheel#chain#is_inside(bufnum, mandalas)
		let is_wheel_buffer = is_wheel_buffer || filename =~ s:is_mandala
		if is_without_name || is_wheel_buffer
			continue
		endif
		if bufloaded(bufnum)
			let content = getbufline(bufnum, linum)[0]
		else
			let content = ' '
		endif
		let bufnum = printf('%3d', bufnum)
		let linum = printf('%5d', linum)
		let colnum = printf('%2d', colnum)
		let entry = [bufnum, linum, colnum, filename, content]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	" newest first
	call reverse(lines)
	return lines
endfun

fun! wheel#perspective#changes ()
	" Changes
	let lines = []
	let changelist = getchangelist()[0]
	for change in changelist
		let linum = change.lnum
		let colnum = change.col
		let content = getline(linum)
		let linum = printf('%5d', linum)
		let colnum = printf('%2d', colnum)
		let entry = [linum, colnum, content]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	" newest first
	call reverse(lines)
	return lines
endfun

" from vector

fun! wheel#perspective#grep (pattern, sieve)
	" Quickfix list
	" Each line has the format :
	" err-number | buffer-number | file | line | col | text
	let bool = wheel#vector#grep (a:pattern, a:sieve)
	if ! bool
		" no file matching a:sieve
		return v:false
	endif
	let quickfix = getqflist()
	let list = []
	for index in range(len(quickfix))
		let elem = quickfix[index]
		let errnum = printf('%5d', index + 1)
		let linum = printf('%5d', elem.lnum)
		let colnum = printf('%5d', elem.col)
		let filename = bufname(elem.bufnr)
		let record = ''
		let record ..= errnum .. s:field_separ
		let record ..= linum .. s:field_separ
		let record ..= colnum .. s:field_separ
		let record ..= filename .. s:field_separ
		let record ..= elem.text
		call add(list, record)
	endfor
	return list
endfun

" from symbol

fun! wheel#perspective#tags ()
	" Tags
	let table = wheel#symbol#table ()
	let lines = []
	for fields in table
		let iden = fields[0]
		let filename = fields[1]
		let search = fields[2]
		let type = fields[3]
		let iden = printf('%5s', iden)
		let type = printf('%2s', type)
		let entry = [type, iden, filename, search]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	return lines
endfun

" Yanks

" from codex

fun! wheel#perspective#yank (mode)
	" Yank wheel
	let lines = []
	if a:mode == 'list'
		for elem in g:wheel_yank
			call add(lines, string(elem))
		endfor
	elseif a:mode == 'plain'
		for elem in g:wheel_yank
			let plain = join(elem, "\n")
			" Only add if some text is there
			if plain =~ '\m\w'
				call add(lines, plain)
			endif
		endfor
	endif
	return lines
endfun

" Undo list

fun! wheel#perspective#undolist ()
	" Undo list
	let undolist = execute('undolist')
	let undolist = split(undolist, '\n')
	if len(undolist) < 2
		return v:false
	endif
	let undolist = undolist[1:]
	let lines = []
	for elem in undolist
		let fields = split(elem)
		let iden = fields[0]
		let modif = fields[1]
		let time = join(fields[2:-2])
		let written = fields[-1]
		let entry = [iden, modif, time, written]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	" more recent first
	call reverse(lines)
	return lines
endfun
