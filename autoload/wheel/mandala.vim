" vim: set filetype=vim:

" Centre of command

fun! wheel#mandala#print ()
	echo g:wheel
endfu

fun! wheel#mandala#dashboard ()
	let chaine = ''
	if has_key(g:wheel, 'toruses') && len(g:wheel.toruses) > 0
		let cur_torus = g:wheel.toruses[g:wheel.current]
		let chaine .= cur_torus.name . ' >> '
		if has_key(cur_torus, 'circles') && len(cur_torus.circles) > 0
			let cur_circle = cur_torus.circles[cur_torus.current]
			let chaine .= cur_circle.name . ' > '
			if has_key(cur_circle, 'locations') && len(cur_circle.locations) > 0
				let cur_location = cur_circle.locations[cur_circle.current]
				if has_key(cur_location, 'name')
					let chaine .= cur_location.name ' = '
				endif
				let chaine .= cur_location.file . ':' . cur_location.line . ':' . cur_location.col
			endif
		endif
	endif
	echomsg chaine
endfun
