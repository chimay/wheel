" vim: ft=vim fdm=indent:

" Navigation buffers

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

" Buffers

fun! wheel#sailing#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	if wheel#referen#empty_upper (level)
		let upper = wheel#referen#upper_level_name (level)
		echomsg 'Wheel mandala switch : empty' upper
		return
	endif
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-switch-' . level)
	let settings = {'level' : level}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#switch (level)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'Wheel mandala switch : empty or incomplete' level
	endif
endfun

fun! wheel#sailing#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-location-index')
	let settings = {'action' : function('wheel#line#helix')}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#helix ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-circle-index')
	let settings = {'action' : function('wheel#line#grid')}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#grid ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tree')
	let settings = {'action' : function('wheel#line#tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ()
	let lines = wheel#perspective#tree ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-history')
	let settings = {'action' : function('wheel#line#history')}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#pendulum ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#grep (...)
	" Grep results
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Grep circle files for pattern ? ')
	endif
	if a:0 > 1
		let sieve = a:2
	else
		let sieve = '\m.'
	endif
	let bool = wheel#vector#grep(pattern, sieve)
	if bool
		call wheel#vortex#update ()
		call wheel#mandala#open ('wheel-grep')
		let settings = {'action' : function('wheel#line#grep')}
		call wheel#sailing#template (settings)
		let lines = wheel#perspective#grep ()
		call wheel#mandala#fill(lines)
		" Context menu
		nnoremap <buffer> <tab> :call wheel#boomerang#menu('grep')<cr>
	endif
endfun

fun! wheel#sailing#outline ()
	" Outline fold headers
	let prompt = 'Outline mode ? '
	let mode = confirm(prompt, "&Folds\n&Markdown\n&Org mode", 1)
	if mode == 1
		let marker = split(&foldmarker, ',')[0]
		if &grepprg !~ '^grep'
			let marker = escape(marker, '{')
		endif
		call wheel#sailing#grep (marker)
	elseif mode == 2
		call wheel#sailing#grep ('^#', '\.md$')
	elseif mode == 3
		call wheel#sailing#grep ('^\*', '\.org$')
	endif
endfun

fun! wheel#sailing#attic ()
	" Most recenty used files
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-mru')
	let settings = {'action' : function('wheel#line#attic')}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#attic ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#locate ()
	" Search files using locate
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-locate')
	let settings = {'action' : function('wheel#line#locate')}
	call wheel#sailing#template (settings)
	let prompt = 'Locate file matching : '
	let pattern = input(prompt)
	let database = g:wheel_config.locate_db
	if empty(database)
		let runme = 'locate ' . pattern
	else
		let runme = 'locate -d ' . expand(database) . ' ' . pattern
	endif
	let lines = systemlist(runme)
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#find ()
	" Search files in current directory using find
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-find')
	let settings = {'action' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	let prompt = 'Find file matching : '
	let pattern = '*' . input(prompt) . '*'
	let pattern = escape(pattern, '*')
	let command = ['find', '.', '-type', 'f', '-name', pattern]
	let settings = {'new_buffer' : v:false}
	if has('nvim')
		call wheel#wave#start(command, settings)
	else
		call wheel#ripple#start(command, settings)
	endif
endfun

fun! wheel#sailing#symbol ()
	" Tags file
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tags')
	let settings = {'action' : function('wheel#line#symbol')}
	call wheel#sailing#template (settings)
	let lines = wheel#perspective#symbol ()
	call wheel#mandala#fill(lines)
endfun
