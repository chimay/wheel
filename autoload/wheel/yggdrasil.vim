" vim: set ft=vim fdm=indent iskeyword&:

" Organize the wheel, dedicated buffers

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

" write commands

fun! wheel#yggdrasil#write (fun_name, ...)
	" Define BufWriteCmd autocommand & set writable property
	" -- arguments
	let fun_name = a:fun_name
	if a:0 > 0
		let optional = string(a:1)
	else
		let optional = ''
	endif
	" -- property
	let b:wheel_nature.is_writable = v:true
	" -- options
	setlocal buftype=acwrite
	" -- autocommand
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

" reorder

fun! wheel#yggdrasil#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorder : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorder/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#yggdrasil#write ('reorder', level)
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
	" reload
	let b:wheel_reload = "wheel#yggdrasil#reorder('" .. level .. "')"
	" additional maps
	nnoremap <m-s> <cmd>2,$sort<cr>
endfun

" rename

fun! wheel#yggdrasil#rename (level)
	" Rename level elements in a buffer
	let level = a:level
	let lines = wheel#perspective#switch (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape rename : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('rename/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#yggdrasil#write ('rename', level)
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
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
	call wheel#polyphony#template ()
	call wheel#yggdrasil#write ('rename_files')
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
	" reload
	let b:wheel_reload = 'wheel#yggdrasil#rename_files()'
	return v:true
endfun

" copy / move

fun! wheel#yggdrasil#copy_move (level)
	" Copy or move elements at level
	let level = a:level
	let lines = wheel#perspective#switch (level)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape copy / move : empty or incomplete' level
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('copy_move/' .. level)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#pencil#mappings ()
	call wheel#yggdrasil#write ('copy_move', level)
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
	" reload
	let b:wheel_reload = "wheel#yggdrasil#copy_move('" .. level .. "')"
endfun

" reorganize

fun! wheel#yggdrasil#reorganize ()
	" Reorganize the wheel tree
	let lines = wheel#perspective#reorganize ()
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel shape reorganize : empty wheel'
		return v:false
	endif
	" -- mandala
	call wheel#mandala#blank ('reorganize')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#template ()
	call wheel#mandala#folding_options ()
	call wheel#yggdrasil#write ('reorganize')
	call wheel#mandala#fill(lines, 'prompt-first')
	setlocal nomodified
	setlocal nocursorline
	" reload
	let b:wheel_reload = 'wheel#yggdrasil#reorganize'
endfun
