" vim: set ft=vim fdm=indent iskeyword&:

" Storage
" Note : use expand to expand '~' in filenames

" read & write wheel variables

" helpers

fun! wheel#disc#write (pointer, file, ...)
	" Write variable referenced by pointer to file
	" in a format that can be :sourced
	" Note : pointer = variable name in vim script
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
	" Roll backups number of file
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

" wheel file

fun! wheel#disc#write_all (...)
	" Write all wheel variables to file argument
	" File defaults to g:wheel_config.file
	if a:0 > 0
		let wheel_file = expand(a:1)
	else
		if has_key(g:wheel_config, 'file')
			let wheel_file = expand(g:wheel_config.file)
		else
			echomsg 'Please configure g:wheel_config.file = my_wheel_file'
		endif
	endif
	if wheel#referen#empty ('wheel')
		echomsg 'Not writing empty wheel'
		return
	endif
	call wheel#vortex#update ()
	if argc() == 0 && has('nvim')
		echomsg 'Writing wheel variables to file ...'
	endif
	call wheel#disc#roll_backups(wheel_file, g:wheel_config.backups)
	call wheel#disc#write('g:wheel', wheel_file, '>')
	call wheel#disc#write('g:wheel_helix', wheel_file, '>>')
	call wheel#disc#write('g:wheel_grid', wheel_file, '>>')
	call wheel#disc#write('g:wheel_files', wheel_file, '>>')
	call wheel#disc#write('g:wheel_history', wheel_file, '>>')
	call wheel#disc#write('g:wheel_track', wheel_file, '>>')
	call wheel#disc#write('g:wheel_alternate', wheel_file, '>>')
	call wheel#disc#write('g:wheel_input', wheel_file, '>>')
	call wheel#disc#write('g:wheel_attic', wheel_file, '>>')
	call wheel#disc#write('g:wheel_wave', wheel_file, '>>')
	call wheel#disc#write('g:wheel_ripple', wheel_file, '>>')
	call wheel#disc#write('g:wheel_yank', wheel_file, '>>')
	call wheel#disc#write('g:wheel_shelve', wheel_file, '>>')
	if argc() == 0 && has('nvim')
		echomsg 'Writing done !'
	endif
endfun

fun! wheel#disc#read_all (...)
	" Read all wheel variables from file argument
	" File defaults to g:wheel_config.file
	if a:0 > 0
		let wheel_file = expand(a:1)
	else
		if has_key(g:wheel_config, 'file')
			let wheel_file = expand(g:wheel_config.file)
		else
			echomsg 'Please configure g:wheel_config.file = my_wheel_file'
		endif
	endif
	if argc() == 0 && has('nvim')
		echomsg 'Reading wheel variables from file ...'
	endif
	call wheel#disc#read (wheel_file)
	if argc() == 0
		call wheel#vortex#jump ()
	endif
endfun

" session : layout of tabs & windows

fun! wheel#disc#write_session (...)
	" Write session layout to session file
	if a:0 > 0
		let session_file = expand(a:1)
	else
		if has_key(g:wheel_config, 'session_file')
			let session_file = expand(g:wheel_config.session_file)
		else
			echomsg 'Please configure g:wheel_config.session_file = my_wheel_file'
		endif
	endif
	" backup value of sessionoptions
	let ampersand = &sessionoptions
	set sessionoptions=tabpages,winsize
	" backup old sessions
	call wheel#disc#roll_backups(session_file, g:wheel_config.backups)
	" writing session
	if argc() == 0 && has('nvim')
		echomsg 'Writing session to file ...'
	endif
	exe 'mksession!' session_file
	" restore value of sessionoptions
	let &sessionoptions=ampersand
	if argc() == 0 && has('nvim')
		echomsg 'Writing done !'
	endif
endfun

fun! wheel#disc#read_session (...)
	" Read session layout from session file
	if a:0 > 0
		let session_file = expand(a:1)
	else
		if has_key(g:wheel_config, 'session_file')
			let session_file = expand(g:wheel_config.session_file)
		else
			echomsg 'Please configure g:wheel_config.session_file = my_wheel_file'
		endif
	endif
	if argc() == 0 && has('nvim')
		echomsg 'Reading session from file ...'
	endif
	if filereadable(session_file)
		exe 'source' session_file
	else
		echomsg 'wheel disc read session : session file does not exist.'
	endif
endfun

" tree torus/circle/location in the filesystem

fun! wheel#disc#tree_script (...)
	" Write a shell script which generates a tree of symlinks or copies
	" following the wheel hierarchy torus/circle/location
	if a:0 > 0
		let soil = a:1
	else
		let prompt = 'Directory to grow tree ? '
		let soil = input(prompt, '', 'dir')
	endif
	if a:0 > 1
		let command = a:1
	else
		let prompt = 'Command to link/copy ? '
		let complete =  'customlist,wheel#completelist#link_copy'
		let command = input(prompt, 'ln -s', complete)
	endif
	if a:0 > 2
		let script_file = a:2
	else
		let prompt = 'Write script in file ? '
		let script_file = input(prompt, '', 'file')
		let script_file = expand(script_file)
	endif
	let script = []
	call add(script, '#!/bin/sh')
	call add(script, 'cd ' . soil)
	call add(script, 'mkdir -p wheel')
	call add(script, 'cd wheel')
	for torus in g:wheel.toruses
		let torus_dir = torus.name
		call add(script, 'mkdir -p ' . torus_dir)
		call add(script, 'cd ' . torus_dir)
		for circle in torus.circles
			let circle_dir = circle.name
			call add(script, 'mkdir -p ' . circle_dir)
			call add(script, 'cd ' . circle_dir)
			for location in circle.locations
				let link = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_link = command . ' ' . file . ' ' . link
				call add(script, make_link)
			endfor
			call add(script, 'cd ..')
		endfor
		call add(script, 'cd ..')
	endfor
	if filereadable(script_file)
		let prompt = 'Replace existing ' . script_file . ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return v:false
		endif
	endif
	call writefile(script, script_file)
	call system('chmod +x ' . script_file)
	return script
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
				if counter % 15 == 0
					echomsg 'Processing location #' counter
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
	" Useful to make a backup of the wheel files
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
				let backup = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_backup = 'cp -n ' . file . ' ' . backup
				"echomsg 'Copying' file
				call system(make_backup)
				let counter += 1
				if counter % 15 == 0
					echomsg 'Processing location #' counter
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
