" vim: ft=vim fdm=indent:

" Enter the void, and become wheel

fun! wheel#void#template(name, ...)
	" Generate template to add to g:wheel lists
	" Name = name in argument
	" Optional arguments : keys initialized as empty list
	let template = {}
	let template.name = a:name
	let template.glossary = []
	let template.current = -1
	if a:0 > 0
		for key in a:000
			let template[key] = []
		endfor
	endif
	return template
endfun

fun! wheel#void#foundation ()
	" Initialize wheel variables
	" Wheel
	if ! exists('g:wheel')
		let g:wheel = {}
	endif
	if ! has_key(g:wheel, 'toruses')
		let g:wheel.toruses = []
	endif
	if ! has_key(g:wheel, 'glossary')
		let g:wheel.glossary = []
	endif
	if ! has_key(g:wheel, 'current')
		let g:wheel.current = -1
	endif
	if ! has_key(g:wheel, 'timestamp')
		let g:wheel.timestamp = -1
	endif
	" Helix : index of locations
	if ! exists('g:wheel_helix')
		let g:wheel_helix = {}
	endif
	if ! has_key(g:wheel_helix, 'table')
		let g:wheel_helix.table = []
	endif
	if ! has_key(g:wheel_helix, 'timestamp')
		let g:wheel_helix.timestamp = -1
	endif
	" Grid : index of circles
	if ! exists('g:wheel_grid')
		let g:wheel_grid = {}
	endif
	if ! has_key(g:wheel_grid, 'table')
		let g:wheel_grid.table = []
	endif
	if ! has_key(g:wheel_grid, 'timestamp')
		let g:wheel_grid.timestamp = -1
	endif
	" Files in wheel
	if ! exists('g:wheel_files')
		let g:wheel_files = {}
	endif
	if ! has_key(g:wheel_files, 'table')
		let g:wheel_files.table = []
	endif
	if ! has_key(g:wheel_files, 'timestamp')
		let g:wheel_files.timestamp = -1
	endif
	" History
	if ! exists('g:wheel_history')
		let g:wheel_history = []
	endif
	" Menu content
	if ! exists('g:wheel_mandala')
		let g:wheel_mandala = []
	endif
	" Config
	if ! exists('g:wheel_config')
		let g:wheel_config = {}
	endif
	if ! has_key(g:wheel_config, 'autowrite')
		let g:wheel_config.autowrite = 0
	endif
	if ! has_key(g:wheel_config, 'autoread')
		let g:wheel_config.autoread = 0
	endif
	if ! has_key(g:wheel_config, 'mappings')
		let g:wheel_config.mappings = 1
	endif
	if ! has_key(g:wheel_config, 'prefix')
		let g:wheel_config.prefix = '<D-w>'
	endif
	if ! has_key(g:wheel_config, 'backups')
		let g:wheel_config.backups = 3
	endif
	if ! has_key(g:wheel_config, 'cd_project')
		let g:wheel_config.cd_project = 3
	endif
	if ! has_key(g:wheel_config, 'project_markers')
		let g:wheel_config.project_markers = '.git'
	endif
	if ! has_key(g:wheel_config, 'max_history')
		let g:wheel_config.max_history = 50
	endif
	if ! has_key(g:wheel_config, 'debug')
		let g:wheel_config.debug = 0
	endif
endfu

fun! wheel#void#init ()
	echomsg 'Wheel hello !'
	call wheel#void#foundation ()
	if g:wheel_config.autoread > 0
		call wheel#disc#read_all ()
	endif
	call wheel#centre#commands ()
	call wheel#centre#mappings ()
endfu

fun! wheel#void#exit ()
	echomsg 'Wheel bye !'
	if g:wheel_config.autowrite > 0
		call wheel#disc#write_all()
	endif
endfu
