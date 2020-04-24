" vim: ft=vim fdm=indent:

" Navigation buffers

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
	call wheel#mandala#template ('navigation', settings)
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
	call wheel#mandala#template ('navigation', settings)
	let lines = wheel#perspective#helix ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-circle-index')
	let settings = {'action' : function('wheel#line#grid')}
	call wheel#mandala#template ('navigation', settings)
	let lines = wheel#perspective#grid ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#tree ()
	" Choose an element in the wheel tree
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tree')
	let settings = {'action' : function('wheel#line#tree')}
	call wheel#mandala#template ('navigation', settings)
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
	call wheel#mandala#template ('navigation', settings)
	let lines = wheel#perspective#pendulum ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#grep (...)
	" Grep results
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Search in circle files for pattern ? ')
	endif
	if a:0 > 1
		let sieve = a:2
	else
		let sieve = '\m.'
	endif
	let ret = wheel#vector#grep(pattern, sieve)
	if ret
		call wheel#vortex#update ()
		call wheel#mandala#open ('wheel-grep')
		let settings = {'action' : function('wheel#line#grep')}
		call wheel#mandala#template ('navigation', settings)
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
		call wheel#mandala#grep (marker)
	elseif mode == 2
		call wheel#mandala#grep ('^#', '\.md$')
	elseif mode == 3
		call wheel#mandala#grep ('^\*', '\.org$')
	endif
endfun

fun! wheel#sailing#attic ()
	" Most recenty used files
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-mru')
	let settings = {'action' : function('wheel#line#attic')}
	call wheel#mandala#template ('navigation', settings)
	let lines = wheel#perspective#attic ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#sailing#locate ()
	" Search files using locate
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-locate')
	let settings = {'action' : function('wheel#line#locate')}
	call wheel#mandala#template ('navigation', settings)
	let prompt = 'Search for file matching : '
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

fun! wheel#sailing#symbol ()
	" Tags file
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tags')
	let settings = {'action' : function('wheel#line#symbol')}
	call wheel#mandala#template ('navigation', settings)
	let lines = wheel#perspective#symbol ()
	call wheel#mandala#fill(lines)
endfun
