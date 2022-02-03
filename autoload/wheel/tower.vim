" vim: set ft=vim fdm=indent iskeyword&:

" Tower
"
" Menu leaf for mandalas

" script constants

if ! exists('s:nav_fun_patterns')
	let s:nav_fun_patterns = wheel#crystal#fetch('function/pattern/navigation')
	lockvar s:nav_fun_patterns
endif

if ! exists('s:mandala_fun_patterns')
	let s:mandala_fun_patterns = wheel#crystal#fetch('function/pattern/mandala')
	lockvar s:mandala_fun_patterns
endif

" booleans

fun! wheel#tower#is_navigation (function)
	" Whether function is a navigation one
	let function = a:function
	for pattern in s:nav_fun_patterns
		if function =~ pattern
			return v:true
		endif
	endfor
	return v:false
endfun

fun! wheel#tower#uses_mandala (function)
	" Whether function uses a mandala
	let function = a:function
	for pattern in s:mandala_fun_patterns
		if function =~ pattern
			return v:true
		endif
	endfor
	return v:false
endfun

" functions

fun! wheel#tower#action (settings)
	" Calls function given by the key = cursor line
	" settings is a dictionary containing settings.menu
	" settings.menu keys can be :
	" - linefun : name of a dictionary variable in storage.vim
	" - close : whether to close mandala buffer
	let settings = a:settings
	let menu_settings = settings.menu
	let dict = wheel#crystal#fetch (menu_settings.linefun, 'dict')
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
	" ---- function to use
	let function = dict[key]
	" ---- tab page of mandala before processing
	let elder_tab = tabpagenr()
	" ---- navigation functions needs to be on the previous, regular window
	if wheel#tower#is_navigation (function)
		call wheel#rectangle#previous ()
	endif
	" --- if functions needs a mandala, overrides the close setting
	if wheel#tower#uses_mandala (function)
		let close = v:false
	endif
	" ---- call function linked to cursor line
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
	let linefun = '<cmd>call wheel#tower#action('
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
	"   - meta menu & submenus
	"   - context menu leaf
	let settings = deepcopy(a:settings)
	let dictname = settings.menu.linefun
	" ---- blank mandala
	call wheel#mandala#blank (dictname)
	" ---- mappings
	call wheel#tower#mappings (settings)
	" ---- fill with dict keys
	let items = wheel#crystal#fetch (dictname)
	let lines = wheel#matrix#items2keys (items)
	call wheel#mandala#fill (lines)
	" ---- properties
	let b:wheel_nature.class = settings.menu.class
	let b:wheel_nature.has_filter = v:true
	let b:wheel_nature.has_selection = v:false
	" ---- save settings
	let b:wheel_settings = settings
endfun
