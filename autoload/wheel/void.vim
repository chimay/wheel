" vim: set filetype=vim:

" Enter the void of initialization

fun! wheel#void#init ()
	call wheel#disc#read_all()
	if ! exists('g:wheel')
		echomsg 'Creating empty Wheel.'
		call wheel#void#reset()
	endif
	if ! exists('g:wheel_config')
		echomsg 'Creating empty Wheel config.'
		let g:wheel_config = {}
	else
		echo 'Wheel config / file :' g:wheel_config.file
		echo 'Wheel config / prefix :' g:wheel_config.prefix
		echo 'Wheel config / mappings :' g:wheel_config.mappings
	endif
	echomsg 'Wheel commands.'
	call wheel#centre#commands ()
	echomsg 'Wheel mappings.'
	call wheel#centre#mappings ()
endfu

fun! wheel#void#exit ()
	call wheel#disc#write_all()
endfu

fun! wheel#void#reset ()
	let g:wheel = {}
endfu
