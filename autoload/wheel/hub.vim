" vim: ft=vim fdm=indent:

" Menus

" Helpers

fun! wheel#hub#call (conf)
	" Calls function corresponding to menu line
	let conf = a:conf
	let menu = wheel#storage#fetch ('menu/' . conf.menu)
	let key = getline('.')
	if conf.close
		call wheel#mandala#close ()
	elseif conf.travel
		let mandala = win_getid()
		wincmd p
	endif
	let value = menu[key]
	if value =~ '\m)'
		exe 'call ' . value
	else
		call {value}()
	endif
	if ! conf.close && conf.travel
		call win_gotoid(mandala)
	endif
endfun

fun! wheel#hub#maps (dictname)
	" Define local menu maps
	let conf = {'menu' : a:dictname, 'close' : 1, 'travel' : 1}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#hub#call('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(conf) . post
	let conf.close = 0
	exe map . 'g<cr>' . pre . string(conf) . post
endfun

fun! wheel#hub#meta_maps (dictname)
	" Define local meta maps
	let conf = {'menu' : a:dictname, 'close' : 0, 'travel' : 0}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#hub#call('
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
