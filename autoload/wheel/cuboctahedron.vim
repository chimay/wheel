" vim: ft=vim fdm=indent:

" Changes of internal structure

" Script vars

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Functions

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
	" The add_* will record new timestamps ; let’s keep the old ones
	let prompt = 'Write old wheel to file before reorganizing ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_all ()
	endif
	" Start from empty wheel
	unlet g:wheel
	call wheel#void#wheel ()
	" Loop over buffer lines
	let linelist = getline(1, '$')
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' . s:fold_1 . '$'
	let pat_fold_two = '\m' . s:fold_2 . '$'
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
			call wheel#tree#add_location(location, 'norecord')
		endif
	endfor
	" Rebuild full location index
	call wheel#helix#album ()
	" Rebuild location index
	call wheel#helix#helix ()
	" Rebuild circle index
	call wheel#helix#grid ()
	" Rebuild file index
	call wheel#helix#files ()
	" Remove invalid entries from history
	call wheel#checknfix#history ()
	" Info
	setlocal nomodified
	echomsg 'Changes written to wheel'
	" Tune wheel coordinates to first entry in history
	call wheel#vortex#chord(g:wheel_history[0].coordin)
endfun

fun! wheel#cuboctahedron#reorg_tabwins ()
	" Reorganize tabs & windows
	" Split commands
	let split_commands = ['vsplit', 'split']
	" Mandala line list
	let linelist = getline(1, '$')
	" Restart from scratch
	tabonly
	" First buffer
	wincmd p
	only
	exe 'buffer' linelist[1]
	call wheel#cylinder#recall ()
	" Loop over mandala lines
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' . s:fold_1 . '$'
	let mandala = win_getid ()
	let index = 2
	let win_nr = 0
	let length = len(linelist)
	while index < length
		let line = linelist[index]
		if line =~ pat_fold_one
			" tab line
			tabnew
			let win_nr = 0
			let index += 1
			let line = linelist[index]
			exe 'buffer' line
			let index += 1
		else
			" window line
			exe split_commands[win_nr % 2]
			exe 'buffer' line
			let index += 1
			let win_nr += 1
		endif
	endwhile
	call win_gotoid(mandala)
	setlocal nomodified
	echomsg 'tabs & windows reorganized.'
endfun
