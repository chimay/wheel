" vim: set ft=vim fdm=indent iskeyword&:

" Wheel navigation, dedicated buffers

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" default values

fun! wheel#whirl#default (settings)
	" Default settings values
	let settings = a:settings
	if ! has_key(settings, 'function')
		let settings.function = 'wheel#line#switch'
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
	if ! has_key(settings, 'related_buffer')
		let settings.related_buffer = b:wheel_related_buffer
	endif
	if ! has_key(settings, 'follow')
		let settings.follow = v:true
	endif
	if ! has_key(settings, 'close')
		let settings.close = v:true
	endif
endfun

" helpers

fun! wheel#whirl#mappings (settings)
	" Define whirl maps
	let settings = copy(a:settings)
	let map = 'nnoremap <silent> <buffer>'
	let pre = '<cmd>call wheel#loop#selection('
	let post = ')<cr>'
	" -- close after navigation
	let settings.close = v:true
	let settings.target = 'current'
	exe map '<cr>' pre .. string(settings) .. post
	let settings.target = 'tab'
	exe map 't' pre .. string(settings) .. post
	let settings.target = 'horizontal_split'
	exe map 's' pre .. string(settings) .. post
	let settings.target = 'vertical_split'
	exe map 'v' pre .. string(settings) .. post
	let settings.target = 'horizontal_golden'
	exe map 'S' pre .. string(settings) .. post
	let settings.target = 'vertical_golden'
	exe map 'V' pre .. string(settings) .. post
	" -- leave open after navigation
	let settings.close = v:false
	let settings.target = 'current'
	exe map 'g<cr>' pre .. string(settings) .. post
	let settings.target = 'tab'
	exe map 'gt' pre .. string(settings) .. post
	let settings.target = 'horizontal_split'
	exe map 'gs' pre .. string(settings) .. post
	let settings.target = 'vertical_split'
	exe map 'gv' pre .. string(settings) .. post
	let settings.target = 'horizontal_golden'
	exe map 'gS' pre .. string(settings) .. post
	let settings.target = 'vertical_golden'
	exe map 'gV' pre .. string(settings) .. post
	" -- selection
	call wheel#pencil#mappings ()
	" -- preview
	call wheel#orbiter#mappings ()
	" -- context menu
	call wheel#boomerang#launch_map ('navigation')
endfun

fun! wheel#whirl#template (settings)
	" Template
	let settings = a:settings
	call wheel#mandala#template (settings)
	call wheel#whirl#mappings (settings)
endfun

fun! wheel#whirl#generic (type)
	" Generic whirl buffer
	let type = a:type
	let Perspective = function('wheel#perspective#' .. type)
	let lines = Perspective ()
	if empty(lines)
		echomsg 'wheel whirl generic : empty lines in' type
		return v:false
	endif
	call wheel#mandala#blank (type)
	let settings = {'function' : function('wheel#line#' .. type)}
	call wheel#whirl#template (settings)
	call wheel#mandala#fill(lines)
endfun

" applications

fun! wheel#whirl#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	if wheel#referen#is_empty_upper (level)
		let upper = wheel#referen#upper_level_name (level)
		echomsg 'wheel whirl switch : empty' upper
		return v:false
	endif
	let lines = wheel#perspective#switch (level)
	call wheel#mandala#blank ('switch/' .. level)
	let settings = {'level' : level}
	call wheel#whirl#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'wheel whirl switch : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#whirl#switch('" .. level .. "')"
endfun

fun! wheel#whirl#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#perspective#helix ()
	if empty(lines)
		echomsg 'wheel whirl helix : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/location')
	let settings = {'function' : function('wheel#line#helix')}
	call wheel#whirl#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#helix'
endfun

fun! wheel#whirl#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#perspective#grid ()
	if empty(lines)
		echomsg 'wheel whirl grid : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/circle')
	let settings = {'function' : function('wheel#line#grid')}
	call wheel#whirl#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#grid'
endfun

fun! wheel#whirl#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	if empty(lines)
		echomsg 'wheel whirl tree : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/tree')
	let settings = {'function' : function('wheel#line#tree')}
	call wheel#whirl#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#tree'
endfun

fun! wheel#whirl#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#whirl#generic('history')
	" reload
	let b:wheel_reload = 'wheel#whirl#history'
endfun

fun! wheel#whirl#history_circuit ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#whirl#generic('history_circuit')
	" reload
	let b:wheel_reload = 'wheel#whirl#history_circuit'
endfun
