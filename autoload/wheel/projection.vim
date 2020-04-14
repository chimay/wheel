" vim: ft=vim fdm=indent:


fun! wheel#projection#closest ()
	" Find closest location to current buffer file & position
	" The search is done in album index
	let cur_file = expand('%:p')
	let cur_line = line('.')
	let album = deepcopy(wheel#helix#album ())
	call filter(album, {_,value -> value[2].file == cur_file})
	if empty(album)
		return []
	endif
	let lines = map(deepcopy(album), {_, val -> val[2].line})
	let deltas = map(copy(lines), {_, val -> abs(val - cur_line)})
	let minim = min(deltas)
	let where = index(deltas, minim)
	let minline = lines[where]
	let closest = filter(album, {_,value -> value[2].line == minline})[0]
	let coordin = closest[0:1] + [closest[2].name]
	return coordin
endfun

fun! wheel#projection#follow ()
	" Try to set current location to match current file
	" Choose location closest to current line
	let cur_file = expand('%:p')
	let cur_location = wheel#referen#location()
	if ! empty(cur_location)
		if cur_file ==# cur_location.file
			return
		endif
	endif
	let coordin = wheel#projection#closest ()
	if ! empty(coordin)
		call wheel#vortex#chord(coordin)
		if g:wheel_config.cd_project > 0
			let markers = g:wheel_config.project_markers
			call wheel#gear#project_root(markers)
		endif
		call wheel#pendulum#record ()
		let info = 'Wheel follows : '
		let info .= coordin[0] . ' > ' . coordin[1] . ' > ' . coordin[2]
		redraw!
		echomsg info
	endif
endfun

