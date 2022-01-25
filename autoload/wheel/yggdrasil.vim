" vim: set ft=vim fdm=indent iskeyword&:

" Organize the wheel, dedicated buffers

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

" write commands

fun! wheel#yggdrasil#write (fun_name, ...)
	" Define BufWriteCmd autocommand
	" -- arguments
	let fun_name = a:fun_name
	if a:0 > 0
		let optional = string(a:1)
	else
		let optional = ''
	endif
	" -- mandala
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

" rename

fun! wheel#yggdrasil#rename (level)
	" Rename level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	if empty(lines)
		echomsg 'wheel shape rename : empty or incomplete' level
		return v:false
	endif
	call wheel#mandala#blank ('rename/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('rename', level)
	if ! empty(lines)
		call wheel#mandala#fill(lines, 'delete-first')
		silent global /^$/ delete
		setlocal nomodified
	else
		echomsg 'wheel shape rename : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#yggdrasil#rename('" .. level .. "')"
endfun

fun! wheel#yggdrasil#rename_files ()
	" Rename locations & files of current circle, after buffer content
	" -- lines
	let lines = wheel#perspective#rename_files ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape rename_files : empty or incomplete circle'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('rename/locations_files')
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('rename_files')
	call wheel#mandala#fill(lines, 'delete-first')
	silent global /^$/ delete
	setlocal nomodified
	" reload
	let b:wheel_reload = 'wheel#yggdrasil#rename_files()'
	return v:true
endfun

" reorder

fun! wheel#yggdrasil#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	if empty(lines)
		echomsg 'wheel shape reorder : empty or incomplete' level
		return v:false
	endif
	call wheel#mandala#blank ('reorder/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('reorder', level)
	call wheel#mandala#fill(lines, 'delete-first')
	silent global /^$/ delete
	setlocal nomodified
	" reload
	let b:wheel_reload = "wheel#yggdrasil#reorder('" .. level .. "')"
endfun

" copy / move

fun! wheel#yggdrasil#copy_move (level)
	" Copy or move elements at level
	let level = a:level
	let lines = wheel#perspective#switch (level)
	if empty(lines)
		echomsg 'wheel shape copy / move : empty or incomplete' level
		return v:false
	endif
	call wheel#mandala#blank ('copy_move/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('copy_move', level)
	if ! empty(lines)
		call wheel#mandala#fill(lines, 'delete-first')
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
	let b:wheel_reload = "wheel#yggdrasil#copy_move('" .. level .. "')"
endfun

" reorganize

fun! wheel#yggdrasil#reorganize ()
	" Reorganize the wheel tree
	let lines = wheel#perspective#reorganize ()
	if empty(lines)
		echomsg 'wheel shape reorganize : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('reorganize')
	call wheel#mandala#common_maps ()
	call wheel#yggdrasil#write ('reorganize')
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines, 'delete-first')
	silent global /^$/ delete
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#yggdrasil#reorganize'
endfun
