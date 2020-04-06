" vim: ft=vim fdm=indent:

" Batch

fun! wheel#vector#reset ()
	" Reset argument list
	if argc() > 0
		let confirm = confirm('Overwrite old argument list ?', "&Yes\n&No", 2)
		if confirm != 1
			return
		endif
	endif
	% argdelete
endfun

fun! wheel#vector#locations ()
	" Add all locations of current circle to arguments
	call wheel#vector#reset ()
	let locations = deepcopy(wheel#referen#circle().locations)
	let files = map(locations, {_,val -> fnameescape(val.file)})
	exe 'argadd ' join(files)
endfun

fun! wheel#vector#argdo (command)
	" Execute command on each location of the circle
	call wheel#vector#locations ()
	redir => output
	exe 'argdo ' a:command
	redir END
	call wheel#mandala#open('wheel-argdo')
	call wheel#mandala#common_maps ()
	put =output
endfun
