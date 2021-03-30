" vim: ft=vim fdm=indent:

" Batch

" Helpers

fun! wheel#vector#files (sieve)
	" Current circle files
	" Filter files with sieve
	let sieve = a:sieve
	if sieve !~ '^\\m'
		let sieve = '\m' . sieve
	endif
	" Locations files
	let locations = deepcopy(wheel#referen#circle().locations)
	let files = map(locations, {_, val -> fnameescape(val.file)})
	" Remove current directory part
	let directory = '\n^' . getcwd() . '/'
	for index in range(len(files))
		let path = files[index]
		let files[index] = substitute(path, directory, '', '')
	endfor
	" Filter with sieve
	call filter(files, {_, val -> val =~ sieve})
	" Done
	return files
endfu

" Arg list

fun! wheel#vector#reset ()
	" Reset argument list
	if argc() > 0
		let confirm = confirm('Overwrite old argument list ?', "&Yes\n&No", 2)
		if confirm != 1
			return v:false
		endif
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
		exe 'argadd ' join(files)
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
		let runme = 'silent! argdo ' . command
		let output = execute(runme)
		call wheel#mandala#open('argdo')
		call wheel#mandala#common_maps ()
		setlocal nofoldenable
		put =output
	endif
endfun

fun! wheel#vector#batch ()
	if a:0 > 0
		let command = a:1
	else
		let command = input('Batch :ex or !shell command : ')
	endif
	call wheel#vector#argdo(command)
endfun

" Grep

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
		echomsg 'Wheel vector grep : no file matching filter'
		return v:false
	endif
	" File list as string
	let files = join(files)
	" Quote if needed
	if pattern !~ "'"
		let pattern = "'" . pattern . "'"
	elseif pattern !~ '"'
		let pattern = '"' . pattern . '"'
	endif
	" Run grep
	let runme = 'silent grep! '
	let runme .= pattern
	let runme .= ' ' . files
	exe runme
	return v:true
endfun

fun! wheel#vector#copen ()
	" Open quickfix with a golden ratio
	let height = float2nr(wheel#spiral#height ())
	exe 'copen ' . height
endfun
