" vim: ft=vim fdm=indent:

" Enter the void, and become wheel

fun! wheel#void#minimum ()
	if ! exists('g:wheel')
		let g:wheel = {}
	endif
	if ! exists('g:wheel_history')
		let g:wheel_history = {}
	endif
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
		let g:wheel_config.prefix = '<D-t>'
	endif
	if ! has_key(g:wheel_config, 'backups')
		let g:wheel_config.backups = 3
	endif
	if ! has_key(g:wheel_config, 'cd_project')
		let g:wheel_config.cd_project = 3
	endif
	if ! has_key(g:wheel_config, 'project_marker')
		let g:wheel_config.project_marker = '.git'
	endif
endfu

fun! wheel#void#template(name)
	" Generate template to add to g:wheel lists
	let template = {}
	let template.name = a:name
	return template
endfun

fun! wheel#void#init ()
	if g:wheel_config.autoread > 0
		call wheel#disc#read_all ()
	endif
	call wheel#void#minimum ()
	call wheel#centre#commands ()
	call wheel#centre#mappings ()
	call wheel#vortex#jump ()
endfu

fun! wheel#void#exit ()
	if g:wheel_config.autowrite > 0
		call wheel#disc#write_all()
	endif
endfu
