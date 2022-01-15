" vim: set ft=vim fdm=indent iskeyword&:

" Navigation buffers

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Helpers

fun! wheel#sailing#maps (settings)
	" Define local maps
	let settings = copy(a:settings)
	let map = 'nnoremap <silent> <buffer> '
	let pre = ' :call wheel#loop#sailing('
	let post = ')<cr>'
	" Close after navigation
	let settings.close = v:true
	let settings.target = 'current'
	exe map .. '<cr>' .. pre .. string(settings) .. post
	let settings.target = 'tab'
	exe map .. 't' .. pre .. string(settings) .. post
	let settings.target = 'horizontal_split'
	exe map .. 's' .. pre .. string(settings) .. post
	let settings.target = 'vertical_split'
	exe map .. 'v' .. pre .. string(settings) .. post
	let settings.target = 'horizontal_golden'
	exe map .. 'S' .. pre .. string(settings) .. post
	let settings.target = 'vertical_golden'
	exe map .. 'V' .. pre .. string(settings) .. post
	" Leave open after navigation
	let settings.close = v:false
	let settings.target = 'current'
	exe map .. 'g<cr>' .. pre .. string(settings) .. post
	let settings.target = 'tab'
	exe map .. 'gt' .. pre .. string(settings) .. post
	let settings.target = 'horizontal_split'
	exe map .. 'gs' .. pre .. string(settings) .. post
	let settings.target = 'vertical_split'
	exe map .. 'gv' .. pre .. string(settings) .. post
	let settings.target = 'horizontal_golden'
	exe map .. 'gS' .. pre .. string(settings) .. post
	let settings.target = 'vertical_golden'
	exe map .. 'gV' .. pre .. string(settings) .. post
	" Define local selection maps
	nnoremap <buffer> <space> <cmd>call wheel#pencil#toggle()<cr>
	nnoremap <buffer> & <cmd>call wheel#pencil#toggle_visible()<cr>
	nnoremap <buffer> * <cmd>call wheel#pencil#select_visible()<cr>
	nnoremap <buffer> <bar> <cmd>call wheel#pencil#clear_visible()<cr>
	" Context menu
	nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('sailing')<cr>
endfun

fun! wheel#sailing#template (settings)
	" Template
	let settings = a:settings
	call wheel#mandala#template (settings)
	call wheel#sailing#maps (settings)
endfun

fun! wheel#sailing#generic (name)
	" Generic sailing buffer
	let name = a:name
	let Perspective = function('wheel#perspective#' .. name)
	let lines = Perspective ()
	call wheel#mandala#open (name)
	let settings = {'action' : function('wheel#line#' .. name)}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

" Buffers

fun! wheel#sailing#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	let lines = wheel#perspective#switch (level)
	if wheel#referen#is_empty_upper (level)
		let upper = wheel#referen#upper_level_name (level)
		echomsg 'wheel mandala switch : empty' upper
		return
	endif
	call wheel#vortex#update ()
	let maxlevel = wheel#referen#coordin_index(level)
	let dashboard = wheel#referen#names()
	if maxlevel > 0
		let maxlevel -= 1
		let dashboard = ' in ' .. join(dashboard[0:maxlevel], ':')
	else
		let dashboard = ''
	endif
	call wheel#mandala#open ('switch/' .. level .dashboard)
	let settings = {'level' : level}
	call wheel#sailing#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'wheel mandala switch : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = "wheel#sailing#switch('" .. level .. "')"
endfun

fun! wheel#sailing#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#perspective#helix ()
	call wheel#mandala#open ('location/index')
	let settings = {'action' : function('wheel#line#helix')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#helix'
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#perspective#grid ()
	call wheel#mandala#open ('circle/index')
	let settings = {'action' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#grid'
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	call wheel#mandala#open ('tree')
	let settings = {'action' : function('wheel#line#tree')}
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

fun! wheel#sailing#locate (...)
	" Search files using locate
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Locate file matching : '
		let pattern = input(prompt)
	endif
	let lines = wheel#perspective#locate (pattern)
	call wheel#mandala#open ('locate')
	let settings = {'action' : function('wheel#line#locate')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#sailing#locate('" .. pattern .. "')"
endfun

fun! wheel#sailing#find (...)
	" Find files in current directory using **/*pattern* glob
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Find file matching : '
		let wordlist = split(input(prompt))
		let pattern = '**/*'
		for word in wordlist
			let pattern ..= word .. '*'
		endfor
	endif
	echomsg 'wheel find : using pattern' pattern
	let lines = wheel#perspective#find (pattern)
	call wheel#mandala#open ('find')
	let settings = {'action' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#sailing#find('" .. pattern .. "')"
endfun

fun! wheel#sailing#async_find (...)
	" Search files in current directory using find in async job
	if ! has('unix')
		echomsg 'wheel : this function is only supported on Unix systems.'
		return v:false
	endif
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Async find file matching : '
		let input = input(prompt)
		let input = escape(input, '*')
		let wordlist = split(input)
		let pattern = '*'
		for word in wordlist
			let pattern ..= word .. '*'
		endfor
	endif
	echomsg 'wheel async find : using pattern' pattern
	call wheel#mandala#open ('async_find')
	let settings = {'action' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	let command = ['find', '.', '-type', 'f', '-path', pattern]
	let settings = {'mandala_open' : v:false, 'mandala_type' : 'async_find'}
	if has('nvim')
		let job = wheel#wave#start(command, settings)
	else
		let job = wheel#ripple#start(command, settings)
	endif
	" Map to stop the job
	let map = 'nnoremap <silent> <buffer> '
	if has('nvim')
		let callme = ' :call wheel#wave#stop()<cr>'
	else
		let callme = ' :call wheel#ripple#stop()<cr>'
	endif
	exe map .. '<c-s>' .. callme
	" reload
	let b:wheel_reload = "wheel#sailing#async_find('" .. pattern .. "')"
endfun

fun! wheel#sailing#mru ()
	" Most recenty used files
	call wheel#sailing#generic('mru')
	" reload
	let b:wheel_reload = 'wheel#sailing#mru'
endfun

fun! wheel#sailing#buffers (mode = 'listed')
	" Buffers
	" To be run before opening the mandala buffer
	" Optional argument mode :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	let mode = a:mode
	let lines = wheel#perspective#buffers (mode)
	call wheel#vortex#update ()
	" mandala buffer
	if mode == 'listed'
		let name = 'buffers'
	elseif mode == 'all'
		let name = 'buffers/all'
	else
		echomsg 'wheel sailing buffers : bad optional argument'
		return []
	endif
	call wheel#mandala#open (name)
	let settings = {'action' : function('wheel#line#buffers')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" context menu
	exe "nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('" .. name .. "')<cr>"
	" reload
	let b:wheel_reload = "wheel#sailing#buffers('" .. mode .. "')"
endfun

fun! wheel#sailing#tabwins ()
	" Buffers visible in tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins ()
	call wheel#vortex#update ()
	" mandala buffer
	call wheel#mandala#open ('tabwins')
	let settings = {'action' : function('wheel#line#tabwins')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#tabwins'
	" Context menu
	nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('tabwins')<cr>
endfun

fun! wheel#sailing#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins_tree ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('tabwins/tree')
	let settings = {'action' : function('wheel#line#tabwins_tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#tabwins_tree'
	" Context menu
	nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('tabwins_tree')<cr>
endfun

fun! wheel#sailing#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	call wheel#mandala#close ()
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#occur (pattern)
	call wheel#mandala#open ('occur')
	let settings = {'action' : function('wheel#line#occur')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#sailing#occur('" .. pattern .. "')"
endfun

fun! wheel#sailing#grep (...)
	" Grep results
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Grep circle files for pattern : ')
	endif
	if a:0 > 1
		let sieve = a:2
	else
		let sieve = '\m.'
	endif
	let lines = wheel#perspective#grep (pattern, sieve)
	if type(lines) == v:t_list
		if empty(lines)
			echomsg 'wheel sailing grep : no match found.'
			return v:false
		endif
	elseif type(lines) == type(v:true)
		if ! lines
			echomsg 'wheel sailing grep : lines parameter is false.'
			return v:false
		endif
	endif
	call wheel#vortex#update ()
	call wheel#mandala#open ('grep')
	let settings = {'action' : function('wheel#line#grep')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#sailing#grep('" .. pattern .. "')"
	" Context menu
	nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('grep')<cr>
	" Useful if we choose edit mode on the context menu
	let b:wheel_settings.pattern = pattern
	let b:wheel_settings.sieve = sieve
	return lines
endfun

fun! wheel#sailing#outline (...)
	" Outline fold headers
	if a:0 > 0
		let mode = a:1
	else
		let prompt = 'Outline mode ? '
		let mode = confirm(prompt, "&Folds\n&Markdown\n&Org mode\nVimwiki", 1)
	endif
	if mode == 1
		let marker = split(&foldmarker, ',')[0]
		let grep_ex_command = g:wheel_config.grep
		if grep_ex_command =~ '^:\?grep' && &grepprg !~ '^grep'
			let marker = escape(marker, '{')
		endif
		let lines = wheel#sailing#grep (marker)
	elseif mode == 2
		let lines = wheel#sailing#grep ('^#', '\.md$')
	elseif mode == 3
		let lines = wheel#sailing#grep ('^\*', '\.org$')
	elseif mode == 4
		let lines = wheel#sailing#grep ('^=.*=$', '\.wiki$')
	endif
	if ! empty(lines)
		call wheel#mandala#filename ('outline')
		" reload
		let b:wheel_reload = "wheel#sailing#outline('" .. mode .. "')"
	endif
endfun

fun! wheel#sailing#markers ()
	" Markers
	call wheel#mandala#close ()
	call wheel#sailing#generic('markers')
	" reload
	let b:wheel_reload = 'wheel#sailing#markers'
endfun

fun! wheel#sailing#jumps ()
	" Jumps list
	call wheel#mandala#close ()
	let lines = wheel#perspective#jumps ()
	" mandala buffer
	call wheel#mandala#open ('jumps')
	let settings = {'action' : function('wheel#line#jumps')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#jumps'
endfun

fun! wheel#sailing#changes ()
	" Jumps list
	call wheel#mandala#close ()
	let lines = wheel#perspective#changes ()
	" mandala buffer
	call wheel#mandala#open ('changes')
	let settings = {'action' : function('wheel#line#changes')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#changes'
endfun

fun! wheel#sailing#tags ()
	" Tags file
	call wheel#sailing#generic('tags')
	" reload
	let b:wheel_reload = 'wheel#sailing#tags'
endfun
