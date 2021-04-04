" vim: ft=vim fdm=indent:

" Find & follow the closest element in wheel

fun! wheel#projection#closest (level, ...)
	" Find closest location to :
	"   - given file & line
	"   - filename & position (default)
	" The search is done in album index
	" Search in given current level = wheel, torus or circle
	if a:0 > 0
		let filename = a:1
	else
		let filename = expand('%:p')
	endif
	if a:0 > 1
		let linum = a:2
	else
		let linum = line('.')
	endif
	let album = deepcopy(wheel#helix#album ())
	call filter(album, {_,value -> value[2].file == filename})
	let narrow = wheel#referen#coordin_index(a:level)
	if narrow >= 0
		let narrow_names = wheel#referen#names()
		for index in range(0, narrow)
			call filter(album, {_,value -> value[index] == narrow_names[index]})
		endfor
	endif
	if empty(album)
		return []
	endif
	let lines = map(deepcopy(album), {_, val -> val[2].line})
	let deltas = map(copy(lines), {_, val -> abs(val - linum)})
	let minim = min(deltas)
	let where = index(deltas, minim)
	let minline = lines[where]
	let closest = filter(album, {_,value -> value[2].line == minline})[0]
	let coordin = closest[0:1] + [closest[2].name]
	return coordin
endfun

fun! wheel#projection#follow (...)
	" Try to set current location to match current file
	" Choose location closest to current line
	" Optional arguments :
	"   - level to search in : wheel, torus or circle
	if a:0 > 0
		let level = a:1
	else
		let level = 'wheel'
	endif
	" If torus or circle is empty, assume the user
	" wants to add something before switching
	if level == 'wheel' && wheel#referen#empty ('torus')
		return
	endif
	" First add some locations before leaving empty circle
	if index(['wheel', 'torus'], level) >= 0 && wheel#referen#empty ('circle')
		return
	endif
	" Check if not already in matching file
	if wheel#referen#location_matches_file ()
		return
	endif
	" Follow
	let coordin = wheel#projection#closest (level)
	if ! empty(coordin)
		call wheel#vortex#chord (coordin)
		if g:wheel_config.cd_project > 0
			let markers = g:wheel_config.project_markers
			call wheel#gear#project_root (markers)
		endif
		call wheel#pendulum#record ()
		let info = 'Wheel follows : '
		let info .= coordin[0] . ' > ' . coordin[1] . ' > ' . coordin[2]
		redraw!
		echomsg info
	endif
endfun
