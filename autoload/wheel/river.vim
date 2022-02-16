" vim: set ft=vim fdm=indent iskeyword&:

" River
"
" Navigation aspect of mandala

" ---- script constants

if ! exists('s:wheel_content_generators')
	let s:wheel_content_generators = wheel#crystal#fetch('function/generator/wheel')
	lockvar s:wheel_content_generators
endif

" ---- default values

fun! wheel#river#default (settings)
	" Default settings values
	let settings = a:settings
	if ! has_key(settings, 'function')
		let settings.function = 'wheel#curve#switch'
	endif
	if ! has_key(settings, 'selection')
		let settings.selection = {}
		let settings.selection.index = -1
		let settings.selection.component = ''
	endif
	if ! has_key(settings, 'level')
		let settings.level = 'location'
	endif
	if ! has_key(settings, 'target')
		let settings.target = 'current'
	endif
	if ! has_key(settings, 'related')
		let settings.related = b:wheel_related
	endif
	if ! has_key(settings, 'follow')
		let settings.follow = v:true
	endif
	if ! has_key(settings, 'close')
		let settings.close = v:true
	endif
endfun

" ---- helpers

fun! wheel#river#mappings (settings)
	" Define whirl maps & set navigation property
	let settings = copy(a:settings)
	" ---- property
	let b:wheel_nature.has_navigation = v:true
	" ---- maps
	let nmap = 'nnoremap <buffer>'
	let loopnav = '<cmd>call wheel#loop#navigation('
	let coda = ')<cr>'
	" -- close after navigation
	let settings.close = v:true
	let settings.target = 'current'
	exe nmap '<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	exe nmap 't' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	exe nmap 'h' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	exe nmap 'v' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	exe nmap 'H' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	exe nmap 'V' loopnav .. string(settings) .. coda
	" -- leave open after navigation
	let settings.close = v:false
	let settings.target = 'current'
	exe nmap 'g<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	exe nmap 'gt' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	exe nmap 'gh' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	exe nmap 'gv' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	exe nmap 'gH' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	exe nmap 'gV' loopnav .. string(settings) .. coda
	" -- selection
	call wheel#pencil#mappings ()
	" -- preview
	call wheel#orbiter#mappings ()
	" -- context menu
	call wheel#boomerang#launch_map ('navigation')
endfun

fun! wheel#river#template (settings)
	" Template
	let settings = a:settings
	call wheel#mandala#template (settings)
	call wheel#river#mappings (settings)
endfun

fun! wheel#river#generic (type)
	" Generic whirl buffer
	let type = a:type
	if type->wheel#chain#is_inside(s:wheel_content_generators)
		let Generator = function('wheel#flower#' .. type)
	else
		let Generator = function('wheel#perspective#' .. type)
	endif
	let lines = Generator ()
	if empty(lines)
		echomsg 'wheel whirl generic : empty lines in' type
		return v:false
	endif
	call wheel#mandala#blank (type)
	let settings = #{ function : 'wheel#curve#' .. type }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#' .. type
endfun
