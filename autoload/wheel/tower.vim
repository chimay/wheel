" vim: set ft=vim fdm=indent iskeyword&:

" Tower
"
" Menu leaf for mandalas

" functions

fun! wheel#tower#menu (settings)
	" Calls function given by the key = cursor line
	" settings is a dictionary containing settings.menu
	" settings.menu keys can be :
	" - linefun : name of a dictionary variable in storage.vim
	" - travel : whether to go back to pre-mandala window before applying action
	" - close : whether to close mandala buffer
	let settings = a:settings
	let menu_settings = settings.menu
	let dict = wheel#crystal#fetch (menu_settings.linefun, 'dict')
	let travel = menu_settings.travel
	let close = menu_settings.close
	" ---- pre checks
	let cursor_line = getline('.')
	if empty(cursor_line)
		echomsg 'wheel line menu : you selected an empty line'
		return v:false
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		echomsg 'wheel line menu : key not found'
		return v:false
	endif
	" ---- tab page of mandala before processing
	let elder_tab = tabpagenr()
	" ---- travel before processing ?
	" true for helm menus
	" false for context menus
	" in case of navigation, it's managed by loop#selection
	if travel
		call wheel#rectangle#previous ()
	endif
	" ---- call function linked to cursor line
	let function = dict[key]
	let winiden = wheel#gear#call (function)
	" ---- coda
	if close
		call wheel#cylinder#close ()
		" -- go to last destination
		call wheel#gear#win_gotoid (winiden)
	else
		call wheel#gear#win_gotoid (winiden)
		let new_tab = tabpagenr()
		" -- tab changed, move mandala to new tab
		if elder_tab != new_tab
			" go back in new tab
			execute 'tabnext' new_tab
		endif
		call wheel#cylinder#recall()
	endif
	return v:true
endfun

fun! wheel#tower#mappings (settings)
	" Define maps
	let settings = deepcopy(a:settings)
	let menu_settings = settings.menu
	call wheel#mandala#template ()
	" ---- menu specific maps
	let map = 'nnoremap <silent> <buffer>'
	let linefun = '<cmd>call wheel#tower#menu('
	let coda = ')<cr>'
	" ---- open / close : default in settings
	exe map '<cr>' linefun .. string(settings) .. coda
	" ---- leave the mandala opened
	let menu_settings.close = v:false
	exe map 'g<cr>'   linefun .. string(settings) .. coda
	exe map '<tab>'   linefun .. string(settings) .. coda
	exe map '<space>' linefun .. string(settings) .. coda
endfun

fun! wheel#tower#staircase (settings)
	" Replace buffer content by a {line -> fun} leaf
	" Define dict maps
	" Used for :
	"   - submenu of meta menu
	"   - context menu leaf
	let settings = deepcopy(a:settings)
	let dictname = settings.menu.linefun
	" ---- blank mandala
	call wheel#mandala#blank (dictname)
	call wheel#mandala#template ()
	" ---- properties
	let b:wheel_nature.class = settings.menu.class
	let b:wheel_nature.has_filter = v:true
	let b:wheel_nature.has_selection = v:false
	" ---- fill with dict keys
	let items = wheel#crystal#fetch (dictname)
	let lines = wheel#matrix#items2keys (items)
	call wheel#mandala#fill (lines)
	" ---- save settings
	let b:wheel_settings = settings
	" ---- mappings
	call wheel#tower#mappings (settings)
endfun
