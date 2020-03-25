" vim: ft=vim fdm=indent:

" Storage

fun! wheel#disc#write (pointer, file)
	" Write variable referenced by string pointer to file
	" in a format that can be :sourced
	let var =  {a:pointer}
	redir => content
		silent! echo 'let' a:pointer '=' var
	redir END
	let content = substitute(content, '[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\n\{2,\}', '\n', 'g')
	exec 'redir! > ' . expand(a:file)
		silent! echo content
	redir END
	echomsg 'Variable' a:pointer 'wrote to ' a:file
endfun

fun! wheel#disc#read (file)
	" Read file
	exe 'source ' . a:file
endfun

fun! wheel#disc#roll_backups (file, backups)
	" Roll backups of g:wheel_config.file
	let suffixes = range(a:backups, 1, -1)
	let filelist = map(suffixes, {ind, val -> a:file . '.' . val})
	let filelist = add(filelist, a:file)
	let command = 'cp -f '
	while len(filelist) > 1
		let second = expand(remove(filelist, 0))
		let first = expand(filelist[0])
		let copy = command . first . ' ' . second
		if filereadable(first)
			"echomsg copy
			call system(copy)
		endif
	endwhile
endfun

fun! wheel#disc#write_all ()
	if ! exists('g:wheel_config')
		let g:wheel_config = {}
	endif
	if ! has_key(g:wheel_config, 'autowrite')
		let g:wheel_config.autowrite = 0
	endif
	if g:wheel_config.autowrite == 0
		return
	endif
	if ! has_key(g:wheel_config, 'backups')
		let g:wheel_config.backups = 3
		echomsg 'Using default of' g:wheel_config.backups 'backups'
	endif
	if has_key(g:wheel_config, 'file')
		call wheel#disc#roll_backups(g:wheel_config.file, g:wheel_config.backups)
		call wheel#disc#write('g:wheel', g:wheel_config.file)
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun

fun! wheel#disc#read_all ()
	if ! exists('g:wheel_config')
		let g:wheel_config = {}
	endif
	if ! has_key(g:wheel_config, 'autoread')
		let g:wheel_config.autoread = 0
	endif
	if g:wheel_config.autoread == 0
		return
	endif
	if has_key(g:wheel_config, 'file')
		call wheel#disc#read(g:wheel_config.file)
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun
