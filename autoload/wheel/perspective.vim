" vim: set ft=vim fdm=indent iskeyword&:

" Perspective
"
" Content generators for :
"
"   - completion of prompting function
"   - dedicated buffers (mandalas)

" ---- script constants

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

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:is_buffer_tabs')
	let s:is_buffer_tabs = wheel#crystal#fetch('is_buffer/tabs')
	lockvar s:is_buffer_tabs
endif

if ! exists('s:is_mandala_tabs')
	let s:is_mandala_tabs = wheel#crystal#fetch('is_mandala/tabs')
	lockvar s:is_mandala_tabs
endif

" ---- helpers

fun! wheel#perspective#execute (runme, ...)
	" Ex or system command
	if a:0 > 0
		let Execute = a:1
	else
		let Execute = function('execute')
	endif
	let runme = a:runme
	if type(Execute) == v:t_func
		let returnlist = Execute(runme)
	elseif type(Execute) == v:t_string
		let returnlist = {Execute}(runme)
	else
		echomsg 'wheel perspective execute : bad function argument'
	endif
	let returnlist = split(returnlist, "\n")
	return returnlist
endfun

" ---- wheel elements

" -- from referen

fun! wheel#perspective#element (level)
	" Switch level = torus, circle or location
	let level = a:level
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		return upper.glossary
	else
		return []
	endif
endfun

fun! wheel#perspective#rename_file ()
	" Locations & files names
	let circle = deepcopy(wheel#referen#circle())
	if empty(circle) || empty(circle.glossary)
		return []
	endif
	let glossary = circle.glossary
	let locations = circle.locations
	let filenames = locations->map({ _, val -> val.file })
	let returnlist = []
	let len_circle = len(locations)
	for index in range(len_circle)
		let entry = [glossary[index], filenames[index]]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	return returnlist
endfun

" -- from helix

fun! wheel#perspective#helix ()
	" Locations index
	" Each coordinate is a string torus > circle > location
	let helix = deepcopy(wheel#helix#helix ())
	return helix->map({ _, val -> join(val, s:level_separ) })
endfun

fun! wheel#perspective#grid ()
	" Circle index
	" Each coordinate is a string torus > circle
	let grid = deepcopy(wheel#helix#grid ())
	return grid->map({ _, val -> join(val, s:level_separ) })
endfun

fun! wheel#perspective#tree ()
	" Tree representation of the wheel
	let returnlist = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		let returnlist = add(returnlist, entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			let returnlist = add(returnlist, entry)
			for location in circle.locations
				let entry = location.name
				let returnlist = add(returnlist, entry)
			endfor
		endfor
	endfor
	return returnlist
endfun

fun! wheel#perspective#reorganize ()
	" Content for reorganize buffer
	let returnlist = []
	for torus in g:wheel.toruses
		let entry = torus.name .. s:fold_1
		let returnlist = add(returnlist, entry)
		for circle in torus.circles
			let entry = circle.name .. s:fold_2
			let returnlist = add(returnlist, entry)
			for location in circle.locations
				let entry = string(location)
				let returnlist = add(returnlist, entry)
			endfor
		endfor
	endfor
	return returnlist
endfun

" -- from pendulum

fun! wheel#perspective#history ()
	" Naturally sorted timeline index
	" Each entry is a string : date hour | torus > circle > location
	let timeline = g:wheel_history.line
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let timeline = sort(timeline, Compare)
	let returnlist = []
	for entry in timeline
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ .. join(coordin, s:level_separ)
		let returnlist = add(returnlist, entry)
	endfor
	return returnlist
endfun

fun! wheel#perspective#history_circuit ()
	" History circuit
	" Each entry is a string : date hour | torus > circle > location
	let timeloop = g:wheel_history.circuit
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let timeloop = sort(timeloop, Compare)
	let returnlist = []
	for entry in timeloop
		let coordin = entry.coordin
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ .. join(coordin, s:level_separ)
		let returnlist = add(returnlist, entry)
	endfor
	return returnlist
endfun

" -- from cuckoo

fun! wheel#perspective#frecency ()
	" Frecency : frequent & recent
	let frecency = g:wheel_history.frecency
	let returnlist = []
	for entry in frecency
		let score = printf('%6d', entry.score)
		let coordin = entry.coordin
		let entry = score .. s:field_separ .. join(coordin, s:level_separ)
		let returnlist = add(returnlist, entry)
	endfor
	return returnlist
endfun

" ---- buffers

fun! wheel#perspective#buffer (scope = 'listed')
	" Buffers
	" Optional argument :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	" Exceptions :
	"   - buffers without name
	"   - wheel dedicated buffers (mandalas)
	let scope = a:scope
	if scope == 'listed'
		let buflist = getbufinfo({'buflisted' : 1})
	elseif scope == 'all'
		let buflist = getbufinfo()
	else
		echomsg 'wheel perspective buffer : bad optional argument'
		return []
	endif
	let returnlist = []
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
			let indicator ..= '  '
		endif
		" check for nameless or mandalas buffers
		let is_nameless = empty(filename)
		let is_wheel_buffer = wheel#chain#is_inside(bufnum, mandalas)
		let has_wheel_filename = filename =~ s:is_mandala_file
		if is_nameless || is_wheel_buffer || has_wheel_filename
			continue
		endif
		" add to the returnlist
		let entry = [bufnum, indicator, linum, filename]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	return returnlist
endfun

fun! wheel#perspective#narrow_file (first, last)
	" Narrow file
	" Optional argument :
	"   - range of lines
	"   - default : all buffer
	let first = a:first
	let last = a:last
	let numlist = range(first, last)
	let linelist = getline(first, last)
	let returnlist = wheel#matrix#dual([numlist, linelist])
	eval returnlist->map({ _, elem -> [ printf('%5d', elem[0]), elem[1] ] })
	eval returnlist->map({ _, elem -> join(elem, s:field_separ) })
	return returnlist
endfun

fun! wheel#perspective#narrow_circle (pattern, sieve)
	" Narrow circle files. Use quickfix list
	" Each line has the format :
	" buffer-number | line | file | text
	let bool = wheel#vector#grep (a:pattern, a:sieve)
	if ! bool
		" no file matching a:sieve
		return []
	endif
	let quickfix = getqflist()
	let list = []
	for index in range(len(quickfix))
		let elem = quickfix[index]
		let bufnum = printf('%3d', elem.bufnr)
		let linum = printf('%5d', elem.lnum)
		let filename = bufname(elem.bufnr)
		let filename = wheel#disc#relative_path (filename)
		let content = elem.text
		let entry = [bufnum, linum, filename, content]
		let record = join(entry, s:field_separ)
		eval list->add(record)
	endfor
	return list
endfun

" ---- tab & windows

fun! wheel#perspective#tabwin ()
	" Buffers visible in tabs & wins
	let returnlist = []
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
			let filename = fnamemodify(filename, ':p')
			let entry = []
			eval entry->add(printf('%3d', tabnum))
			eval entry->add(printf('%3d', winum))
			eval entry->add(filename)
			let record = join(entry, s:field_separ)
			eval returnlist->add(record)
		endfor
	endfor
	return returnlist
endfun

fun! wheel#perspective#tabwin_tree ()
	" Buffers visible in tree of tabs & wins
	let returnlist = []
	let last_tab = tabpagenr('$')
	let mandalas = g:wheel_mandalas.ring
	for tabnum in range(1, last_tab)
		let record = 'tab ' .. tabnum .. s:fold_1
		eval returnlist->add(record)
		let buflist = tabpagebuflist(tabnum)
		let winum = 0
		for bufnum in buflist
			if wheel#chain#is_inside (bufnum, mandalas)
				continue
			endif
			let winum += 1
			let filename = bufname(bufnum)
			let filename = fnamemodify(filename, ':p')
			let record = filename
			eval returnlist->add(record)
		endfor
	endfor
	return returnlist
endfun

" ---- search file

fun! wheel#perspective#find (pattern)
	" Find files in current directory using glob pattern
	let pattern = a:pattern
	return glob(pattern, v:false, v:true)
endfun

fun! wheel#perspective#locate (pattern)
	" Locate
	if ! has('unix')
		echomsg 'wheel perspective locate : this function is only supported on Unix systems'
		return v:false
	endif
	let pattern = a:pattern
	let database = g:wheel_config.locate_db
	if empty(database)
		let runme = 'locate ' .. pattern
	else
		let runme = 'locate -d ' .. expand(database) .. ' ' .. pattern
	endif
	let returnlist = systemlist(runme)
	return returnlist
endfun

" -- from attic

fun! wheel#perspective#mru ()
	" Sorted most recenty used files
	" Each entry is a string : date hour | filename
	let attic = deepcopy(g:wheel_attic)
	" should not be necessary
	"let Compare = function('wheel#pendulum#compare')
	"let attic = sort(attic, Compare)
	let returnlist = []
	for entry in attic
		let filename = entry.file
		let timestamp = entry.timestamp
		let date_hour = wheel#pendulum#date_hour (timestamp)
		let entry = date_hour .. s:field_separ
		let entry ..= filename
		let returnlist = add(returnlist, entry)
	endfor
	return returnlist
endfun

" ---- search inside file

fun! wheel#perspective#occur (pattern)
	" Occur
	let pattern = a:pattern
	let position = getcurpos()
	let runme = 'global /' .. pattern .. '/number'
	let returnlist = execute(runme)
	let returnlist = split(returnlist, "\n")
	for index in range(len(returnlist))
		let elem = returnlist[index]
		let fields = split(elem, ' ')
		let linum = fields[0]
		let content = join(fields[1:])
		let linum = printf('%5d', linum)
		let entry = [linum, content]
		let elem = join(entry, s:field_separ)
		let returnlist[index] = elem
	endfor
	call wheel#gear#restore_cursor(position)
	return returnlist
endfun

fun! wheel#perspective#marker ()
	" Markers
	let returnlist = []
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
		eval returnlist->add(record)
	endfor
	return returnlist
endfun

fun! wheel#perspective#jump ()
	" Jumps
	let returnlist = []
	let mandalas = g:wheel_mandalas.ring
	let jumplist = getjumplist()[0]
	for jump in jumplist
		let bufnum = jump.bufnr
		" valid number ?
		if bufnum <= 0
			"echomsg 'wheel perspective jumps : bufnum' bufnum 'on' jump
			continue
		endif
		let linum = jump.lnum
		let colnum = jump.col
		if has_key(jump, 'filename')
			let filename = jump.filename
		else
			let filename = bufname(bufnum)
		endif
		" check for nameless or mandalas buffers
		let is_nameless = empty(filename)
		let is_wheel_buffer = wheel#chain#is_inside(bufnum, mandalas)
		let has_wheel_filename = filename =~ s:is_mandala_file
		if is_nameless || is_wheel_buffer || has_wheel_filename
			continue
		endif
		" loaded ?
		if bufloaded(bufnum)
			let content = getbufline(bufnum, linum)[0]
		else
			let content = ' '
		endif
		" add to the returnlist
		let bufnum = printf('%3d', bufnum)
		let linum = printf('%5d', linum)
		let colnum = printf('%2d', colnum)
		let entry = [bufnum, linum, colnum, filename, content]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	" newest first
	call reverse(returnlist)
	return returnlist
endfun

fun! wheel#perspective#change ()
	" Changes
	let returnlist = []
	let changelist = getchangelist()[0]
	for change in changelist
		let linum = change.lnum
		let colnum = change.col
		let content = getline(linum)
		let linum = printf('%5d', linum)
		let colnum = printf('%2d', colnum)
		let entry = [linum, colnum, content]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	" newest first
	call reverse(returnlist)
	return returnlist
endfun

" -- from vector

fun! wheel#perspective#grep (pattern, sieve)
	" Quickfix list
	" Each line has the format :
	" error number | line | col | file | line content
	let bool = wheel#vector#grep (a:pattern, a:sieve)
	if ! bool
		" no file matching a:sieve
		return []
	endif
	let quickfix = getqflist()
	let list = []
	for index in range(len(quickfix))
		let elem = quickfix[index]
		" elem.nr does not work
		" let's take the index instead
		let errnum = printf('%4d', index + 1)
		let linum = printf('%5d', elem.lnum)
		let colnum = printf('%2d', elem.col)
		let filename = bufname(elem.bufnr)
		let content = elem.text
		let entry = [errnum, linum, colnum, filename, content]
		let record = join(entry, s:field_separ)
		eval list->add(record)
	endfor
	return list
endfun

" -- from symbol

fun! wheel#perspective#tag ()
	" Tags
	let table = wheel#symbol#table ()
	let returnlist = []
	for fields in table
		let iden = fields[0]
		let filename = fields[1]
		let search = fields[2]
		let type = fields[3]
		let iden = printf('%5s', iden)
		let type = printf('%2s', type)
		let entry = [type, iden, filename, search]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	return returnlist
endfun

" ---- yanks

fun! wheel#perspective#yank (mode)
	" Yank wheel
	let returnlist = []
	if a:mode == 'list'
		for elem in g:wheel_yank
			eval returnlist->add(string(elem))
		endfor
	elseif a:mode == 'plain'
		for elem in g:wheel_yank
			let plain = join(elem, "\n")
			" Only add if some text is there
			if plain =~ '\m\w'
				eval returnlist->add(plain)
			endif
		endfor
	endif
	return returnlist
endfun

" ---- undo list

fun! wheel#perspective#undolist ()
	" Undo list
	let undotree = undotree()
	let undolist = undotree.entries
	if empty(undolist)
		return v:false
	endif
	let returnlist = []
	for elem in undolist
		let iden = printf('%4d', elem.seq)
		let time = wheel#pendulum#date_hour(elem.time)
		if has_key(elem, 'save')
			let written = elem.save
		else
			let written = ''
		endif
		let entry = [iden, time, written]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	" more recent first
	call reverse(returnlist)
	return returnlist
endfun
