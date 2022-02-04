" vim: set ft=vim fdm=indent iskeyword&:

" Tower
"
" Menu leaf for mandalas

" script constants

if ! exists('s:fun_is_navigation')
	let s:fun_is_navigation = wheel#crystal#fetch('function/pattern/navigation')
	lockvar s:fun_is_navigation
endif

if ! exists('s:fun_opens_mandala')
	let s:fun_opens_mandala = wheel#crystal#fetch('function/pattern/mandala/opens')
	lockvar s:fun_opens_mandala
endif

if ! exists('s:fun_needs_mandala')
	let s:fun_needs_mandala = wheel#crystal#fetch('function/pattern/mandala/needs')
	lockvar s:fun_needs_mandala
endif

" booleans

fun! wheel#tower#is_navigation (function)
	" Whether function is a navigation one
	let function = a:function
	for pattern in s:fun_is_navigation
		if function =~ pattern
			return v:true
		endif
	endfor
	return v:false
endfun

fun! wheel#tower#opens_mandala (function)
	" Whether function opens a mandala
	let function = a:function
	for pattern in s:fun_opens_mandala
		if function =~ pattern
			return v:true
		endif
	endfor
	return v:false
endfun

fun! wheel#tower#needs_mandala (function)
	" Whether function needs a mandala
	let function = a:function
	for pattern in s:fun_needs_mandala
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
	" ---- navigation functions needs to be on the previous, regular window
	if wheel#tower#is_navigation (function)
		call wheel#rectangle#previous ()
	endif
	" --- if functions opens or needs a mandala, override the close setting
	let uses_mandala = wheel#tower#opens_mandala (function)
	let uses_mandala = uses_mandala || wheel#tower#needs_mandala (function)
	if uses_mandala
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

fun! wheel#tower#staircase (menuset, settings = {})
	" Replace buffer content by a {line -> fun} leaf
	" Define dict maps
	" Used for :
	"   - meta menu & submenus
	"   - context menu leaf
	let menuset = a:menuset
	let settings = deepcopy(a:settings)
	let dictname = menuset.linefun
	let settings.menu = menuset
	" ---- blank mandala
	call wheel#mandala#blank (dictname)
	" ---- mappings
	call wheel#tower#mappings (settings)
	" ---- fill with dict keys
	let items = wheel#crystal#fetch (dictname)
	let lines = wheel#matrix#items2keys (items)
	call wheel#mandala#fill (lines)
	" ---- properties
	let b:wheel_nature.class = menuset.class
	let b:wheel_nature.has_filter = v:true
	let b:wheel_nature.has_selection = v:false
	" ---- save settings
	let b:wheel_settings = settings
endfun
