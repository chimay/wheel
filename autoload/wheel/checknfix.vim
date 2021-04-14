" vim: ft=vim fdm=indent:

" Check & fix

" Script vars

if ! exists('s:layer_stack_fields')
	let s:layer_stack_fields = wheel#crystal#fetch('layer/stack/fields')
	lockvar s:layer_stack_fields
endif

" Checkers

fun! wheel#checknfix#glossaries ()
	" Check & fix glossaries in wheel & current torus & circle
	" Names in toruses, circles and locations are considered to be the right ones
	let success = 1
	let coordin = wheel#referen#circle('all')
	let cur_torus    = coordin[0]
	let cur_circle   = coordin[1]
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
				echomsg 'Error in check glossaries : wheel glossary is too short.'
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
				echomsg 'Error in check glossaries : torus glossary is too short.'
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
				echomsg 'Error in check glossaries : circle glossary is too short.'
				break
			endif
		endif
		let ind += 1
	endwhile
	" Return
	return success
endfun

fun! wheel#checknfix#history ()
" Check history
	let success = 1
	let history = deepcopy(g:wheel_history)
	let helix = wheel#helix#helix()
	let ind = 0
	let length = len(history)
	while ind < length
		let coordin = history[ind].coordin
		if index(helix, coordin) < 0
			let success = 0
			echomsg 'Removing [' join(coordin, ', ') '] from history.'
			call wheel#chain#remove_element(history[ind], g:wheel_history)
		endif
		let ind += 1
	endwhile
	return success
endfun

fun! wheel#checknfix#layer_stack ()
	" Check b:wheel_stack in mandalas
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	if top < length
		echomsg 'top' string(top) '<' 'length' string(length) 'ok'
	else
		echomsg 'bad top' string(top) '>' 'length' string(length)
	endif
	echomsg 'layer stack length = ' string(length)
	for field in s:layer_stack_fields
		let same = len(b:wheel_stack[field])
		if same == length
			echomsg 'length' field '=' same 'ok'
		else
			echomsg 'wheel layer stack : bad' field 'length =' string(same) '/ stack length :' string(length)
		endif
	endfor
endfun
