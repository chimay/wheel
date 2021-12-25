" vim: set ft=vim fdm=indent iskeyword&:

" Indexes

fun! wheel#helix#album ()
	" Full index of toruses, circles & locations in the wheel
	" Each entry = [torus.name, circle.name, location]
	" Not worth caching it : updated too often,
	" each time a line or col is changed in a location
	let album = []
	for torus in g:wheel.toruses
		for circle in torus.circles
			for location in circle.locations
				let entry = [torus.name, circle.name, location]
				let album = add(album, entry)
			endfor
		endfor
	endfor
	return album
endfu

fun! wheel#helix#helix ()
	" Index of locations coordinates in the wheel
	" Each coordinate = [torus.name, circle.name, location.name]
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
	" Each coordinate = [torus.name, circle.name]
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
					let files = add(files, filename)
				endfor
			endfor
		endfor
		let files = uniq(sort(files))
		let g:wheel_files.table = files
		let g:wheel_files.timestamp = wheel#pendulum#timestamp()
	else
		let files = g:wheel_files.table
	endif
	return files
endfu

fun! wheel#helix#rename_file(old, new)
	" Rename all occurences old -> new filename
	let old = a:old
	let new = a:new
	let files = g:wheel_files.table
	for index in range(len(files))
		if files[index] ==# old
			let files[index] = new
		endif
	endfor
	let g:wheel_files.timestamp = wheel#pendulum#timestamp()
endfun
