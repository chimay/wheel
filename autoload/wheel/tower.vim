" vim: set ft=vim fdm=indent iskeyword&:

" Menu leaf for mandalas

" script constants

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

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
	" ---- cursor line
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
	" in case of sailing, it's managed by loop#sailing
	if travel
		call wheel#rectangle#previous ()
	endif
	" ---- call function linked to cursor line
	let value = dict[key]
	let winiden = wheel#gear#call (value)
	" ---- coda
	if close
		call wheel#mandala#close ()
		" -- go to last destination
		call wheel#gear#win_gotoid (winiden)
	else
		call wheel#gear#win_gotoid (winiden)
		let new_tab = tabpagenr()
		" -- tab changed, move mandala to new tab
		if elder_tab != new_tab
			" close it in elder tab
			silent call wheel#mandala#close ()
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
	" Menu specific maps
	let map = 'nnoremap <silent> <buffer>'
	let pre = '<cmd>call wheel#tower#menu('
	let post = ')<cr>'
	" Open / Close : default in settings
	exe map '<cr>' pre .. string(settings) .. post
	exe map '<tab>' pre .. string(settings) .. post
	" Leave the mandala Open
	let menu_settings.close = v:false
	exe map 'g<cr>' pre .. string(settings) .. post
	exe map '<space>' pre .. string(settings) .. post
endfun

fun! wheel#tower#staircase (settings)
	" Replace buffer content by a {line -> fun} leaf
	" Define dict maps
	" Used for :
	"   - submenu of meta menu
	"   - context menu leaf
	let settings = a:settings
	let dictname = settings.linefun
	call wheel#book#add ()
	let items = wheel#crystal#fetch (dictname)
	let lines = wheel#matrix#items2keys (items)
	call wheel#mandala#filename (dictname)
	call wheel#mandala#fill (lines, 'blank-first')
	call wheel#tower#mappings (settings)
	let b:wheel_lines = lines
	let b:wheel_settings = settings
	call cursor(1, 1)
	call wheel#book#syncup ()
	call wheel#status#mandala_leaf ()
endfun
