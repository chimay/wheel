" vim: ft=vim fdm=indent:

" Navigation buffers

" Script vars

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Helpers

fun! wheel#sailing#maps (settings)
	" Define local maps
	let settings = copy(a:settings)
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#line#sailing('
	let post = ')<cr>'
	" Close after navigation
	let settings.close = v:true
	let settings.target = 'current'
	exe map . '<cr>' . pre . string(settings) . post
	let settings.target = 'tab'
	exe map . 't' . pre . string(settings) . post
	let settings.target = 'horizontal_split'
	exe map . 's' . pre . string(settings) . post
	let settings.target = 'vertical_split'
	exe map . 'v' . pre . string(settings) . post
	let settings.target = 'horizontal_golden'
	exe map . 'S' . pre . string(settings) . post
	let settings.target = 'vertical_golden'
	exe map . 'V' . pre . string(settings) . post
	" Leave open after navigation
	let settings.close = v:false
	let settings.target = 'current'
	exe map . 'g<cr>' . pre . string(settings) . post
	let settings.target = 'tab'
	exe map . 'gt' . pre . string(settings) . post
	let settings.target = 'horizontal_split'
	exe map . 'gs' . pre . string(settings) . post
	let settings.target = 'vertical_split'
	exe map . 'gv' . pre . string(settings) . post
	let settings.target = 'horizontal_golden'
	exe map . 'gS' . pre . string(settings) . post
	let settings.target = 'vertical_golden'
	exe map . 'gV' . pre . string(settings) . post
	" Define local toggle selection maps
	nnoremap <buffer> <space> :call wheel#line#toggle()<cr>
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('sailing')<cr>
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
	let Perspective = function('wheel#perspective#' . name)
	let lines = Perspective ()
	call wheel#vortex#update ()
	call wheel#mandala#open (name)
	let settings = {'action' : function('wheel#line#' . name)}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#bounce (command)
	" Buffer for jumps / changes lists
	let command = a:command
	let lines = wheel#perspective#bounce (command)
	" mandala buffer
	call wheel#mandala#open (command)
	let settings = {'action' : function('wheel#line#' . command)}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

" Buffers

fun! wheel#sailing#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	let lines = wheel#perspective#switch (level)
	if wheel#referen#empty_upper (level)
		let upper = wheel#referen#upper_level_name (level)
		echomsg 'Wheel mandala switch : empty' upper
		return
	endif
	call wheel#vortex#update ()
	let maxlevel = wheel#referen#coordin_index(level)
	let dashboard = wheel#referen#names()
	if maxlevel > 0
		let maxlevel -= 1
		let dashboard = ' in ' . join(dashboard[0:maxlevel], ':')
	else
		let dashboard = ''
	endif
	call wheel#mandala#open ('switch/' . level .dashboard)
	let settings = {'level' : level}
	call wheel#sailing#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'Wheel mandala switch : empty or incomplete' level
	endif
	" Reload
	let b:wheel_reload = "wheel#sailing#switch('" . level . "')"
endfun

fun! wheel#sailing#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#perspective#helix ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('location/index')
	let settings = {'action' : function('wheel#line#helix')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#helix'
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#perspective#grid ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('circle/index')
	let settings = {'action' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#grid'
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('tree')
	let settings = {'action' : function('wheel#line#tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#tree'
endfun

fun! wheel#sailing#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#sailing#generic('history')
	" Reload
	let b:wheel_reload = 'wheel#sailing#history'
endfun

fun! wheel#sailing#opened_files ()
	" Opened files
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#opened_files ()
	call wheel#vortex#update ()
	" mandala buffer
	call wheel#mandala#open ('buffers')
	let settings = {'action' : function('wheel#line#opened_files')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#opened_files'
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('openedFiles')<cr>
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
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#tabwins'
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('tabwins')<cr>
endfun

fun! wheel#sailing#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins_tree ()
	call wheel#vortex#update ()
	" mandala buffer
	call wheel#mandala#open ('tabwins/tree')
	let settings = {'action' : function('wheel#line#tabwins_tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#tabwins_tree'
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('tabwins_tree')<cr>
endfun

fun! wheel#sailing#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#occur (pattern)
	" mandala buffer
	call wheel#mandala#open ('occur')
	let settings = {'action' : function('wheel#line#occur')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = "wheel#sailing#occur('" . pattern . "')"
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
	let bool = wheel#vector#grep(pattern, sieve)
	if bool
		let lines = wheel#perspective#grep ()
		call wheel#vortex#update ()
		call wheel#mandala#open ('grep')
		let settings = {'action' : function('wheel#line#grep')}
		call wheel#sailing#template (settings)
		call wheel#mandala#fill(lines)
		" Reload
		let b:wheel_reload = "wheel#sailing#grep('" . pattern . "')"
		" Context menu
		nnoremap <buffer> <tab> :call wheel#boomerang#menu('grep')<cr>
	endif
	return bool
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
		if &grepprg !~ '^grep'
			let marker = escape(marker, '{')
		endif
		let bool = wheel#sailing#grep (marker)
	elseif mode == 2
		let bool = wheel#sailing#grep ('^#', '\.md$')
	elseif mode == 3
		let bool = wheel#sailing#grep ('^\*', '\.org$')
	elseif mode == 4
		let bool = wheel#sailing#grep ('^=.*=$', '\.wiki$')
	endif
	if bool
		call wheel#mandala#pseudo_filename ('outline')
		" Reload
		let b:wheel_reload = "wheel#sailing#outline('" . mode . "')"
	endif
endfun

fun! wheel#sailing#tags ()
	" Tags file
	call wheel#sailing#generic('tags')
	" Reload
	let b:wheel_reload = 'wheel#sailing#tags'
endfun

fun! wheel#sailing#mru ()
	" Most recenty used files
	call wheel#sailing#generic('mru')
	" Reload
	let b:wheel_reload = 'wheel#sailing#mru'
endfun

fun! wheel#sailing#locate ()
	" Search files using locate
	let prompt = 'Locate file matching : '
	let pattern = input(prompt)
	let lines = wheel#perspective#locate (pattern)
	call wheel#vortex#update ()
	call wheel#mandala#open ('locate')
	let settings = {'action' : function('wheel#line#locate')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Reload
	let b:wheel_reload = 'wheel#sailing#locate'
endfun

fun! wheel#sailing#find (...)
	" Search files in current directory using find
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Find file matching : '
		let pattern = '*' . input(prompt) . '*'
		let pattern = escape(pattern, '*')
	endif
	call wheel#vortex#update ()
	call wheel#mandala#open ('find')
	let settings = {'action' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	let command = ['find', '.', '-type', 'f', '-path', pattern]
	let settings = {'mandala_open' : v:false, 'mandala_type' : 'find'}
	if has('nvim')
		let job = wheel#wave#start(command, settings)
	else
		let job = wheel#ripple#start(command, settings)
	endif
	" Map to stop the job
	let map  =  'nnoremap <buffer> '
	if has('nvim')
		let callme  = ' :call wheel#wave#stop()<cr>'
	else
		let callme  = ' :call wheel#ripple#stop()<cr>'
	endif
	exe map . '<c-s>' . callme
	" Reload
	let b:wheel_reload = "wheel#sailing#find('" . pattern . "')"
endfun

fun! wheel#sailing#jumps ()
	" Jumps list
	call wheel#sailing#bounce ('jumps')
	" Reload
	let b:wheel_reload = 'wheel#sailing#jumps'
endfun

fun! wheel#sailing#changes ()
	" Changes list
	call wheel#sailing#bounce ('changes')
	" Reload
	let b:wheel_reload = 'wheel#sailing#changes'
endfun
