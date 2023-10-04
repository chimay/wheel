" vim: set ft=vim fdm=indent iskeyword&:

" Vortex
"
" Wheel navigation, straightforward and prompt functions

" ---- script constants

if exists('s:referen_coordin')
	unlockvar s:referen_coordin
endif
let s:referen_coordin = ['torus', 'circle', 'location']
lockvar s:referen_coordin

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = wheel#crystal#fetch('separator/level')
lockvar s:level_separ

" ---- sync up & down

fun! wheel#vortex#here ()
	" Location of cursor
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col = col('.')
	return location
endfun

fun! wheel#vortex#update (verbose = 'quiet')
	" Update current location line & col to cursor
	" Optional argument :
	"   - quiet (default)
	"   - verbose
	let verbose = a:verbose
	let location = wheel#referen#location()
	if empty(location) || location.file !=# expand('%:p')
		return v:false
	endif
	let cur_line = line('.')
	let cur_col = col('.')
	if location.line == cur_line && location.col == cur_col
		return v:false
	endif
	let location.line = cur_line
	let location.col = cur_col
	call wheel#chakra#update_locations ()
	if verbose ==# 'verbose'
		echo 'wheel : location updated'
	endif
	return v:true
endfun

" -- jump

fun! wheel#vortex#target (target)
	" Open target tab / win if needed before navigation
	let target = a:target
	if target ==# 'here'
		return win_getid ()
	endif
	if target ==# 'search-window'
		return wheel#rectangle#tour ()
	endif
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
	return win_getid ()
endfun

fun! wheel#vortex#jump (where = 'search-window')
	" Jump to current location
	" Perform user post-jump autocmd
	" Optional argument :
	"   - search-window (default) : search for active buffer
	"                               in tabs & windows
	"   - here : load the buffer in current window,
	"            do not search in tabs & windows
	"   - tab : jump in new tab
	"   - horizontal_split : jump in new horizontal split
	"   - vertical_split : jump in new horizontal split
	"   - horizontal_golden : jump in new horizontal golden split
	"   - vertical_golden : jump in new horizontal golden split
	let where = a:where
	" ---- check location
	let location = wheel#referen#location ()
	if empty(location)
		return win_getid ()
	endif
	" ---- target
	let window = wheel#vortex#target (where)
	" ---- jump
	if where ==# 'search-window' && window >= 0
		" -- switch to window containing location buffer
		call win_gotoid(window)
		call cursor(location.line, location.col)
	elseif bufloaded(location.file)
		" -- load buffer in current window
		let buffer = bufname(location.file)
		execute 'noautocmd silent hide buffer' buffer
		call cursor(location.line, location.col)
		doautocmd BufEnter
	else
		" -- edit location file
		let filename = location.file
		if ! filereadable (filename)
			let prompt = 'File not found. Delete broken location ?'
			let confirm = confirm(prompt, "&Yes\n&No", 1)
			if confirm == 1
				call wheel#tree#delete('location', 'force')
			endif
			return v:false
		endif
		execute 'noautocmd silent hide edit' filename
		call cursor(location.line, location.col)
		doautocmd BufRead
		doautocmd BufEnter
	endif
	" ---- auto change dir to project root
	if g:wheel_config.project.auto_chdir > 0
		let markers = g:wheel_config.project.markers
		call wheel#disc#project_root(markers)
	endif
	" ---- record in history
	call wheel#pendulum#record ()
	" ---- view in fold
	call wheel#origami#view_cursor ()
	" ---- user autocmd
	silent doautocmd User WheelAfterJump
	" ---- cursor
	call wheel#spiral#cursor ()
	" ---- update signs
	call wheel#chakra#update_locations ()
	" ---- dashboard
	call wheel#status#dashboard ()
	" ---- coda
	return win_getid ()
endfun

" ---- tune

fun! wheel#vortex#tune (level, name)
	" Adjust variables of level to name ; internal use
	let level = a:level
	let name = a:name
	let upper = wheel#referen#upper(level)
	let glossary = upper.glossary
	" ---- check
	if empty(upper) || empty(glossary)
		echomsg 'wheel vortex tune : empty or incomplete' level
		return -1
	endif
	" ---- tune
	let index = glossary->index(name)
	if index < 0
		echomsg 'wheel vortex tune :' name 'not found'
		return -1
	endif
	let upper.current = index
	return index
endfun

fun! wheel#vortex#voice (level, name)
	" Adjust variables of level to name & perform user update autocmd
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	return wheel#vortex#tune (a:level, a:name)
endfun

fun! wheel#vortex#interval (coordin)
	" Adjust wheel to circle coordin = [torus, circle]
	let coordin = a:coordin
	let indexes = [-1, -1]
	" ---- check
	if len(coordin) != 2
		echomsg 'wheel vortex interval : [' join(coordin) '] should contain 2 elements'
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	let indexes[0] = wheel#vortex#tune ('torus', coordin[0])
	if indexes[0] >= 0
		let indexes[1] = wheel#vortex#tune ('circle', coordin[1])
	endif
	return indexes
endfun

fun! wheel#vortex#chord (coordin)
	" Adjust wheel to location coordin = [torus, circle, location]
	let coordin = a:coordin
	" ---- check
	let indexes = [-1, -1, -1]
	if len(coordin) != 3
		echomsg 'wheel vortex chord : [' join(coordin) '] should contain 3 elements'
		return indexes
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	let indexes[0] = wheel#vortex#tune ('torus', coordin[0])
	if indexes[0] >= 0
		let indexes[1] = wheel#vortex#tune ('circle', coordin[1])
	endif
	if indexes[1] >= 0
		let indexes[2] = wheel#vortex#tune ('location', coordin[2])
	endif
	return indexes
endfun

" ---- next / previous

fun! wheel#vortex#previous (level, where = 'search-window')
	" Previous element in level
	" Optional argument : see vortex#jump
	let level = a:level
	let where = a:where
	let upper = wheel#referen#upper(level)
	" ---- check
	if empty(upper) || empty(upper.glossary)
		return -1
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	let index = upper.current
	let elements = wheel#referen#elements(upper)
	let length = len(elements)
	let upper.current = wheel#taijitu#circular_minus(index, length)
	return wheel#vortex#jump(where)
endfun

fun! wheel#vortex#next (level, where = 'search-window')
	" Next element in level
	" Optional argument : see vortex#jump
	let level = a:level
	let where = a:where
	let upper = wheel#referen#upper(level)
	" ---- check
	if empty(upper) || empty(upper.glossary)
		return -1
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	let index = upper.current
	let elements = wheel#referen#elements(upper)
	let length = len(elements)
	let upper.current = wheel#taijitu#circular_plus(index, length)
	return wheel#vortex#jump(where)
endfun

" ---- switch : tune and jump

fun! wheel#vortex#switch (level, where = 'search-window')
	" Switch to element with completion
	" Optional argument 0 : name of element
	" Optional argument 1 : see vortex#jump optional argument
	let level = a:level
	let where = a:where
	let prompt = 'Switch to ' .. level .. ' : '
	let complete = 'customlist,wheel#complete#' .. level
	let name = input(prompt, '', complete)
	if empty(name)
		return -1
	endif
	let index = wheel#vortex#voice (level, name)
	if index < 0
		return index
	endif
	call wheel#vortex#jump (where)
	return index
endfun

fun! wheel#vortex#multi_switch (where = 'search-window')
	" Switch torus, circle & location
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- tune
	let indexes = [-1, -1, -1]
	for level in s:referen_coordin
		let prompt = 'Switch to ' .. level .. ' : '
		let complete = 'customlist,wheel#complete#' .. level
		let name = input(prompt, '', complete)
		if empty(name)
			return indexes
		endif
		let level_index = wheel#referen#level_index_in_coordin(level)
		let found = wheel#vortex#tune (level, name)
		if found >= 0
			let indexes[level_index] = found
		else
			echomsg 'wheel vortex multi switch : name' name 'not found'
			return indexes
		endif
	endfor
	call wheel#vortex#jump (where)
	return indexes
endfun

fun! wheel#vortex#helix (where = 'search-window')
	" Switch to coordinates in helix index
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	let prompt = 'Switch to location in index : '
	let complete = 'customlist,wheel#complete#helix'
	let record = input(prompt, '', complete)
	if empty(record)
		return [-1, -1, -1]
	endif
	let coordin = split(record, s:level_separ)
	let indexes = wheel#vortex#chord (coordin)
	call wheel#vortex#jump (where)
	return indexes
endfun

fun! wheel#vortex#grid (where = 'search-window')
	" Switch to coordinates in grid index
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	let prompt = 'Switch to circle in index : '
	let complete = 'customlist,wheel#complete#grid'
	let record = input(prompt, '', complete)
	if empty(record)
		return [-1, -1]
	endif
	let coordin = split(record, s:level_separ)
	let indexes = wheel#vortex#interval (coordin)
	call wheel#vortex#jump (where)
	return indexes
endfun
