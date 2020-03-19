" vim: set filetype=vim:

" Command, Mappings

fun! wheel#centre#commands ()
	" Define commands
	" Status
	com! WheelDashboard :call wheel#status#dashboard()
	com! WheelPrint :call wheel#status#print()
	" Tree
	com! WheelAddTorus :call wheel#tree#add_torus()
	com! WheelAddCircle :call wheel#tree#add_circle()
	com! WheelAddLocation :call wheel#tree#add_location()
	com! WheelDeleteTorus :call wheel#tree#delete_torus()
	com! WheelDeleteCircle :call wheel#tree#delete_circle()
	com! WheelDeleteLocation :call wheel#tree#delete_location()
	" Vortex
	com! WheelPrevTorus :call wheel#vortex#prev_torus()
	com! WheelNextTorus :call wheel#vortex#next_torus()
	com! WheelPrevCircle :call wheel#vortex#prev_circle()
	com! WheelNextCircle :call wheel#vortex#next_circle()
	com! WheelPrevLocation :call wheel#vortex#prev_location()
	com! WheelNextLocation :call wheel#vortex#next_location()
endfun

fun! wheel#centre#mappings ()
	" Define mappings
	if ! has_key(g:wheel, 'mapping_level')
		let g:wheel_config.mapping = 1
	endif
	if ! has_key(g:wheel, 'prefix')
		let g:wheel_config.prefix = '<D-t>'
	endif
	if g:wheel_config['mapping'] > 0
		exe 'nnoremap ' . g:wheel_config['prefix'] . 'a' ':call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . g:wheel_config['prefix'] . '<c-a>' ':call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config['prefix'] . 'A' ':call wheel#tree#add_torus()<cr>'
	endif
endfun
