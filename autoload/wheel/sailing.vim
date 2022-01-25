" vim: set ft=vim fdm=indent iskeyword&:

"  Dedicated buffers for navigation in the wheel

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" default values

fun! wheel#sailing#default (settings)
	" Default settings values
	let settings = a:settings
	if ! has_key(settings, 'function')
		let settings.function = 'wheel#line#switch'
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

fun! wheel#sailing#mappings (settings)
	" Define sailing maps
	let settings = copy(a:settings)
	let map = 'nnoremap <silent> <buffer>'
	let pre = '<cmd>call wheel#loop#sailing('
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
	call wheel#boomerang#launch_map ('sailing')
endfun

fun! wheel#sailing#template (settings)
	" Template
	let settings = a:settings
	call wheel#mandala#template (settings)
	call wheel#sailing#mappings (settings)
endfun

fun! wheel#sailing#generic (type)
	" Generic sailing buffer
	let type = a:type
	let Perspective = function('wheel#perspective#' .. type)
	let lines = Perspective ()
	if empty(lines)
		echomsg 'wheel sailing generic : empty lines in' type
		return v:false
	endif
	call wheel#mandala#blank (type)
	let settings = {'function' : function('wheel#line#' .. type)}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

" applications

fun! wheel#sailing#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	if wheel#referen#is_empty_upper (level)
		let upper = wheel#referen#upper_level_name (level)
		echomsg 'wheel sailing switch : empty' upper
		return v:false
	endif
	let lines = wheel#perspective#switch (level)
	call wheel#mandala#blank ('switch/' .. level)
	let settings = {'level' : level}
	call wheel#sailing#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'wheel sailing switch : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#sailing#switch('" .. level .. "')"
endfun

fun! wheel#sailing#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#perspective#helix ()
	if empty(lines)
		echomsg 'wheel sailing helix : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/location')
	let settings = {'function' : function('wheel#line#helix')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#helix'
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#perspective#grid ()
	if empty(lines)
		echomsg 'wheel sailing grid : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/circle')
	let settings = {'function' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#grid'
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	if empty(lines)
		echomsg 'wheel sailing tree : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/tree')
	let settings = {'function' : function('wheel#line#tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#tree'
endfun

fun! wheel#sailing#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#sailing#generic('history')
	" reload
	let b:wheel_reload = 'wheel#sailing#history'
endfun

fun! wheel#sailing#history_circuit ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#sailing#generic('history_circuit')
	" reload
	let b:wheel_reload = 'wheel#sailing#history_circuit'
endfun
