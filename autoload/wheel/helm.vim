" vim: set ft=vim fdm=indent iskeyword&:

" Helm
"
" Menus

" Script constants

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:menu_list')
	let s:menu_list = wheel#crystal#fetch('menu/list')
	lockvar s:menu_list
endif

" booleans

fun! wheel#helm#is_menu ()
	" Whether mandala leaf is a context menu
	return b:wheel_nature.menu
endfun

" maps

fun! wheel#helm#menu_maps (dictname)
	" Define local maps for menus
	let dictname = 'menu/' .. a:dictname
	let settings = {}
	let settings.menu = #{class : 'menu', linefun : dictname, close : v:false, travel : v:true}
	call wheel#tower#mappings (settings)
	let b:wheel_settings = settings
endfun

fun! wheel#helm#meta_maps (dictname)
	" Define local maps for meta menu
	let dictname = 'menu/' .. a:dictname
	let settings = {}
	let settings.menu = #{class : 'menu/meta', linefun : dictname, close : v:false, travel : v:false}
	call wheel#tower#mappings (settings)
	let b:wheel_settings = settings
	return
endfun

" folding

fun! wheel#helm#folding_options ()
	" Folding options for menu
	setlocal foldenable
	setlocal foldminlines=1
	setlocal foldlevel=0
	setlocal foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
	setlocal foldclose=
	setlocal foldmethod=marker
	let &l:foldmarker = s:fold_markers
	setlocal foldcolumn=2
	setlocal foldtext=wheel#helm#folding_text()
endfun

fun! wheel#helm#folding_text ()
	" Folding text for menu
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	if v:foldlevel == 1
		let level = 'submenu'
	else
		let level = 'none'
	endif
	let marker = s:fold_markers[0]
	let pattern = '\m' .. marker .. '[12]'
	let repl = ':: ' .. level
	let line = substitute(line, pattern, repl, '')
	let text = line .. ' :: ' .. numlines .. ' lines ' .. v:folddashes
	return text
endfun

" menus

fun! wheel#helm#menu (dictname)
	" Menu in mandala buffer
	let dictname = a:dictname
	let string = 'menu/' .. dictname
	call wheel#mandala#blank (string)
	call wheel#mandala#template ()
	" -- class
	let b:wheel_nature.class = 'menu'
	" -- selection property
	let b:wheel_nature.has_selection = v:false
endfun

fun! wheel#helm#submenu (dictname)
	" Submenu
	let dictname = 'menu/' .. a:dictname
	let settings = {}
	let settings.menu = #{class : 'menu/submenu', linefun : dictname, close : v:false, travel : v:true}
	call wheel#tower#staircase (settings)
	" -- class
	let b:wheel_nature.class = 'menu/submenu'
endfun

fun! wheel#helm#main ()
	" Main menu in mandala buffer
	call wheel#helm#menu('main')
	call wheel#helm#menu_maps ('main')
	call wheel#helm#folding_options ()
	let menu = []
	for elem in s:menu_list
		let header = elem .. s:fold_1
		let items = wheel#crystal#fetch('menu/' .. elem)
		let submenu = wheel#matrix#items2keys (items)
		eval menu->add(header)
		call extend(menu, submenu)
	endfor
	call wheel#mandala#fill(menu)
endfun

fun! wheel#helm#meta ()
	" Meta menu in mandala buffer
	call wheel#helm#menu('meta')
	call wheel#helm#meta_maps('meta')
	let items = wheel#crystal#fetch('menu/meta')
	let menu = wheel#matrix#items2keys (items)
	call wheel#mandala#fill(menu)
endfun
