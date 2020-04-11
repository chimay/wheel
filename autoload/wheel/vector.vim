" vim: ft=vim fdm=indent:

" Batch

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

fun! wheel#vector#grep ()
	" Grep in all files of circle
	" TODO
endfun
