" vim: set ft=vim fdm=indent iskeyword&:

" Kintsugi
"
" Check & fix
"
" Kintsugi is a traditional japanese art
" that fixes a broken object by highlighting the joins.
" The damages are considered a part of the object history

" ---- script constants

if exists('s:mandala_vars')
	unlockvar s:mandala_vars
endif
let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
lockvar s:mandala_vars

" ---- checks

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

" ---- display

fun! wheel#kintsugi#mandala_vars ()
	" Display mandala vars
	for varname in s:mandala_vars
		echomsg varname ': ' string({varname})
	endfor
endfun

" ---- conversion from old data structure

fun! wheel#kintsugi#pre ()
	" Convert old keys to new ones, called before config init
	" Run in void foundation, before vars initialization
	if ! exists('g:wheel_config')
		return v:false
	endif
	" ---- chdir project
	if has_key(g:wheel_config, 'cd_project')
		let g:wheel_config.project.auto_chdir = g:wheel_config.cd_project
		unlet g:wheel_config.cd_project
		let info = 'wheel config : cd_project is deprecated. '
		let info ..= 'Please use project.auto_chdir instead.'
		echomsg info
	endif
	" ---- default_yanks, other_yanks
	if has_key(g:wheel_config.maxim, 'yanks')
		let max_yanks = g:wheel_config.maxim.yanks
		let g:wheel_config.maxim.unnamed_yanks = max_yanks
		let g:wheel_config.maxim.other_yanks = float2nr(round(max_yanks/10))
		unlet g:wheel_config.maxim.yanks
		let info = 'wheel config : maxim.yanks is deprecated. '
		let info ..= 'Please use maxim.unnamed_yanks and maxim.other_yanks instead.'
		echomsg info
	endif
	if has_key(g:wheel_config.maxim, 'default_yanks')
		let max_yanks = g:wheel_config.maxim.default_yanks
		let g:wheel_config.maxim.unnamed_yanks = max_yanks
		unlet g:wheel_config.maxim.default_yanks
		let info = 'wheel config : maxim.default_yanks is deprecated. '
		let info ..= 'Please use maxim.unnamed_yanks instead.'
		echomsg info
	endif
	" ---- display message -> display dedibuf_msg
	if has_key(g:wheel_config.display, 'message')
		let g:wheel_config.display.dedibuf_msg = g:wheel_config.display.message
		unlet g:wheel_config.display.message
		let info = 'wheel config : display.message is deprecated. '
		let info ..= 'Please use display.dedibuf_msg instead.'
		echomsg info
	endif
	if has_key(g:wheel_config.display, 'dedibuf')
		let g:wheel_config.display.dedibuf_msg = g:wheel_config.display.dedibuf
		unlet g:wheel_config.display.dedibuf
		let info = 'wheel config : display.dedibuf is deprecated. '
		let info ..= 'Please use display.dedibuf_msg instead.'
		echomsg info
	endif
	" ---- coda
	return v:true
endfun

fun! wheel#kintsugi#post ()
	" Convert old keys to new ones, called after config init
	" -- project
	if has_key(g:wheel_config, 'project_markers')
		let g:wheel_config.project.markers = g:wheel_config.project_markers
		unlet g:wheel_config.project_markers
		let info = 'wheel config : project_markers is deprecated. '
		let info ..= 'Please use project.markers instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'auto_chdir_project')
		let g:wheel_config.project.auto_chdir = g:wheel_config.auto_chdir_project
		unlet g:wheel_config.project.auto_chdir_project
		let info = 'wheel config : auto_chdir_project is deprecated. '
		let info ..= 'Please use project.auto_chdir instead.'
		echomsg info
	endif
	" ---- storage
	" -- wheel
	if has_key(g:wheel_config, 'file')
		let path = g:wheel_config.file
		let g:wheel_config.storage.wheel.folder = fnamemodify(path, ':h')
		let g:wheel_config.storage.wheel.name = fnamemodify(path, ':t')
		unlet g:wheel_config.file
		let info = 'wheel config : file is deprecated. '
		let info ..= 'Please use storage.wheel.name instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'autoread')
		let g:wheel_config.storage.wheel.autoread = g:wheel_config.autoread
		unlet g:wheel_config.autoread
		let info = 'wheel config : autoread is deprecated. '
		let info ..= 'Please use storage.wheel.autoread instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'autowrite')
		let g:wheel_config.storage.wheel.autowrite = g:wheel_config.autowrite
		unlet g:wheel_config.autowrite
		let info = 'wheel config : autowrite is deprecated. '
		let info ..= 'Please use storage.wheel.autowrite instead.'
		echomsg info
	endif
	" -- session
	if has_key(g:wheel_config, 'session_file')
		let path = g:wheel_config.session_file
		let g:wheel_config.storage.session.folder = fnamemodify(path, ':h')
		let g:wheel_config.storage.session.name = fnamemodify(path, ':t')
		unlet g:wheel_config.session_file
		let info = 'wheel config : session_file is deprecated. '
		let info ..= 'Please use storage.session.name instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'session_dir')
		let g:wheel_config.storage.session.folder = g:wheel_config.session_dir
		unlet g:wheel_config.session_dir
		let info = 'wheel config : session_dir is deprecated. '
		let info ..= 'Please use storage.session.folder instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'autoread_session')
		let g:wheel_config.storage.session.autoread = g:wheel_config.autoread_session
		unlet g:wheel_config.autoread_session
		let info = 'wheel config : autoread_session is deprecated. '
		let info ..= 'Please use storage.session.autoread instead.'
		echomsg info
	endif
	if has_key(g:wheel_config, 'autowrite_session')
		let g:wheel_config.storage.session.autowrite = g:wheel_config.autowrite_session
		unlet g:wheel_config.autowrite_session
		let info = 'wheel config : autowrite_session is deprecated. '
		let info ..= 'Please use storage.session.autowrite instead.'
		echomsg info
	endif
	" -- backups
	if has_key(g:wheel_config, 'backups')
		let g:wheel_config.storage.backups = g:wheel_config.backups
		unlet g:wheel_config.backups
		let info = 'wheel config : backups is deprecated. '
		let info ..= 'Please use storage.backups instead.'
		echomsg info
	endif
	" ---- shelve session_file
	if has_key(g:wheel_shelve, 'session_file')
		let g:wheel_shelve.current.session = g:wheel_shelve.session_file
		unlet g:wheel_shelve.session_file
	endif
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
			let new_history.alternate = g:wheel_alternate
		else
			let new_history.circuit = g:wheel_history
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
		let new_yank.unnamed = g:wheel_yank
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
	if ! has_key(g:wheel_yank, 'unnamed')
		let g:wheel_yank.unnamed = g:wheel_yank.default
		unlet g:wheel_yank.default
	endif
	if ! has_key(g:wheel_shelve, 'yank')
		let g:wheel_shelve.yank = {}
	endif
	if ! has_key(g:wheel_shelve.yank, 'default_register')
		let g:wheel_shelve.yank.default_register = 'unnamed'
	endif
	" ---- coda
	return v:true
endfun
