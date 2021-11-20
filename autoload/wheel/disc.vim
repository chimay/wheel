" vim: ft=vim fdm=indent:

" Storage
" Note : use expand to expand '~' in filenames

fun! wheel#disc#write (pointer, file, ...)
	" Write variable referenced by pointer to file
	" in a format that can be :sourced
	" If optional argument 1 is :
	" '>' : replace file content (default)
	" '>>' : add to file content
	if ! exists(a:pointer)
		return
	endif
	let file = expand(a:file)
	if a:0 > 0
		let mode = a:1
	else
		let mode = '>'
	endif
	let var =  {a:pointer}
	redir => content
	silent! echo 'let' a:pointer '=' var
	redir END
	let content = substitute(content, '\m[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\m\n\{2,\}', '\n', 'g')
	exec 'redir!' mode file
	silent! echo content
	redir END
endfun

fun! wheel#disc#writefile (varname, file, ...)
	" Write variable referenced by varname to file
	" in a format that can be :sourced
	" If optional argument 1 is :
	" '>' : replace file content (default)
	" '>>' : add to file content
	" Similar to wheel#disc#write but with writefile()
	if ! exists(a:varname)
		return
	endif
	let file = expand(a:file)
	if a:0 > 0
		let mode = a:1
	else
		let mode = '>'
	endif
	let string = 'let ' . a:varname . ' = ' . string({a:varname})
	let string = substitute(string, '\m[=,]', '\0\\', 'g')
	let list = split(string, '\m[=,]\zs')
	if mode == '>>'
		call writefile(list, file, 'a')
	else
		call writefile(list, file)
	endif
endfun

fun! wheel#disc#read (file)
	" Read file
	let file = expand(a:file)
	if filereadable(file)
		exe 'source' file
	else
		echomsg 'Could not read' file
	endif
endfun

fun! wheel#disc#roll_backups (file, backups)
	" Roll backups of file
	let file = expand(a:file)
	let suffixes = range(a:backups, 1, -1)
	let filelist = map(suffixes, {ind, val -> file . '.' . val})
	let filelist = add(filelist, file)
	let command = 'cp -f '
	while len(filelist) > 1
		let second = expand(remove(filelist, 0))
		let first = expand(filelist[0])
		let copy = command . shellescape(first) . ' ' . shellescape(second)
		if filereadable(first)
			"echomsg copy
			call system(copy)
		endif
	endwhile
endfun

fun! wheel#disc#write_all ()
	" Write all wheel variables to g:wheel_config.file
	if wheel#referen#empty ('wheel')
		echomsg 'Not writing empty wheel'
		return
	endif
	call wheel#vortex#update ()
	if has_key(g:wheel_config, 'file')
		if argc() == 0 && has('nvim')
			echomsg 'Writing wheel variables to file ...'
		endif
		call wheel#disc#roll_backups(g:wheel_config.file, g:wheel_config.backups)
		call wheel#disc#write('g:wheel', g:wheel_config.file, '>')
		call wheel#disc#write('g:wheel_helix', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_grid', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_files', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_history', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_input', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_attic', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_wave', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_ripple', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_yank', g:wheel_config.file, '>>')
		call wheel#disc#write('g:wheel_shelve', g:wheel_config.file, '>>')
		if argc() == 0 && has('nvim')
			echomsg 'Writing done !'
		endif
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun

fun! wheel#disc#read_all ()
	" Read all wheel variables from g:wheel_config.file
	if has_key(g:wheel_config, 'file')
		if argc() == 0 && has('nvim')
			echomsg 'Reading wheel variables from file ...'
		endif
		call wheel#disc#read (g:wheel_config.file)
		if argc() == 0
			call wheel#vortex#jump ()
		endif
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
	endif
endfun

fun! wheel#disc#symlink_tree (...)
	" Tree of symlinks following the wheel hierarchy
	" torus/circle/link-to-location-file
	if a:0 > 0
		let soil = a:1
	else
		let prompt = 'Directory to grow tree ? '
		let soil = input(prompt, '', 'dir')
	endif
	let old_cdpath = &cdpath
	set cdpath=,,
	let cd_parent = 'cd ..'
	" chop newline at beginning of pwd output
	let old_dir = execute('pwd')[1:]
	let cd_soil = 'cd ' . soil
	call execute(cd_soil)
	let mkdir_wheel = 'mkdir -p wheel'
	call system(mkdir_wheel)
	let cd_wheel = 'cd wheel'
	call execute(cd_wheel)
	let counter = 0
	for torus in g:wheel.toruses
		let torus_dir = torus.name
		let mkdir_torus = 'mkdir -p ' . torus_dir
		call system(mkdir_torus)
		let cd_torus = 'cd ' . torus_dir
		call execute(cd_torus)
		for circle in torus.circles
			"echomsg 'Processing circle' circle.name 'in torus' torus.name
			let circle_dir = circle.name
			let mkdir_circle = 'mkdir -p ' . circle_dir
			call system(mkdir_circle)
			let cd_circle = 'cd ' . circle_dir
			call execute(cd_circle)
			for location in circle.locations
				let link = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_link = 'ln -s ' . file . ' ' . link
				"echomsg 'Linking' link '->' file
				call system(make_link)
				let counter += 1
				if counter % 10 == 0
					echomsg 'Processing link #' counter
				endif
			endfor
			call execute(cd_parent)
		endfor
		call execute(cd_parent)
	endfor
	let cd_old_dir = 'cd ' . old_dir
	echo cd_old_dir
	call execute(cd_old_dir)
	let &cdpath = old_cdpath
	return v:true
endfun

fun! wheel#disc#copied_tree ()
	" Tree of files copies following the wheel hierarchy
	" torus/circle/copy-of-the-location-file
endfun
