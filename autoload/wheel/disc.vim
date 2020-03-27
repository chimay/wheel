" vim: ft=vim fdm=indent:

" Storage

fun! wheel#disc#write (pointer, file, ...)
	" Write variable referenced by string pointer to file
	" in a format that can be :sourced
	" If optional argument 1 is :
	" '>' : replace file content (default)
	" '>>' : add to file content
	let mode = '>'
	if a:0 > 0
		let mode = a:1
	endif
	let var =  {a:pointer}
	redir => content
		silent! echo 'let' a:pointer '=' var
	redir END
	let content = substitute(content, '[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\n\{2,\}', '\n', 'g')
	exec 'redir! ' . mode . ' ' . expand(a:file)
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
	" Write all wheel variables to g:wheel_config.file
	if has_key(g:wheel_config, 'file')
		call wheel#disc#roll_backups(g:wheel_config.file, g:wheel_config.backups)
		call wheel#disc#write('g:wheel', g:wheel_config.file, '>')
		call wheel#disc#write('g:wheel_helix', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_grid', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_files', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_history', g:wheel_config.file, '>>')
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun

fun! wheel#disc#read_all ()
	" Read all wheel variables from g:wheel_config.file
	if has_key(g:wheel_config, 'file')
		call wheel#disc#read(g:wheel_config.file)
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun
