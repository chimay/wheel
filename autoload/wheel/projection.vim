" vim: set ft=vim fdm=indent iskeyword&:

" Find & follow the closest element in wheel

fun! wheel#projection#closest (...)
	" Find closest location to :
	"   - given file & line
	"   - filename & position (default)
	" The search is done in album index
	" Optional arguments :
	"   - level : search in given current level
	"     + wheel : everywhere in the wheel
	"     + torus : in current torus
	"     + circle : in current circle
	"   - file name
	"   - line number
	"   - column number
	if a:0 > 0
		let level = a:1
	else
		let level = 'wheel'
	endif
	if a:0 > 1
		let filename = a:2
	else
		let filename = expand('%:p')
	endif
	if a:0 > 2
		let linum = a:3
	else
		let linum = line('.')
	endif
	if a:0 > 3
		let colnum = a:4
	else
		let colnum = col('.')
	endif
	" no global var, should be fine without deepcopy
	let album = wheel#helix#album ()
	call filter(album, {_,value -> value[2].file ==# filename})
	" narrow down to current level
	let narrow = wheel#referen#coordin_index(level)
	if narrow >= 0
		let narrow_names = wheel#referen#names()
		for index in range(0, narrow)
			call filter(album, {_,value -> value[index] == narrow_names[index]})
		endfor
	endif
	if empty(album)
		return []
	endif
	" min diff lines
	let lines = map(deepcopy(album), {_, val -> val[2].line})
	let diff = map(copy(lines), {_, val -> abs(val - linum)})
	let where = wheel#chain#argmin (diff)
	let album = wheel#chain#indexes (album, where)
	" min diff columns
	let cols = map(deepcopy(album), {_, val -> val[2].col})
	let diff = map(copy(cols), {_, val -> abs(val - colnum)})
	let where = wheel#chain#argmin (diff)
	let album = wheel#chain#indexes (album, where)
	" closest
	let closest = album[0]
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
	" if torus or circle is empty, assume the user
	" wants to add something before switching
	if level == 'wheel' && wheel#referen#empty ('torus')
		return
	endif
	" first add some locations before leaving empty circle
	if wheel#chain#is_inside(level, ['wheel', 'torus']) && wheel#referen#empty ('circle')
		return
	endif
	" follow
	let coordin = wheel#projection#closest (level)
	if ! empty(coordin) && coordin != wheel#referen#names()
		call wheel#vortex#chord (coordin)
		if g:wheel_config.cd_project > 0
			let markers = g:wheel_config.project_markers
			call wheel#gear#project_root (markers)
		endif
		call wheel#pendulum#record ()
		let info = 'wheel follows : '
		let info ..= coordin[0] .. ' > ' .. coordin[1] .. ' > ' .. coordin[2]
		redraw!
		echomsg info
	endif
endfun
