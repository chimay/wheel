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
	com! WheelNameLocation :call wheel#tree#name_location()
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
	if ! has_key(g:wheel_config, 'mappings')
		let g:wheel_config.mappings = 1
	endif
	if ! has_key(g:wheel_config, 'prefix')
		let g:wheel_config.prefix = '<D-t>'
	endif
	if g:wheel_config.mappings > 0
		exe 'nnoremap ' . g:wheel_config.prefix . 'a :call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-a> :call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'A :call wheel#tree#add_torus()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<left> :call wheel#vortex#prev_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<right> :call wheel#vortex#next_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-left> :call wheel#vortex#prev_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-right> :call wheel#vortex#next_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<s-left> :call wheel#vortex#prev_torus()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<s-right> :call wheel#vortex#next_torus()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'r :call wheel#disc#read_all()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'w :call wheel#disc#write_all()<cr>'
	endif
	if g:wheel_config.mappings > 1
		exe 'nnoremap ' . g:wheel_config.prefix . 'n :call wheel#tree#rename_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-n> :call wheel#tree#rename_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'N :call wheel#tree#rename_torus()<cr>'
	endif
	if g:wheel_config.mappings > 10
		" Tree
		nnoremap <D-Insert>   :call wheel#tree#add_here()<cr>
		nnoremap <D-Del>      :call wheel#tree#delete_location()<cr>
		" Vortex
		nnoremap <C-PageUp>   :call wheel#vortex#prev_location()<cr>
		nnoremap <C-PageDown> :call wheel#vortex#next_location()<cr>
		nnoremap <C-Home>     :call wheel#vortex#prev_circle()<cr>
		nnoremap <C-End>      :call wheel#vortex#next_circle()<cr>
	endif
endfun
