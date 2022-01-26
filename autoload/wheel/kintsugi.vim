" vim: set ft=vim fdm=indent iskeyword&:

" Check & fix
"
" Kintsugi is a traditional japanese art that fixes
" a broken object by highlighting the damages

" Script constants

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

" Functions

fun! wheel#kintsugi#glossaries ()
	" Check & fix glossaries in wheel & current torus & circle
	" Names in toruses, circles and locations are considered to be the right ones
	let success = 1
	let coordin = wheel#referen#circle('all')
	let cur_torus = coordin[0]
	let cur_circle = coordin[1]
	" Wheel glossary
	echomsg 'Checking wheel glossary'
	let ind = 0
	let length = len(g:wheel.toruses)
	let glossary = g:wheel.glossary
	while ind < length
		let torus = g:wheel.toruses[ind]
		if torus.name != glossary[ind]
			let success = 0
			if ind < len(glossary)
				echomsg 'Fixing' glossary[ind] '->' torus.name
				let glossary[ind] = torus.name
			elseif ind == len(glossary)
				echomsg 'Adding' torus.name
				let glossary = add(glossary, torus.name)
			else
				echomsg 'Error in check glossaries : wheel glossary is too short'
				break
			endif
		endif
		let ind += 1
	endwhile
	" Torus glossary
	echomsg 'Checking torus glossary'
	let ind = 0
	let length = len(cur_torus.circles)
	let glossary = cur_torus.glossary
	while ind < length
		let circle = cur_torus.circles[ind]
		if circle.name != glossary[ind]
			let success = 0
			if ind < len(glossary)
				echomsg 'Fixing' glossary[ind] '->' circle.name
				let glossary[ind] = circle.name
			elseif ind == len(glossary)
				echomsg 'Adding' circle.name
				let glossary = add(glossary, circle.name)
			else
				echomsg 'Error in check glossaries : torus glossary is too short'
				break
			endif
		endif
		let ind += 1
	endwhile
	" Circle glossary
	echomsg 'Checking circle glossary'
	let ind = 0
	let length = len(cur_circle.locations)
	let glossary = cur_circle.glossary
	while ind < length
		let location = cur_circle.locations[ind]
		if location.name != glossary[ind]
			let success = 0
			if ind < len(glossary)
				echomsg 'Fixing' glossary[ind] '->' location.name
				let glossary[ind] = location.name
			elseif ind == len(glossary)
				echomsg 'Adding' location.name
				let glossary = add(glossary, location.name)
			else
				echomsg 'Error in check glossaries : circle glossary is too short'
				break
			endif
		endif
		let ind += 1
	endwhile
	" Return
	return success
endfun

fun! wheel#kintsugi#mandala_vars ()
	" Display mandala vars
	for varname in s:mandala_vars
		echomsg varname ': ' string({varname})
	endfor
endfun
