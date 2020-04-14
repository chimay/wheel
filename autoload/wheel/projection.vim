" vim: ft=vim fdm=indent:


fun! wheel#projection#closest ()
	" Find closest location to current buffer & position
	" The search is done in g:wheel_album
	let album = deepcopy(g:wheel_album)
	if empty(album)
		return []
	endif
	let cur_file = expand('%:p')
	call filter(album, {_,value -> value[2].file == cur_file})
	return album
	if empty(locations)
		return [-1, {}]
	endif
	let cur_line = line('.')
	let lines = map(deepcopy(locations), {_,val -> val.line})
	let deltas = map(deepcopy(locations), {_,val -> abs(val.line - cur_line)})
	let minim = min(deltas)
	let where = index(deltas, minim)
	let minline = lines[where]
	let closest = filter(locations, {_,value -> value.line == minline})[0]
	let index = index(circle.locations, closest)
	return [index, closest]
endfun

fun! wheel#projection#follow ()
	" Try to set current location to match current file
	" Search for current file in current circle
	let cur_file = expand('%:p')
	let cur_location = wheel#referen#location()
	if empty(cur_location)
		return
	endif
	let cur_loc_file = cur_location.file
	if cur_file ==# cur_loc_file
		return
	endif
	let [index, location] = wheel#projection#closest ()
	if index < 0
		return
	endif
	let circle = wheel#referen#circle ()
	let circle.current = index
	let position = getcurpos()
	call wheel#projection#jump ()
	call setpos('.', position)
	redraw!
	echomsg 'Wheel follows :' string(location)
endfun

