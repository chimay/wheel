" vim: set ft=vim fdm=indent iskeyword&:

" Reshaping buffers

" Script constants

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:is_mandala')
	let s:is_mandala = wheel#crystal#fetch('is_mandala')
	lockvar s:is_mandala
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Write commands

fun! wheel#shape#write (fun_name, ...)
	" Define BufWriteCmd autocommand
	if a:0 > 0
		let optional = string(a:1)
	else
		let optional = ''
	endif
	let fun_name = a:fun_name
	setlocal buftype=acwrite
	let group = s:mandala_autocmds_group
	let event = 'BufWriteCmd'
	call wheel#gear#clear_autocmds(group, event)
	if fun_name =~ '#'
		" fun_name is the complete function name
		let function = 'call ' .. fun_name .. '(' .. optional .. ')'
	else
		" fun_name is the last part of the function
		let function = 'call wheel#cuboctahedron#'
		let function ..= fun_name .. '(' .. optional .. ')'
	endif
	exe 'autocmd' group event '<buffer>' function
endfun

" Reorder

fun! wheel#shape#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	call wheel#mandala#open ('reorder/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('reorder', level)
	if ! empty(lines)
		call wheel#mandala#fill(lines, 'delete')
		silent global /^$/ delete
		setlocal nomodified
	else
		echomsg 'wheel shape reorder : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#shape#reorder('" .. level .. "')"
endfun

" Rename

fun! wheel#shape#rename (level)
	" Rename level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	call wheel#mandala#open ('rename/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('rename', level)
	if ! empty(lines)
		call wheel#mandala#fill(lines, 'delete')
		silent global /^$/ delete
		setlocal nomodified
	else
		echomsg 'wheel shape rename : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#shape#rename('" .. level .. "')"
endfun

fun! wheel#shape#rename_files ()
	" Rename locations & files of current circle, after buffer content
	let glossary = wheel#perspective#switch ('location')
	if empty(glossary)
		echomsg 'wheel shape rename_files : empty or incomplete circle'
		return v:false
	endif
	let locations = deepcopy(wheel#referen#circle().locations)
	let filenames = map(locations, {_,v -> v.file})
	let lines = []
	let len_circle = len(locations)
	if len_circle != len(filenames)
		echomsg 'shape rename_files : inconsistent circle lengths'
		return v:false
	endif
	for index in range(len_circle)
		let entry = [glossary[index], filenames[index]]
		let record = join(entry, s:field_separ)
		call add(lines, record)
	endfor
	call wheel#mandala#open ('rename/locations_files')
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('rename_files')
	call wheel#mandala#fill(lines, 'delete')
	silent global /^$/ delete
	setlocal nomodified
	" reload
	let b:wheel_reload = 'wheel#shape#rename_files()'
	return v:true
endfun

" Batch copy/move

fun! wheel#shape#copy_move (level)
	" Copy or move elements at level
	let level = a:level
	let lines = wheel#perspective#switch (level)
	call wheel#mandala#open ('copy_move/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('copy_move', level)
	if ! empty(lines)
		call wheel#mandala#fill(lines, 'delete')
		silent global /^$/ delete
		setlocal nomodified
	else
		echomsg 'wheel shape copy/move : empty or incomplete' level
	endif
	" define local selection maps
	nnoremap <buffer> <space> <cmd>call wheel#pencil#toggle()<cr>
	nnoremap <buffer> & <cmd>call wheel#pencil#toggle_visible()<cr>
	nnoremap <buffer> * <cmd>call wheel#pencil#select_visible()<cr>
	nnoremap <buffer> <bar> <cmd>call wheel#pencil#clear_visible()<cr>
	" reload
	let b:wheel_reload = "wheel#shape#copy_move('" .. level .. "')"
endfun

" Reorganize

fun! wheel#shape#reorganize ()
	" Reorganize the wheel tree
	let lines = wheel#perspective#reorganize ()
	call wheel#mandala#open ('reorganize')
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('reorganize')
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines, 'delete')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#shape#reorganize'
endfun

" Reorganize tabs

fun! wheel#shape#reorg_tabwins ()
	" Reorganize tabs & windows
	let lines = wheel#perspective#tabwins_tree ()
	call wheel#mandala#open ('reorg/tabwins')
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('reorg_tabwins')
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill(lines, 'delete')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#shape#reorg_tabwins'
endfun

" Grep

fun! wheel#shape#grep_edit (...)
	" Reorder level elements in a buffer
	if a:0 > 0
		let pattern = a:1
	else
		let file = expand('%')
		if file =~ s:is_mandala .. 'context/grep'
			" called from context menu
			" original pattern is in the previous leaf of the ring
			let settings = wheel#book#previous ('settings')
			" old layer stack implementation
			"let settings = wheel#layer#top_field ('settings')
			let pattern = settings.pattern
		else
			let pattern = input('Grep circle files for pattern [edit mode] : ')
		endif
	endif
	if a:0 > 1
		let sieve = a:2
	else
		if file =~ s:is_mandala .. 'context/grep'
			let settings = wheel#book#previous ('settings')
			" old layer stack implementation
			"let settings = wheel#layer#top_field ('settings')
			let sieve = settings.sieve
		else
			let sieve = '\m.'
		endif
	endif
	let lines = wheel#perspective#grep (pattern, sieve)
	if type(lines) == v:t_list
		if empty(lines)
			echomsg 'wheel sailing grep : no match found.'
			return v:false
		endif
	elseif type(lines) == type(v:true)
		if ! lines
			echomsg 'wheel sailing grep : lines parameter is false.'
			return v:false
		endif
	endif
	call wheel#mandala#open ('grep/edit')
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('wheel#vector#write_quickfix')
	call wheel#mandala#fill (lines, 'delete')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" copy of original lines
	let b:wheel_lines = copy(lines)
	" reload
	let b:wheel_reload = "wheel#shape#grep_edit('" .. pattern .. "','" .. sieve .. "')"
	" info
	echomsg 'adding or removing lines is not supported.'
	return lines
endfun

" Narrow, filter & operate on multi-lines

fun! wheel#shape#narrow (first = -1, last = -1) range
	" Lines matching pattern
	call wheel#mandala#close ()
	let first = a:first
	let last = a:last
	" To be run before opening the mandala buffer
	if first < 0
		let first = a:firstline
		let last = a:lastline
		if first == last
			" assume the user does not launch it just for one line
			let first = 1
			let last = line('$')
		endif
	endif
	let lines = wheel#perspective#narrow (first, last)
	call wheel#mandala#open ('narrow')
	call wheel#polyphony#filter_maps ()
	call wheel#mandala#common_maps ()
	call wheel#shape#write ('wheel#polyphony#harmony')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#shape#narrow(' .. first .. ', ' .. last .. ')'
	echomsg 'adding or removing lines is not supported.'
endfun
