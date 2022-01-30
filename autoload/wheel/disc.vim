" vim: set ft=vim fdm=indent iskeyword&:

" Storage

" read & write wheel variables

" ---- file system operations

" -- directory

fun! wheel#disc#relative_path (...)
	" Return path of filename relative to current directory
	" Optional argument :
	"   - filename
	"   - default : current filename
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%:p')
	endif
	let directory = '\m^' .. getcwd() .. '/'
	let filename = substitute(filename, directory, '', '')
	return filename
endfun

fun! wheel#disc#project_root (markers)
	" Change local directory to root of project marked by markers
	" start in current buffer directory
	let markers = a:markers
	if type(a:markers) == v:t_string
		let markers = [ a:markers ]
	endif
	let directory = expand('%:p:h')
	execute 'lcd' directory
	let found = 0
	while v:true
		for flag in markers
			if filereadable(flag) || isdirectory(flag)
				let found = 1
				break
			endif
		endfor
		if found || directory ==# '/'
			break
		endif
		lcd ..
		let directory = getcwd()
	endwhile
	return directory
endfun

fun! wheel#disc#mkdir (directory)
	" Create directory if non existent
	let directory = fnamemodify(a:directory, ':p')
	" nothing to do if directory already exists
	if isdirectory(directory)
		return 'nothing-to-do'
	endif
	" create directory
	echomsg 'wheel : creating directory' directory
	let success = mkdir(directory, 'p')
	if ! success
		echomsg 'wheel disc mkdir : error creating directory' directory
		return 'failure'
	endif
	return 'success'
endfun

" -- file

fun! wheel#disc#rename (source, destination, ask = 'confirm')
	" Rename file ; perform some checks
	let source = a:source
	let destination = a:destination
	let ask = a:ask
	" check not empty
	if empty(source)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-source-file-name'
	endif
	if empty(destination)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-destination-file-name'
	endif
	" full path
	let source = fnamemodify(source, ':p')
	let destination = fnamemodify(destination, ':p')
	" nothing to do if source == destination
	if source ==# destination
		echomsg 'wheel disc rename : nothing to do if new filename == old one'
		return 'nothing-to-do'
	endif
	" check source is directory
	if isdirectory(source)
		echomsg 'wheel disc rename : source must be a regular file'
		return 'source-is-directory'
	endif
	" check non existent source
	if ! filereadable(source)
		echomsg 'wheel disc rename : source file not readable'
		return 'source-not-readable'
	endif
	" check existent destination
	if ask == 'confirm' && filereadable(destination)
		let prompt = 'Replace existing ' .. destination .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-replace-destination-no'
		endif
	endif
	" create directory if needed
	let directory = fnamemodify(destination, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring == 'failure'
		return v:false
	endif
	" rename
	let zero = rename(source, destination)
	if zero != 0
		echomsg 'wheel disc rename : error renaming' source '->' destination
		return 'failure'
	endif
	return 'success'
endfun

fun! wheel#disc#copy (source, destination, ask = 'confirm')
	" Copy file ; perform some checks
	let source = a:source
	let destination = a:destination
	let ask = a:ask
	" check not empty
	if empty(source)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-source-file-name'
	endif
	if empty(destination)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-destination-file-name'
	endif
	" full path
	let source = fnamemodify(source, ':p')
	let destination = fnamemodify(destination, ':p')
	" nothing to do if source == destination
	if source ==# destination
		echomsg 'wheel disc copy : nothing to do if new filename == old one'
		return 'nothing-to-do'
	endif
	" check source is directory
	if isdirectory(source)
		echomsg 'wheel disc copy : source must be a regular file'
		return 'source-is-directory'
	endif
	" check non existent source
	if ! filereadable(source)
		echomsg 'wheel disc copy : source file not readable'
		return 'source-not-readable'
	endif
	" check existent destination
	if ask == 'confirm' && filereadable(destination)
		let prompt = 'Replace existing ' .. destination .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-replace-destination-no'
		endif
	endif
	" create directory if needed
	let directory = fnamemodify(destination, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring == 'failure'
		return v:false
	endif
	" copy
	let content = readfile(source, 'b')
	let zero = writefile(content, destination, 'b')
	if zero != 0
		return 'failure'
	endif
	return 'success'
endfun

fun! wheel#disc#delete (file, ask = 'confirm')
	" Delete file ; perform some checks
	let file = a:file
	let ask = a:ask
	" check not empty
	if empty(file)
		echomsg 'wheel disc delete : file name cannot be empty'
		return 'empty-file-name'
	endif
	" full path
	let file = fnamemodify(file, ':p')
	" check file is directory
	if isdirectory(file)
		echomsg 'wheel disc delete : file must be a regular file'
		return 'file-is-directory'
	endif
	" check non existent file
	if ! filereadable(file)
		echomsg 'wheel disc delete : file not readable'
		return 'file-not-readable'
	endif
	" ask confirmation
	if ask == 'confirm'
		let prompt = 'Delete ' .. file .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-no'
		endif
	endif
	" delete
	let zero = delete(file)
	if zero != 0
		return 'failure'
	endif
	return 'success'
endfun

" ---- write & read

fun! wheel#disc#writefile (varname, file, where = '>')
	" Write variable referenced by varname to file
	" in a format that can be :sourced
	" If optional argument is :
	"   - '>' : replace file content (default)
	"   - '>>' : append to file content
	" Uses writefile()
	let varname = a:varname
	if ! exists(varname)
		return v:false
	endif
	let file = fnamemodify(a:file, ':p')
	let where = a:where
	" create directory if needed
	let directory = fnamemodify(file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring == 'failure'
		return v:false
	endif
	" write
	let string = 'let ' .. varname .. ' = ' .. string({varname})
	let string = substitute(string, '\m[=,]', '\0\\', 'g')
	let list = split(string, '\m[=,]\zs')
	if where == '>>'
		call writefile(list, file, 'a')
	else
		call writefile(list, file)
	endif
endfun

fun! wheel#disc#write (pointer, file, where = '>')
	" Write variable referenced by pointer to file
	" in a format that can be :sourced
	" Note : pointer = variable name in vim script
	" If optional argument 1 is :
	"   - '>' : replace file content (default)
	"   - '>>' : append to file content
	" Doesn't work well with some abbreviated echoed variables content in vim
	" disc#writefile is more reliable with vim
	let pointer = a:pointer
	if ! exists(pointer)
		return
	endif
	let file = fnamemodify(a:file, ':p')
	let where = a:where
	" create directory if needed
	let directory = fnamemodify(file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring == 'failure'
		return v:false
	endif
	" write
	let var = {pointer}
	redir => content
	silent! echo 'let' pointer '=' var
	redir END
	let content = substitute(content, '\m[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\m\n\{2,\}', '\n', 'g')
	exec 'redir!' where file
	silent! echo content
	redir END
endfun

fun! wheel#disc#read (file)
	" Read file
	let file = fnamemodify(a:file, ':p')
	if filereadable(file)
		execute 'source' file
	else
		echomsg 'Could not read' file
	endif
endfun

" ---- arguments at (neo)vim startup

fun! wheel#disc#argc ()
	" Number of file args at vim startup
	return g:wheel_volatile.argc
endfun

" ---- roll backups

fun! wheel#disc#roll_backups (file, backups)
	" Roll backups number of file
	let file = fnamemodify(a:file, ':p')
	let backups = a:backups
	let padding = len(string(backups))
	let format = '%0' .. padding .. 'd'
	let suffixes = range(backups, 1, -1)
	eval suffixes->map({ _, val -> printf(format, val) })
	let filelist = map(suffixes, {ind, val -> file .. '.' .. val})
	let filelist = add(filelist, file)
	while len(filelist) > 1
		let second = remove(filelist, 0)
		let first = filelist[0]
		if filereadable(first)
			"echomsg 'backup' first '->' second
			let returnstring = wheel#disc#rename(first, second, 'force')
			if returnstring == 'failure'
				echomsg 'wheel batch rename files : error renaming' first '->' second
				return v:false
			endif
		endif
	endwhile
endfun

" ---- wheel file

fun! wheel#disc#write_wheel (...)
	" Write all wheel variables to file argument
	" File defaults to g:wheel_config.file
	if a:0 > 0
		let wheel_file = fnamemodify(a:1, ':p')
	else
		if empty(g:wheel_config.file)
			echomsg 'Please configure g:wheel_config.file = my_wheel_file'
			return v:false
		else
			let wheel_file = fnamemodify(g:wheel_config.file, ':p')
		endif
	endif
	if wheel#referen#is_empty ('wheel')
		echomsg 'Not writing empty wheel'
		return v:false
	endif
	call wheel#vortex#update ()
	call wheel#kintsugi#wheel_file ()
	echomsg 'Writing wheel variables to file ..'
	call wheel#disc#roll_backups(wheel_file, g:wheel_config.backups)
	" replace >
	call wheel#disc#writefile('g:wheel', wheel_file, '>')
	" append >>
	call wheel#disc#writefile('g:wheel_helix', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_grid', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_files', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_history', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_input', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_attic', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_yank', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_shelve', wheel_file, '>>')
	echomsg 'Writing done !'
	return v:true
endfun

fun! wheel#disc#read_wheel (...)
	" Read all wheel variables from file argument
	" File defaults to g:wheel_config.file
	if a:0 > 0
		let wheel_file = fnamemodify(a:1, ':p')
	else
		if empty(g:wheel_config.file)
			echomsg 'Please configure g:wheel_config.file = my_wheel_file'
			return v:false
		else
			let wheel_file = fnamemodify(g:wheel_config.file, ':p')
		endif
	endif
	let init_argc = wheel#disc#argc ()
	if init_argc == 0
		echomsg 'Reading wheel variables from file ..'
	endif
	call wheel#disc#read (wheel_file)
	call wheel#kintsugi#wheel_file ()
	if init_argc == 0
		call wheel#vortex#jump ()
		echomsg 'Reading done !'
	endif
	return v:true
endfun

" ---- session file : layout of tabs & windows

fun! wheel#disc#write_session (...)
	" Write session layout to session file
	if a:0 > 0
		let session_file = fnamemodify(a:1, ':p')
	else
		if empty(g:wheel_config.session_file)
			echomsg 'Please configure g:wheel_config.session_file = my_session_file'
			return v:false
		else
			let session_file = fnamemodify(g:wheel_config.session_file, ':p')
		endif
	endif
	" backup value of sessionoptions
	let ampersand = &sessionoptions
	set sessionoptions=tabpages,winsize
	" create directory if needed
	let directory = fnamemodify(session_file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring == 'failure'
		return v:false
	endif
	" backup old sessions
	call wheel#disc#roll_backups(session_file, g:wheel_config.backups)
	" writing session
	echomsg 'Writing session to file ..'
	execute 'mksession!' session_file
	" restore value of sessionoptions
	let &sessionoptions=ampersand
	echomsg 'Writing done !'
	return v:true
endfun

fun! wheel#disc#read_session (...)
	" Read session layout from session file
	if a:0 > 0
		let session_file = fnamemodify(a:1, ':p')
	else
		if empty(g:wheel_config.session_file)
			echomsg 'Please configure g:wheel_config.session_file = my_session_file'
			return v:false
		else
			let session_file = fnamemodify(g:wheel_config.session_file, ':p')
		endif
	endif
	let init_argc = wheel#disc#argc ()
	if init_argc == 0 && has('nvim')
		echomsg 'Reading session from file ..'
	endif
	if filereadable(session_file)
		execute 'source' session_file
	else
		echomsg 'wheel disc read session : session file does not exist'
	endif
	" even windows in each tab
	" does not work
	"tabdo wincmd =
	"tabnext 1
	if init_argc == 0 && has('nvim')
		echomsg 'Reading done !'
	endif
	return v:true
endfun

" ---- tree following torus/circle/location hierarchy in the filesystem

fun! wheel#disc#tree_script (...)
	" Write a shell script which generates a tree of symlinks or copies
	" following the wheel hierarchy torus/circle/location
	if ! has('unix')
		echomsg 'wheel tree script : this function is only supported on Unix systems'
		return v:false
	endif
	if a:0 > 0
		let soil = a:1
	else
		let prompt = 'Directory to grow tree ? '
		let complete = 'customlist,wheel#complete#directory'
		let soil = input(prompt, '', complete)
	endif
	if a:0 > 1
		let command = a:1
	else
		let prompt = 'Command to link/copy ? '
		let complete = 'customlist,wheel#complete#link_copy'
		let command = input(prompt, 'ln -s', complete)
	endif
	if a:0 > 2
		let script_file = a:2
	else
		let prompt = 'Write script in file ? '
		let script_file = input(prompt, '', 'file')
		let script_file = wheel#tree#format_filename (script_file)
	endif
	let script = []
	eval script->add('#!/bin/sh')
	eval script->add('cd ' .. soil)
	eval script->add('mkdir -p wheel')
	eval script->add('cd wheel')
	for torus in g:wheel.toruses
		let torus_dir = torus.name
		eval script->add('mkdir -p ' .. torus_dir)
		eval script->add('cd ' .. torus_dir)
		for circle in torus.circles
			let circle_dir = circle.name
			eval script->add('mkdir -p ' .. circle_dir)
			eval script->add('cd ' .. circle_dir)
			for location in circle.locations
				let link = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_link = command .. ' ' .. file .. ' ' .. link
				eval script->add(make_link)
			endfor
			eval script->add('cd ..')
		endfor
		eval script->add('cd ..')
	endfor
	if filereadable(script_file)
		let prompt = 'Replace existing ' .. script_file .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return v:false
		endif
	endif
	call writefile(script, script_file)
	call system('chmod +x ' .. script_file)
	return script
endfun

fun! wheel#disc#symlink_tree (...)
	" Tree of symlinks following the wheel hierarchy
	" torus/circle/link-to-location-file
	if ! has('unix')
		echomsg 'wheel symlink tree : this function is only supported on Unix systems'
		return v:false
	endif
	if a:0 > 0
		let soil = a:1
	else
		let prompt = 'Directory to grow tree ? '
		let complete = 'customlist,wheel#complete#directory'
		let soil = input(prompt, '', complete)
	endif
	let old_cdpath = &cdpath
	set cdpath=,,
	let cd_parent = 'cd ..'
	" chop newline at beginning of pwd output
	let old_dir = execute('pwd')[1:]
	let cd_soil = 'cd ' .. soil
	call execute(cd_soil)
	let mkdir_wheel = 'mkdir -p wheel'
	call system(mkdir_wheel)
	let cd_wheel = 'cd wheel'
	call execute(cd_wheel)
	let counter = 0
	for torus in g:wheel.toruses
		let torus_dir = torus.name
		let mkdir_torus = 'mkdir -p ' .. torus_dir
		call system(mkdir_torus)
		let cd_torus = 'cd ' .. torus_dir
		call execute(cd_torus)
		for circle in torus.circles
			"echomsg 'Processing circle' circle.name 'in torus' torus.name
			let circle_dir = circle.name
			let mkdir_circle = 'mkdir -p ' .. circle_dir
			call system(mkdir_circle)
			let cd_circle = 'cd ' .. circle_dir
			call execute(cd_circle)
			for location in circle.locations
				let link = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_link = 'ln -s ' .. file .. ' ' .. link
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
	let cd_old_dir = 'cd ' .. old_dir
	echo cd_old_dir
	call execute(cd_old_dir)
	let &cdpath = old_cdpath
	return v:true
endfun

fun! wheel#disc#copied_tree ()
	" Tree of files copies following the wheel hierarchy
	" torus/circle/copy-of-the-location-file
	" Useful to make a backup of the wheel files
	if ! has('unix')
		echomsg 'wheel copied tree : this function is only supported on Unix systems'
		return v:false
	endif
	if a:0 > 0
		let soil = a:1
	else
		let prompt = 'Directory to grow tree ? '
		let complete = 'customlist,wheel#complete#directory'
		let soil = input(prompt, '', complete)
	endif
	let old_cdpath = &cdpath
	set cdpath=,,
	let cd_parent = 'cd ..'
	" chop newline at beginning of pwd output
	let old_dir = execute('pwd')[1:]
	let cd_soil = 'cd ' .. soil
	call execute(cd_soil)
	let mkdir_wheel = 'mkdir -p wheel'
	call system(mkdir_wheel)
	let cd_wheel = 'cd wheel'
	call execute(cd_wheel)
	let counter = 0
	for torus in g:wheel.toruses
		let torus_dir = torus.name
		let mkdir_torus = 'mkdir -p ' .. torus_dir
		call system(mkdir_torus)
		let cd_torus = 'cd ' .. torus_dir
		call execute(cd_torus)
		for circle in torus.circles
			"echomsg 'Processing circle' circle.name 'in torus' torus.name
			let circle_dir = circle.name
			let mkdir_circle = 'mkdir -p ' .. circle_dir
			call system(mkdir_circle)
			let cd_circle = 'cd ' .. circle_dir
			call execute(cd_circle)
			for location in circle.locations
				let backup = substitute(location.name, '/', '-', 'g')
				let file = location.file
				let make_backup = 'cp -n ' .. file .. ' ' .. backup
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
	let cd_old_dir = 'cd ' .. old_dir
	echo cd_old_dir
	call execute(cd_old_dir)
	let &cdpath = old_cdpath
	return v:true
endfun
