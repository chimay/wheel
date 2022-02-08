" vim: set ft=vim fdm=indent iskeyword&:

" Kintsugi
"
" Check & fix
"
" Kintsugi is a traditional japanese art
" that fixes a broken object by highlighting the joins.
" The damages are considered a part of the object history

" script constants

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

" checks

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

" display

fun! wheel#kintsugi#mandala_vars ()
	" Display mandala vars
	for varname in s:mandala_vars
		echomsg varname ': ' string({varname})
	endfor
endfun

" conversion from old data structure

fun! wheel#kintsugi#config ()
	" Convert old config keys to new ones
	" Run in void foundation, before vars initialization
	if ! exists('g:wheel_config')
		return v:false
	endif
	" ---- chdir project
	if has_key(g:wheel_config, 'cd_project')
		if ! has_key(g:wheel_config, 'auto_chdir_project')
			let g:wheel_config.auto_chdir_project = g:wheel_config.cd_project
			unlet g:wheel_config.cd_project
			let info = 'wheel config : cd_project is deprecated. '
			let info ..= 'Please use auto_chdir_project instead.'
			echomsg info
		endif
	endif
	" ---- default_yanks, other_yanks
	if has_key(g:wheel_config.maxim, 'yanks')
		if ! has_key(g:wheel_config, 'default_yanks')
			let max_yanks = g:wheel_config.maxim.yanks
			let g:wheel_config.maxim.default_yanks = max_yanks
			let g:wheel_config.maxim.other_yanks = float2nr(round(max_yanks/10))
			unlet g:wheel_config.maxim.yanks
			let info = 'wheel config : maxim.yanks is deprecated. '
			let info ..= 'Please use maxim.default_yanks and maxim.other_yanks instead.'
			echomsg info
		endif
	endif
	" ---- coda
	return v:true
endfun

fun! wheel#kintsugi#wheel_file ()
	" Convert old data structure to new one
	" Run in read / write wheel file
	" ---- history
	if type(g:wheel_history) == v:t_list
		let new_history = {}
		let new_history.line = g:wheel_history
		if exists('g:wheel_track')
			let new_history.circuit = g:wheel_track
		else
			let new_history.circuit = g:wheel_history
		endif
		if exists('g:wheel_track')
			let new_history.alternate = g:wheel_alternate
		else
			let new_history.alternate = {}
		endif
		let g:wheel_history = new_history
		unlet g:wheel_track
		unlet g:wheel_alternate
	endif
	if ! has_key(g:wheel_history, 'frecency')
		let g:wheel_history.frecency = []
	endif
	" ---- yank
	if type(g:wheel_yank) == v:t_list
		let new_yank = {}
		let new_yank.default = g:wheel_yank
		let new_yank.clipboard = []
		let new_yank.primary = []
		let new_yank.small = []
		let new_yank.inserted = []
		let new_yank.search = []
		let new_yank.command = []
		let new_yank.expression = []
		let new_yank.file = []
		let new_yank.alternate = []
		let g:wheel_yank = new_yank
	endif
	" ---- coda
	return v:true
endfun
