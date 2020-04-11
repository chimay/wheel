" vim: ft=vim fdm=indent:

" Changes of internal structure

fun! wheel#cuboctahedron#reorder (level)
	" Reorder current elements at level, after buffer content
	let level = a:level
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let key = wheel#referen#list_key (upper_level_name)
	let old_list = deepcopy(wheel#referen#elements (upper))
	let old_names = deepcopy(old_list)
	let old_names = map(old_names, {_,val -> val.name})
	let new_names = getline(1, '$')
	let new_list = []
	for name in new_names
		let index = index(old_names, name)
		if index >= 0
			let elem = old_list[index]
		else
			echomsg 'Wheel cuboctahedron reorder : ' name  'not found'
		endif
		call add(new_list, elem)
	endfor
	if len(new_list) < len(old_list)
		echomsg 'Some elements seem to be missing : changes not written'
	elseif len(new_list) > len(old_list)
		echomsg 'Elements in excess : changes not written'
	else
		let upper[key] = []
		let upper[key] = new_list
		let upper.glossary = new_names
		setlocal nomodified
		echomsg 'Changes written to wheel'
		return new_list
	endif
endfun

fun! wheel#cuboctahedron#reorganize ()
	" Rebuild wheel by adding elements contained in buffer
	" Follow folding tree
	" Backups
	let b:wheel_backup = deepcopy(g:wheel)
	" The add_* will record new timestamps ; let’s keep the old ones
	let history = deepcopy(g:wheel_history)
	" Start from empty wheel
	unlet g:wheel
	call wheel#void#wheel ()
	" Loop over buffer lines
	let linelist = getline(1, '$')
	let marker = split(&foldmarker, ',')[0]
	let pat_fold_one = '\m' . marker . '1$'
	let pat_fold_two = '\m' . marker . '2$'
	let pat_dict = '\m^{.*}'
	for line in linelist
		if line =~ pat_fold_one
			" torus line
			let torus = split(line)[0]
			call wheel#tree#add_torus(torus)
		elseif line =~ pat_fold_two
			" circle line
			let circle = split(line)[0]
			call wheel#tree#add_circle(circle)
		elseif line =~ pat_dict
			" location line
			let runme = 'let location = ' . line
			exe runme
			call wheel#tree#add_location(location)
		endif
	endfor
	" Rebuild location index
	call wheel#helix#helix ()
	" Rebuild circle index
	call wheel#helix#grid ()
	" Rebuild file index
	call wheel#helix#files ()
	" Restore history timestamps
	let g:wheel_history = history
	" Remove invalid entries from history
	call wheel#checknfix#history ()
	" Info
	setlocal nomodified
	echomsg 'Changes written to wheel'
	" Tune wheel coordinates to first entry in history
	call wheel#vortex#chord(history[0].coordin)
endfun
