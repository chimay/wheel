" vim: set filetype=vim:

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
	exec 'redir! > ' . a:file
		silent! echo content
	redir END
	echomsg 'Variable' a:pointer 'wrote to ' a:file
endfun

fun! wheel#disc#read (file)
	" Read file
	exe 'source ' . a:file
	echomsg 'File' a:file 'sourced'
endfun

fun! wheel#disc#roll_backups (file, backups)
	" Roll backups of g:wheel_config.file
	let suffixes = range(a:backups, 1, -1)
	let filelist = map(suffixes, {ind, val -> a:file . '.' . val})
	let filelist = add(filelist, a:file)
	let command = 'cp -f '
	while len(filelist) > 1
		let second = remove(filelist, 0)
		let first = filelist[0]
		let copy = command . first . ' ' . second
		if filereadable(expand(first))
			echomsg copy
			call system(copy)
		endif
	endwhile
endfun

fun! wheel#disc#write_all ()
	if exists('g:wheel_config')
		if ! has_key(g:wheel_config, 'backups')
			let g:wheel_config.backups = 3
			echomsg 'Using default of' g:wheel_config.backups 'backups'
		endif
		call wheel#disc#roll_backups(g:wheel_config.file, g:wheel_config.backups)
		if has_key(g:wheel_config, 'file')
			call wheel#disc#write('g:wheel', g:wheel_config.file)
		else
			echomsg 'Please configure g:wheel_config.file = my_wheel_file'
		endif
	else
		echomsg 'Please initialize g:wheel_config = {}'
	endif
endfun

fun! wheel#disc#read_all ()
	call wheel#disc#read(g:wheel_config.file)
endfun
