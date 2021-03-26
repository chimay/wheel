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
	call wheel#mandala#open ('wheel/' . name)
	let settings = {'action' : function('wheel#line#' . name)}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#bounce (command)
	" Buffer for jumps / changes lists
	let command = a:command
	let lines = wheel#perspective#bounce (command)
	" Wheel buffer
	call wheel#mandala#open ('wheel/' . command)
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
	let dashboard = wheel#referen#names()
	let maxlevel = wheel#referen#coordin_index(level)
	let dashboard = join(dashboard[0:maxlevel], ':')
	call wheel#mandala#open ('wheel/switch/' . level . ' ' . dashboard)
	let settings = {'level' : level}
	call wheel#sailing#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'Wheel mandala switch : empty or incomplete' level
	endif
endfun

fun! wheel#sailing#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#perspective#helix ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel/location/index')
	let settings = {'action' : function('wheel#line#helix')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#perspective#grid ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel/circle/index')
	let settings = {'action' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	let lines = wheel#perspective#tree ()
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel/tree')
	let settings = {'action' : function('wheel#line#tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#sailing#generic('history')
endfun

fun! wheel#sailing#opened_files ()
	" Opened files
	" To be run before opening the wheel buffer
	let lines = wheel#perspective#opened_files ()
	call wheel#vortex#update ()
	" Wheel buffer
	call wheel#mandala#open ('wheel/opened/files')
	let settings = {'action' : function('wheel#line#opened_files')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('openedFiles')<cr>
endfun

fun! wheel#sailing#tabwins ()
	" Buffers visible in tabs & wins
	" To be run before opening the wheel buffer
	let lines = wheel#perspective#tabwins ()
	call wheel#vortex#update ()
	" Wheel buffer
	call wheel#mandala#open ('wheel/tabwins')
	let settings = {'action' : function('wheel#line#tabwins')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('tabwins', {'ctx_close' : v:true})<cr>
endfun

fun! wheel#sailing#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the wheel buffer
	let lines = wheel#perspective#tabwins_tree ()
	call wheel#vortex#update ()
	" Wheel buffer
	call wheel#mandala#open ('wheel/tabwins/tree')
	let settings = {'action' : function('wheel#line#tabwins_tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('tabwins_tree', {'ctx_close' : v:true})<cr>
endfun

fun! wheel#sailing#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	" To be run before opening the wheel buffer
	let lines = wheel#perspective#occur (pattern)
	" Wheel buffer
	call wheel#mandala#open ('wheel/occur')
	let settings = {'action' : function('wheel#line#occur')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
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
		call wheel#mandala#open ('wheel/grep')
		let settings = {'action' : function('wheel#line#grep')}
		call wheel#sailing#template (settings)
		call wheel#mandala#fill(lines)
		" Context menu
		nnoremap <buffer> <tab> :call wheel#boomerang#menu('grep')<cr>
	endif
	return bool
endfun

fun! wheel#sailing#outline ()
	" Outline fold headers
	let prompt = 'Outline mode ? '
	let mode = confirm(prompt, "&Folds\n&Markdown\n&Org mode\nVimwiki", 1)
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
		let &filetype = 'wheel/outline'
		file /wheel/outline
	endif
endfun

fun! wheel#sailing#tags ()
	" Tags file
	call wheel#sailing#generic('tags')
endfun

fun! wheel#sailing#mru ()
	" Most recenty used files
	call wheel#sailing#generic('mru')
endfun

fun! wheel#sailing#locate ()
	" Search files using locate
	let prompt = 'Locate file matching : '
	let pattern = input(prompt)
	let lines = wheel#perspective#locate (pattern)
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel/locate')
	let settings = {'action' : function('wheel#line#locate')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#find ()
	" Search files in current directory using find
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel/find')
	let settings = {'action' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	let prompt = 'Find file matching : '
	let pattern = '*' . input(prompt) . '*'
	let pattern = escape(pattern, '*')
	let command = ['find', '.', '-type', 'f', '-path', pattern]
	let settings = {'new_buffer' : v:false}
	if has('nvim')
		call wheel#wave#start(command, settings)
	else
		call wheel#ripple#start(command, settings)
	endif
endfun

fun! wheel#sailing#jumps ()
	" Jumps list
	call wheel#sailing#bounce ('jumps')
endfun

fun! wheel#sailing#changes ()
	" Changes list
	call wheel#sailing#bounce ('changes')
endfun
