" vim: set ft=vim fdm=indent iskeyword&:

" Vector
"
" Batch
" Grep
" Quickfix

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- helpers

fun! wheel#vector#files (sieve)
	" Current circle files
	" Filter files with sieve
	let sieve = a:sieve
	if sieve !~ '^\\m'
		let sieve = '\m' .. sieve
	endif
	if wheel#referen#is_empty ('circle')
		return []
	endif
	" Locations files
	let locations = deepcopy(wheel#referen#circle().locations)
	let files = locations->map({ _, val -> fnameescape(val.file) })
	let directory = '\m^' .. getcwd() .. '/'
	eval files->map({ _, path -> substitute(path, directory, '', '') })
	" Filter with sieve
	eval files->filter({ _, val -> val =~ sieve })
	" Done
	return files
endfun

" ---- arg list

fun! wheel#vector#reset ()
	" Reset argument list
	if argc() == 0
		return v:true
	endif
	let confirm = confirm('Overwrite old argument list ?', "&Yes\n&No", 2)
	if confirm != 1
		return v:false
	endif
	% argdelete
	return v:true
endfun

fun! wheel#vector#argadd (sieve)
	" Add files of current circle to arguments
	" Filter files with sieve
	let yield = wheel#vector#reset ()
	if yield
		let files = wheel#vector#files (a:sieve)
		execute 'argadd' join(files)
	endif
	return yield
endfun

fun! wheel#vector#argdo (command, ...)
	" Execute command on each location of the circle
	" Filter files with optional argument
	if a:0 > 0
		let sieve = a:1
	else
		let sieve = '\m.'
	endif
	let command = a:command
	let yield = wheel#vector#argadd (sieve)
	if yield
		let runme = 'silent! argdo ' .. command
		let output = execute(runme)
		let output = split(output, '\n')
		let type = 'batch/' .. split(command)[0]
		call wheel#mandala#blank(type)
		call wheel#mandala#common_maps ()
		call wheel#mandala#fill (output)
		setlocal nofoldenable
	endif
endfun

fun! wheel#vector#batch (...)
	" Interactive wrapper for wheel#vector#argdo
	if a:0 > 0
		let command = a:1
	else
		let command = input('Batch :ex or !shell command : ')
	endif
	call wheel#vector#argdo(command)
endfun

" ---- grep

fun! wheel#vector#grep (pattern, ...)
	" Grep in all files of circle
	" Filter files with optional argument
	if a:0 > 0
		let sieve = a:1
	else
		let sieve = '\m.'
	endif
	let pattern = a:pattern
	let pattern = escape(pattern, '#')
	let files = wheel#vector#files (sieve)
	if empty(files)
		echomsg 'wheel vector grep : no file matching filter'
		return v:false
	endif
	" File list as string
	let files = join(files)
	" Quote if needed
	if pattern !~ "'"
		let pattern = "'" .. pattern .. "'"
	elseif pattern !~ '"'
		let pattern = '"' .. pattern .. '"'
	endif
	" Run grep
	let grep = g:wheel_config.grep
	if ! wheel#chain#is_inside(grep, ['grep', 'vimgrep'])
		echoerr 'wheel vector grep : bad g:wheel_config.grep value'
		return v:false
	endif
	let grep ..= '!'
	" do not jump to first pattern
	if grep ==# 'vimgrep'
		let pattern ..= 'j'
	endif
	execute 'silent!' grep pattern files
	return v:true
endfun

fun! wheel#vector#copen ()
	" Open quickfix with a golden ratio
	let height = float2nr(wheel#spiral#height ())
	execute 'copen' height
endfun

" ---- propagate changes in quickfix

fun! wheel#vector#cdo (newlines)
	" Apply change of current line in grep edit mode
	let newlines = a:newlines
	if ! empty(newlines)
		let line = remove(newlines, 0)
		call setline('.', line)
	else
		echomsg 'wheel cdo : quickfix list is prematurely empty'
	endif
endfun
