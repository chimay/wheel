" vim: ft=vim fdm=indent:

" Menus

fun! wheel#hub#menu_maps (dictname)
	" Define local maps for menus
	let dictname = 'menu/' . a:dictname
	let settings = {'menu' : dictname, 'close' : 1, 'travel' : 1, 'deselect' : 1}
	call wheel#layer#overlay (settings)
	let b:wheel_settings = settings
endfun

fun! wheel#hub#meta_maps (dictname)
	" Define local maps for meta menu
	let dictname = 'menu/' . a:dictname
	let settings = {'menu' : dictname, 'close' : 0, 'travel' : 0, 'deselect' : 1}
	call wheel#layer#overlay (settings)
	let b:wheel_settings = settings
	return
endfun

fun! wheel#hub#menu (dictname)
	" Menu in wheel buffer
	let dictname = a:dictname
	let string = 'wheel-menu-' . dictname
	call wheel#mandala#open (string)
	call wheel#mandala#template ()
	let dict = wheel#crystal#fetch('menu/' . dictname)
	let menu = sort(keys(dict))
	call wheel#mandala#fill(menu)
endfun

fun! wheel#hub#submenu (dictname)
	" Submenu
	let dictname = 'menu/' . a:dictname
	let settings = {'menu' : dictname, 'close' : 1, 'travel' : 1, 'deselect' : 1}
	call wheel#layer#staircase (settings)
endfun

fun! wheel#hub#main ()
	" Main hub menu in wheel buffer
	call wheel#hub#menu('main')
	call wheel#hub#menu_maps ('main')
	nunmap <buffer> <space>
endfun

fun! wheel#hub#meta ()
	" Meta hub menu in wheel buffer
	call wheel#hub#menu('meta')
	call wheel#hub#meta_maps('meta')
endfun
