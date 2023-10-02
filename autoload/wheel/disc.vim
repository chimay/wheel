" vim: set ft=vim fdm=indent iskeyword&:

" Disc
"
" Persistent storage

" read & write wheel variables

" ---- helpers

fun! wheel#disc#full_path (...)
	" Return filename full path
	" Default : current file name
	" % -> current filename
	" # -> alternate filename
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%')
	endif
	if filename ==# '%'
		let filename = getreg('%')
	endif
	if filename ==# '#'
		let filename = getreg('#')
	endif
	let filename = trim(filename, ' ')
	let filename = fnamemodify(filename, ':p')
	let filename = fnameescape(filename)
	return filename
endfun

fun! wheel#disc#format_name (filename)
	" Format filename to avoid annoying characters
	let filename = a:filename
	let filename = wheel#disc#full_path (filename)
	let filename = substitute(filename, ' ', '_', 'g')
	return filename
endfun

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
	" ---- check not empty
	if empty(filename)
		echomsg 'wheel disc relative_path : file name cannot be empty'
		return 'empty-file-name'
	endif
	"let directory = '\m^' .. getcwd() .. '/'
	let filename = wheel#disc#full_path (filename)
	let filename = fnamemodify(filename, ':.')
	return filename
endfun

fun! wheel#disc#project_root (markers)
	" Change local directory to root of project marked by markers
	" start in current buffer directory
	let markers = a:markers
	if type(a:markers) == v:t_string
		let markers = [ a:markers ]
	endif
	" ---- current file directory
	let directory = expand('%:p:h')
	execute 'lcd' directory
	" ---- find marker
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
	" ---- project root
	return directory
endfun

fun! wheel#disc#mkdir (directory)
	" Create directory if non existent
	let directory = fnamemodify(a:directory, ':p')
	" ---- check not empty
	if empty(directory)
		echomsg 'wheel disc mkdir : dir name cannot be empty'
		return 'empty-dir-name'
	endif
	" ---- format dir name
	let directory = wheel#disc#format_name (directory)
	" ---- nothing to do if directory already exists
	if isdirectory(directory)
		return 'nothing-to-do'
	endif
	" ---- create directory
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
	" ---- check not empty
	if empty(source)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-source-file-name'
	endif
	if empty(destination)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-destination-file-name'
	endif
	" ---- full path
	let source = wheel#disc#full_path (source)
	let destination = wheel#disc#format_name (destination)
	" ---- nothing to do if source == destination
	if source ==# destination
		echomsg 'wheel disc rename : nothing to do if new filename == old one'
		return 'nothing-to-do'
	endif
	" ---- check source is directory
	if isdirectory(source)
		echomsg 'wheel disc rename : source must be a regular file'
		return 'source-is-directory'
	endif
	" ---- check non existent source
	if ! filereadable(source)
		echomsg 'wheel disc rename : source file not readable'
		return 'source-not-readable'
	endif
	" ---- check existent destination
	if ask ==# 'confirm' && filereadable(destination)
		let prompt = 'Replace existing ' .. destination .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-replace-destination-no'
		endif
	endif
	" ---- create directory if needed
	let directory = fnamemodify(destination, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return 'failure'
	endif
	" ---- rename
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
	" ---- check not empty
	if empty(source)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-source-file-name'
	endif
	if empty(destination)
		echomsg 'wheel disc rename : file name cannot be empty'
		return 'empty-destination-file-name'
	endif
	" ---- full path
	let source = wheel#disc#full_path (source)
	let destination = wheel#disc#format_name (destination)
	" ---- nothing to do if source == destination
	if source ==# destination
		echomsg 'wheel disc copy : nothing to do if new filename == old one'
		return 'nothing-to-do'
	endif
	" ---- check source is directory
	if isdirectory(source)
		echomsg 'wheel disc copy : source must be a regular file'
		return 'source-is-directory'
	endif
	" ---- check non existent source
	if ! filereadable(source)
		echomsg 'wheel disc copy : source file not readable'
		return 'source-not-readable'
	endif
	" ---- check existent destination
	if ask ==# 'confirm' && filereadable(destination)
		let prompt = 'Replace existing ' .. destination .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-replace-destination-no'
		endif
	endif
	" ---- create directory if needed
	let directory = fnamemodify(destination, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return 'failure'
	endif
	" ---- copy
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
	" ---- check not empty
	if empty(file)
		echomsg 'wheel disc delete : file name cannot be empty'
		return 'empty-file-name'
	endif
	" ---- full path
	let file = wheel#disc#full_path (file)
	" ---- check file is directory
	if isdirectory(file)
		echomsg 'wheel disc delete : file must be a regular file'
		return 'file-is-directory'
	endif
	" ---- check non existent file
	if ! filereadable(file)
		echomsg 'wheel disc delete : file not readable'
		return 'file-not-readable'
	endif
	" ---- ask confirmation
	if ask ==# 'confirm'
		let prompt = 'Delete ' .. file .. ' ?'
		let overwrite = confirm(prompt, "&Yes\n&No", 2)
		if overwrite != 1
			return 'confirm-no'
		endif
	endif
	" ---- delete
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
	" ---- create directory if needed
	let directory = fnamemodify(file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return 'failure'
	endif
	" ---- write
	let string = 'let ' .. varname .. ' = ' .. string({varname})
	let string = substitute(string, '\m[=,]', '\0\\', 'g')
	let list = split(string, '\m[=,]\zs')
	if where ==# '>>'
		let zero = writefile(list, file, 'a')
		if zero != 0
			return 'failure'
		endif
	else
		let zero = writefile(list, file)
		if zero != 0
			return 'failure'
		endif
	endif
	return 'success'
endfun

fun! wheel#disc#readfile (file)
	" Read file
	let file = fnamemodify(a:file, ':p')
	if ! filereadable(file)
		echomsg 'Could not read' file
	endif
	let lines = readfile(file)
	" ---- loop on variables
	let start = lines->match('^let g:wheel')
	while start >= 0
		let end = lines->match('^let g:wheel', start + 1) - 1
		if end < 0
			let slice = lines[start:]
		else
			let slice = lines[start:end]
		endif
		if len(slice) > 1
			let following = slice[1:]
			" -- remove the backslashes at beginning of each line
			eval following->map({ _, val -> val[1:] })
			let slice = [ slice[0] ] + following
		endif
		let string = join(slice)
		execute string
		let start = end + 1
	endwhile
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
		if ! filereadable(first)
			continue
		endif
		"echomsg 'backup' first '->' second
		let returnstring = wheel#disc#rename(first, second, 'force')
		if returnstring ==# 'failure'
			echomsg 'wheel disc roll backups : error renaming' first '->' second
			return v:false
		endif
	endwhile
endfun

" ---- wheel file

fun! wheel#disc#write_wheel (...)
	" Write all wheel variables to wheel file
	" File defaults to g:wheel_config.file
	" Optional arguments :
	"   - wheel file
	"   - verbose
	if a:0 > 0 && ! empty(a:1)
		let wheel_file = fnamemodify(a:1, ':p')
	elseif ! empty(g:wheel_config.file)
		let wheel_file = fnamemodify(g:wheel_config.file, ':p')
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
		return v:false
	endif
	if a:0 > 1
		let verbose = a:2
	else
		let verbose = v:true
	endif
	if wheel#referen#is_empty ('wheel')
		"echomsg 'Not writing empty wheel'
		return v:false
	endif
	" ---- create directory if needed
	let directory = fnamemodify(wheel_file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return v:false
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeWrite
	" ---- convert old data
	call wheel#kintsugi#wheel_file ()
	" ---- write
	"echomsg 'Writing wheel variables to file ..'
	call wheel#disc#roll_backups(wheel_file, g:wheel_config.backups)
	" -- replace >
	call wheel#disc#writefile('g:wheel', wheel_file, '>')
	" -- append >>
	call wheel#disc#writefile('g:wheel_helix', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_grid', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_files', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_history', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_input', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_shelve', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_attic', wheel_file, '>>')
	call wheel#disc#writefile('g:wheel_yank', wheel_file, '>>')
	" ---- coda
	if verbose
		echomsg 'writing wheel : done'
	endif
	return v:true
endfun

fun! wheel#disc#read_wheel (...)
	" Read all wheel variables from wheel file
	" File defaults to g:wheel_config.file
	" Optional arguments :
	"   - wheel file
	"   - keep_tabwins
	"   - verbose
	if a:0 > 0 && ! empty(a:1)
		let wheel_file = fnamemodify(a:1, ':p')
	elseif ! empty(g:wheel_config.file)
		let wheel_file = fnamemodify(g:wheel_config.file, ':p')
	else
		echomsg 'Please configure g:wheel_config.file = my_wheel_file'
		return v:false
	endif
	if a:0 > 1
		let keep_tabwins = a:2
	else
		let keep_tabwins = 'dont-keep'
	endif
	if a:0 > 2
		let verbose = a:3
	else
		let verbose = v:true
	endif
	" ---- check
	if ! filereadable(wheel_file)
		echomsg 'wheel disc read wheel : wheel file does not exist'
		return v:false
	endif
	" ---- read file
	"echomsg 'Reading wheel variables from file ..'
	call wheel#disc#readfile (wheel_file)
	" ---- convert old data
	call wheel#kintsugi#wheel_file ()
	" ---- complete vars
	call wheel#void#foundation ()
	" ---- keep tabs & wins ?
	if keep_tabwins == 'dont-keep'
		call wheel#vortex#jump ()
	endif
	" ---- coda
	if verbose
		echomsg 'reading wheel : done'
	endif
	return v:true
endfun

" ---- session file : layout of tabs & windows

fun! wheel#disc#write_session_file (session_file, ...)
	" Write session layout to session file
	" Optional arguments :
	"   - wheel file
	"   - verbose
	" ---- arguments
	let session_file = a:session_file
	if a:0 > 0
		let verbose = a:1
	else
		let verbose = v:true
	endif
	" ---- create directory if needed
	let directory = fnamemodify(session_file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return v:false
	endif
	" ---- backup old sessions
	call wheel#disc#roll_backups(session_file, g:wheel_config.backups)
	" ----- writing session
	let commandlist = wheel#labyrinth#session ()
	let zero = writefile(commandlist, session_file)
	if zero != 0
		return 'failure'
	endif
	" ---- coda
	if verbose
		echomsg 'writing session : done'
	endif
	return v:true
endfun

fun! wheel#disc#read_session_file (session_file, ...)
	" Read session layout from session file
	" Optional arguments :
	"   - wheel file
	"   - keep_tabwins
	"   - verbose
	let session_file = a:session_file
	if a:0 > 0
		let keep_tabwins = a:1
	else
		let keep_tabwins = 'dont-keep'
	endif
	if a:0 > 1
		let verbose = a:2
	else
		let verbose = v:true
	endif
	" ---- check
	if ! filereadable(session_file)
		echomsg 'wheel disc read session file : session file does not exist'
		return v:false
	endif
	" ---- keep tabs & wins ?
	if keep_tabwins == 'dont-keep'
		silent tabonly
		silent only
	else
		silent tablast
		silent tabnew
	endif
	" ---- read file
	execute 'source' session_file
	" ---- make the wheel follow the current file
	call wheel#projection#follow ()
	" ---- coda
	if verbose
		echomsg 'reading session : done'
	endif
	return v:true
endfun

fun! wheel#disc#write_session (...)
	" Ask where to write current session and do it
	" Default : g:wheel_config.session_file
	" ---- automatic mode
	if a:0 > 0
		if ! empty(a:1)
			let session_file = fnamemodify(a:1, ':p')
		else
			if ! empty(g:wheel_config.session_file)
				let session_file = fnamemodify(g:wheel_config.session_file, ':p')
			else
				echomsg 'Please configure g:wheel_config.session_file'
				return v:false
			endif
		endif
		let arglist = [session_file] + a:000[1:]
		return call('wheel#disc#write_session_file', arglist)
	endif
	" ---- session dir
	if ! empty(g:wheel_config.session_dir)
		let session_dir = g:wheel_config.session_dir
	elseif ! empty(g:wheel_config.session_file)
		let session_dir = fnamemodify(g:wheel_config.session_dir, ':h')
	else
		echomsg 'Please configure g:wheel_config.session_dir or g:wheel_config.session_file'
		return v:false
	endif
	let session_dir = fnamemodify(session_dir, ':p')
	" ---- create directory if needed
	let returnstring = wheel#disc#mkdir(session_dir)
	if returnstring ==# 'failure'
		return v:false
	endif
	if session_dir[-1] ==# '/'
		let session_dir = session_dir[:-2]
	endif
	" ---- default session file
	if ! empty(g:wheel_config.session_file)
		let default_session = fnamemodify(g:wheel_config.session_file, ':t')
	endif
	" ---- session file
	let current_dir = getcwd()
	execute 'lcd' session_dir
	let prompt = 'Write session file ? '
	if exists('default_session')
		let prompt ..= '[' .. default_session .. '] '
	endif
	let complete = 'customlist,wheel#complete#file'
	let session_file = input(prompt, '', complete)
	if empty(session_file) && exists('default_session')
		let session_file = default_session
	endif
	let session_file = session_dir .. '/' .. session_file
	execute 'lcd' current_dir
	" ---- write session
	return wheel#disc#write_session_file(session_file)
endfun

fun! wheel#disc#read_session (...)
	" Ask where to read current session and do it
	" Default : g:wheel_config.session_file
	" ---- automatic mode
	if a:0 > 0
		if ! empty(a:1)
			let session_file = fnamemodify(a:1, ':p')
		else
			if ! empty(g:wheel_config.session_file)
				let session_file = fnamemodify(g:wheel_config.session_file, ':p')
			else
				echomsg 'Please configure g:wheel_config.session_file'
				return v:false
			endif
		endif
		let arglist = [session_file] + a:000[1:]
		return call('wheel#disc#read_session_file', arglist)
	endif
	" ---- session dir
	if ! empty(g:wheel_config.session_dir)
		let session_dir = g:wheel_config.session_dir
	elseif ! empty(g:wheel_config.session_file)
		let session_dir = fnamemodify(g:wheel_config.session_dir, ':h')
	else
		echomsg 'Please configure g:wheel_config.session_dir or g:wheel_config.session_file'
		return v:false
	endif
	let session_dir = fnamemodify(session_dir, ':p')
	if ! isdirectory(session_dir)
		echomsg 'wheel disc prompt_read_session :' session_dir  'does not exist'
		return v:false
	endif
	if session_dir[-1] ==# '/'
		let session_dir = session_dir[:-2]
	endif
	" ---- default session file
	if ! empty(g:wheel_config.session_file)
		let default_session = fnamemodify(g:wheel_config.session_file, ':t')
	endif
	" ---- session file
	let current_dir = getcwd()
	execute 'lcd' session_dir
	let prompt = 'Read session file ? '
	if exists('default_session')
		let prompt ..= '[' .. default_session .. '] '
	endif
	let complete = 'customlist,wheel#complete#file'
	let session_file = input(prompt, '', complete)
	if empty(session_file) && exists('default_session')
		let session_file = default_session
	endif
	let session_file = session_dir .. '/' .. session_file
	echomsg session_file
	execute 'lcd' current_dir
	" ---- write session
	return wheel#disc#read_session_file(session_file)
endfun

fun! wheel#disc#mksession (...)
	" Write session layout to session file with :mksession
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
	if returnstring ==# 'failure'
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
	if empty(soil)
		return []
	endif
	if a:0 > 1
		let command = a:1
	else
		let prompt = 'Command to link/copy ? '
		let complete = 'customlist,wheel#complete#link_copy'
		let command = input(prompt, 'ln -s', complete)
	endif
	if empty(command)
		return []
	endif
	if a:0 > 2
		let script_file = a:2
	else
		let prompt = 'Write script in file ? '
		let script_file = input(prompt, '', 'file')
		let script_file = wheel#disc#format_name (script_file)
	endif
	if empty(script_file)
		return []
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
	if empty(soil)
		return v:false
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
	if empty(soil)
		return v:false
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
