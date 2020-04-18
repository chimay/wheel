" vim: ft=vim fdm=indent:

" Menus

" Maps

fun! wheel#hub#maps (dictname)
	" Define local menu maps
	let varname = 'menu/' . a:dictname
	let conf = {'menu' : varname, 'close' : 1, 'travel' : 1}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#layer#call('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(conf) . post
	let conf.close = 0
	exe map . 'g<cr>' . pre . string(conf) . post
endfun

fun! wheel#hub#meta_maps (dictname)
	" Define local meta maps
	let varname = 'menu/' . a:dictname
	let conf = {'menu' : varname, 'close' : 0, 'travel' : 0}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#layer#call('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(conf) . post
endfun

" Menus

fun! wheel#hub#menu (dictname)
	" Menu in wheel buffer
	let dictname = a:dictname
	let string = 'wheel-menu-' . dictname
	call wheel#mandala#open (string)
	call wheel#mandala#template ()
	let dict = wheel#storage#fetch('menu/' . dictname)
	let menu = sort(keys(dict))
	call wheel#mandala#fill(menu)
endfun

fun! wheel#hub#submenu (dictname)
	" Submenu
	let dictname = a:dictname
	call wheel#layer#staircase ('menu/' . dictname)
endfun

fun! wheel#hub#main ()
	" Main hub menu in wheel buffer
	call wheel#hub#menu('main')
	call wheel#hub#maps('main')
endfun

fun! wheel#hub#meta ()
	" Meta hub menu in wheel buffer
	call wheel#hub#menu('meta')
	call wheel#hub#meta_maps('meta')
endfun
