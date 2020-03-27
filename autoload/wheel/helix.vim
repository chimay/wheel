" vim: ft=vim fdm=indent:

" Indexes

fun! wheel#helix#helix ()
	" Index of locations coordinates in the wheel
	" Each coordinate = [torus, circle, location]
	if g:wheel.timestamp >= g:wheel_helix.timestamp
		let helix = []
		for torus in g:wheel.toruses
			for circle in torus.circles
				for location in circle.locations
					let coordin = [torus.name, circle.name, location.name]
					let helix = add(helix, coordin)
				endfor
			endfor
		endfor
		let g:wheel_helix.table = helix
		let g:wheel_helix.timestamp = wheel#pendulum#timestamp()
	else
		let helix = g:wheel_helix.table
	endif
	return helix
endfu

fun! wheel#helix#grid ()
	" Index of circles coordinates in the wheel
	" Each coordinate = [torus, circle]
	if g:wheel.timestamp >= g:wheel_grid.timestamp
		let grid = []
		for torus in g:wheel.toruses
			for circle in torus.circles
				let coordin = [torus.name, circle.name]
				let grid = add(grid, coordin)
			endfor
		endfor
		let g:wheel_grid.table = grid
		let g:wheel_grid.timestamp = wheel#pendulum#timestamp()
	else
		let grid = g:wheel_grid.table
	endif
	return grid
endfu

fun! wheel#helix#files ()
	" Index of files in the wheel
	if g:wheel.timestamp >= g:wheel_files.timestamp
		let files = []
		for torus in g:wheel.toruses
			for circle in torus.circles
				for location in circle.locations
					let filename = location.file
					let helix = add(files, filename)
				endfor
			endfor
		endfor
		let g:wheel_files.table = files
		let g:wheel_files.timestamp = wheel#pendulum#timestamp()
	else
		let files = g:wheel_files.table
	endif
	return files
endfu

fun! wheel#helix#locations ()
	" Index of locations coordinates in the wheel
	" Each coordinate is a string torus >> circle > location
	let helix = wheel#helix#helix ()
	let strings = []
	for coordin in helix
		let entry = coordin[0] . ' >> ' . coordin[1] . ' > ' . coordin[2]
		let strings = add(strings, entry)
	endfor
	return strings
endfu

fun! wheel#helix#circles ()
	" Index of circles coordinates in the wheel
	" Each coordinate is a string torus >> circle
	let grid = wheel#helix#grid ()
	let strings = []
	for coordin in grid
		let entry = coordin[0] . ' >> ' . coordin[1]
		let strings = add(strings, entry)
	endfor
	return strings
endfu
