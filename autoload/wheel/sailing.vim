" vim: set ft=vim fdm=indent iskeyword&:

" Navigation buffers

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Helpers

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
	call wheel#mandala#open (type)
	let settings = {'function' : function('wheel#line#' .. type)}
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
		echomsg 'wheel sailing switch : empty' upper
		return
	endif
	call wheel#mandala#open ('switch/' .. level)
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
	call wheel#mandala#open ('index/location')
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
	call wheel#mandala#open ('index/circle')
	let settings = {'function' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#grid'
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	call wheel#mandala#open ('index/tree')
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
	let settings = {'function' : function('wheel#line#locate')}
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
	let settings = {'function' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#sailing#find('" .. pattern .. "')"
endfun

fun! wheel#sailing#async_find (...)
	" Search files in current directory using find in async job
	if ! has('unix')
		echomsg 'wheel async find : this function is only supported on Unix systems'
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
	" mandala
	call wheel#mandala#open ('async_find')
	let settings = {'function' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	" job
	let command = ['find', '.', '-type', 'f', '-path', pattern]
	let settings = {'mandala_type' : 'async_find'}
	if has('nvim')
		let job = wheel#wave#start(command, settings)
	else
		let job = wheel#ripple#start(command, settings)
	endif
	" map to stop the job
	let map = 'nnoremap <silent> <buffer>'
	if has('nvim')
		let callme = '<cmd>call wheel#wave#stop()<cr>'
	else
		let callme = '<cmd>call wheel#ripple#stop()<cr>'
	endif
	exe map '<c-s>' callme
	" reload
	let b:wheel_reload = "wheel#sailing#async_find('" .. pattern .. "')"
endfun

fun! wheel#sailing#mru ()
	" Most recenty used files
	call wheel#sailing#generic('mru')
	" reload
	let b:wheel_reload = 'wheel#sailing#mru'
endfun

fun! wheel#sailing#buffers (scope = 'listed')
	" Buffers
	" To be run before opening the mandala buffer
	" Optional argument scope :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	let scope = a:scope
	let lines = wheel#perspective#buffers (scope)
	" mandala buffer
	if scope == 'listed'
		let type = 'buffers'
	elseif scope == 'all'
		let type = 'buffers/all'
	else
		echomsg 'wheel sailing buffers : bad optional argument'
		return []
	endif
	call wheel#mandala#open (type)
	let settings = {'function' : function('wheel#line#buffers')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" context menu
	call wheel#boomerang#launch_map (type)
	" reload
	let b:wheel_reload = "wheel#sailing#buffers('" .. scope .. "')"
endfun

fun! wheel#sailing#tabwins ()
	" Buffers visible in tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins ()
	call wheel#mandala#open ('tabwins')
	let settings = {'function' : function('wheel#line#tabwins')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#tabwins'
	" Context menu
	call wheel#boomerang#launch_map ('tabwins')
endfun

fun! wheel#sailing#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins_tree ()
	call wheel#mandala#open ('tabwins/tree')
	let settings = {'function' : function('wheel#line#tabwins_tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#tabwins_tree'
	" Context menu
	call wheel#boomerang#launch_map ('tabwins_tree')
endfun

fun! wheel#sailing#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	call wheel#rectangle#previous ()
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#occur (pattern)
	call wheel#mandala#open ('occur')
	let settings = {'function' : function('wheel#line#occur')}
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
	if empty(lines)
		echomsg 'wheel sailing grep : no match found'
		if wheel#cylinder#is_mandala ()
			" when reloading
			let b:wheel_nature.empty = v:false
		endif
		return v:false
	endif
	call wheel#rectangle#previous ()
	let word = substitute(pattern, '\W.*', '', '')
	call wheel#mandala#open ('grep/' .. word)
	let settings = {'function' : function('wheel#line#grep')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#sailing#grep('" .. pattern .. "', '" .. sieve .. "')"
	" Context menu
	call wheel#boomerang#launch_map ('grep')
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
	call wheel#rectangle#previous ()
	call wheel#sailing#generic('markers')
	" reload
	let b:wheel_reload = 'wheel#sailing#markers'
endfun

fun! wheel#sailing#jumps ()
	" Jumps list
	call wheel#rectangle#previous ()
	let lines = wheel#perspective#jumps ()
	" mandala buffer
	call wheel#mandala#open ('jumps')
	let settings = {'function' : function('wheel#line#jumps')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#sailing#jumps'
endfun

fun! wheel#sailing#changes ()
	" Jumps list
	call wheel#rectangle#previous ()
	let lines = wheel#perspective#changes ()
	" mandala buffer
	call wheel#mandala#open ('changes')
	let settings = {'function' : function('wheel#line#changes')}
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
