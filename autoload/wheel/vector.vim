" vim: ft=vim fdm=indent:

" Batch

" Arg list

fun! wheel#vector#reset ()
	" Reset argument list
	if argc() > 0
		let confirm = confirm('Overwrite old argument list ?', "&Yes\n&No", 2)
		if confirm != 1
			return 0
		endif
	endif
	% argdelete
	return 1
endfun

fun! wheel#vector#locations ()
	" Add all locations of current circle to arguments
	let ret = wheel#vector#reset ()
	let locations = deepcopy(wheel#referen#circle().locations)
	let files = map(locations, {_,val -> fnameescape(val.file)})
	exe 'argadd ' join(files)
	return ret
endfun

fun! wheel#vector#argdo (command)
	" Execute command on each location of the circle
	let ret = wheel#vector#locations ()
	if ret
		redir => output
		exe 'silent argdo ' a:command
		redir END
		call wheel#mandala#open('wheel-argdo')
		call wheel#mandala#common_maps ()
		put =output
	endif
endfun

" Grep

fun! wheel#vector#grep (...)
	" Grep in all files of circle
	" Display result in quickfix window
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Pattern ? ')
	endif
	let locations = deepcopy(wheel#referen#circle().locations)
	let files = map(locations, {_,value -> value.file})
	" Remove current directory part
	let directory = getcwd() . '/'
	for index in range(len(files))
		let path = files[index]
		let files[index] = substitute(path, directory, '', '')
	endfor
	" File list as string
	let files = join(files)
	" Run grep
	let runme = 'silent grep! '
	let runme .= "'"
	let runme .= pattern
	let runme .= "'"
	let runme .= ' ' . files
	exe runme
endfun

fun! wheel#vector#quickfix ()
	" Quickfix list to be displayed
	let quickfix = getqflist()
	let list = []
	for elem in quickfix
		let record = bufname(elem.bufnr) . ' | '
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
