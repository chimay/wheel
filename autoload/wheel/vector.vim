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
	let ret = wheel#vector#reset ()
	if ret
		let files = wheel#vector#files (a:sieve)
		exe 'argadd ' join(files)
	endif
	return ret
endfun

fun! wheel#vector#argdo (command, ...)
	" Execute command on each location of the circle
	" Filter files with optional argument
	if a:0 > 0
		let sieve = a:1
	else
		let sieve = '\m.'
	endif
	let ret = wheel#vector#argadd (sieve)
	if ret
		let runme = 'silent! argdo ' . a:command
		let output = execute(runme)
		call wheel#mandala#open('wheel-argdo')
		call wheel#mandala#common_maps ()
		setlocal nofoldenable
		put =output
	endif
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
	" Run grep
	let runme = 'silent grep! '
	let runme .= "'"
	let runme .= pattern
	let runme .= "'"
	let runme .= ' ' . files
	exe runme
	return v:true
endfun

fun! wheel#vector#quickfix ()
	" Quickfix list to be displayed
	" Each line has the format :
	" buffer-number | file | line | col | text
	let quickfix = getqflist()
	let list = []
	for elem in quickfix
		let bufnr = elem.bufnr
		let record = bufnr . ' | '
		let record .= bufname(bufnr) . ' | '
		let record .= elem.lnum . ' | '
		let record .= elem.col . ' | '
		let record .= elem.text
		call add(list, record)
	endfor
	return list
endfun

fun! wheel#vector#copen ()
	" Open quickfix with a golden ratio
	let height = float2nr(wheel#spiral#height ())
	exe 'copen ' . height
endfun
