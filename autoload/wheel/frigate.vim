" vim: set ft=vim fdm=indent iskeyword&:

" Frigate
"
" Native navigation, dedicated buffers

" ---- helpers

fun! wheel#frigate#generic (type)
	" Generic whirl buffer
	let type = a:type
	let Perspective = function('wheel#perspective#' .. type)
	let lines = Perspective ()
	if empty(lines)
		echomsg 'wheel frigate generic : empty lines in' type
		return v:false
	endif
	call wheel#mandala#blank (type)
	let settings = #{ function : 'wheel#line#' .. type }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#' .. type
endfun

" ---- buffers, tabs, windows

fun! wheel#frigate#buffer (scope = 'listed')
	" Buffers
	" To be run before opening the mandala buffer
	" Optional argument scope :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	let scope = a:scope
	let lines = wheel#perspective#buffer (scope)
	if empty(lines)
		echomsg 'wheel frigate buffer : empty result'
		return v:false
	endif
	" mandala buffer
	if scope ==# 'listed'
		let type = 'buffer'
	elseif scope ==# 'all'
		let type = 'buffer/all'
	else
		echomsg 'wheel frigate buffer : bad optional argument'
		return []
	endif
	call wheel#mandala#blank (type)
	let settings = #{ function : 'wheel#line#buffer' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" context menu
	call wheel#boomerang#launch_map (type)
	" reload
	let b:wheel_reload = 'wheel#frigate#buffer(' .. string(scope) .. ')'
endfun

fun! wheel#frigate#tabwin_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwin_tree ()
	if empty(lines)
		echomsg 'wheel frigate tabwin tree : empty result'
		return v:false
	endif
	call wheel#mandala#blank ('tabwin/tree')
	let settings = #{ function : 'wheel#line#tabwin_tree' }
	call wheel#river#template (settings)
	call wheel#mandala#folding_options ('tabwin_folding_text')
	call wheel#mandala#fill (lines)
	" properties
	let b:wheel_nature.is_treeish = v:true
	" full information
	let b:wheel_full = wheel#cuboctahedron#tabwin ()
	" reload
	let b:wheel_reload = 'wheel#frigate#tabwin_tree'
	" Context menu
	call wheel#boomerang#launch_map ('tabwin_tree')
endfun

fun! wheel#frigate#tabwin ()
	" Buffers visible in tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwin ()
	if empty(lines)
		echomsg 'wheel frigate tabwin : empty result'
		return v:false
	endif
	call wheel#mandala#blank ('tabwin')
	let settings = #{ function : 'wheel#line#tabwin' }
	call wheel#river#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#tabwin'
	" Context menu
	call wheel#boomerang#launch_map ('tabwin')
endfun

" ---- vim lists

fun! wheel#frigate#marker ()
	" Markers
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#goto_previous ()
	endif
	call wheel#frigate#generic('marker')
endfun

fun! wheel#frigate#jump ()
	" Jumps list
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#goto_previous ()
	endif
	let lines = wheel#perspective#jump ()
	if empty(lines)
		echomsg 'wheel frigate jump : empty result'
		return v:false
	endif
	" mandala buffer
	call wheel#mandala#blank ('jump')
	let settings = #{ function : 'wheel#line#jump' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#jump'
endfun

fun! wheel#frigate#change ()
	" Jumps list
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#goto_previous ()
	endif
	let lines = wheel#perspective#change ()
	if empty(lines)
		echomsg 'wheel frigate change : empty result'
		return v:false
	endif
	" mandala buffer
	call wheel#mandala#blank ('change')
	let settings = #{ function : 'wheel#line#change' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#change'
endfun

fun! wheel#frigate#tag ()
	" Tags file
	call wheel#frigate#generic('tag')
endfun

" ---- search files

fun! wheel#frigate#mru ()
	" Most recenty used files
	call wheel#frigate#generic('mru')
endfun

fun! wheel#frigate#locate (...)
	" Search files using locate
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Locate file matching : '
		let pattern = input(prompt)
	endif
	let lines = wheel#perspective#locate (pattern)
	if empty(lines)
		echomsg 'wheel frigate locate : no match found'
		return v:false
	endif
	call wheel#mandala#blank ('locate')
	let settings = #{ function : 'wheel#line#locate' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#locate(' .. string(pattern) .. ')'
endfun

fun! wheel#frigate#find (...)
	" Find files in current directory using **/*pattern* glob
	if a:0 > 0
		let pattern = a:1
	else
		let prompt = 'Find file matching : '
		let pattern = input(prompt)
	endif
	let lines = wheel#perspective#find (pattern)
	if empty(lines)
		echomsg 'wheel frigate find : no match found'
		return v:false
	endif
	call wheel#mandala#blank ('find')
	let settings = #{ function : 'wheel#line#find' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#find(' .. string(pattern) .. ')'
endfun

fun! wheel#frigate#async_find (...)
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
	let settings = #{ function : 'wheel#line#find' }
	" job
	let command = ['find', '.', '-type', 'f', '-path', pattern]
	let settings = #{ mandala_type : 'async_find' }
	if has('nvim')
		let job = wheel#wave#start(command, settings)
	else
		let job = wheel#ripple#start(command, settings)
	endif
	let settings = #{ function : 'wheel#line#find' }
	call wheel#river#template (settings)
	" reload
	let b:wheel_reload = 'wheel#frigate#async_find(' .. string(pattern) .. ')'
endfun

" ---- search inside files

fun! wheel#frigate#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#goto_previous ()
	endif
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#occur (pattern)
	if empty(lines)
		echomsg 'wheel frigate occur : no match found'
		return v:false
	endif
	let filetype = &l:filetype
	call wheel#mandala#blank ('occur')
	let &l:filetype = filetype
	let settings = #{ function : 'wheel#line#occur' }
	call wheel#river#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#occur(' .. string(pattern) .. ')'
endfun

fun! wheel#frigate#grep (...)
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
		echomsg 'wheel frigate grep : no match found'
		return v:false
	endif
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#goto_previous ()
	endif
	let word = substitute(pattern, '\W.*', '', '')
	call wheel#mandala#blank ('grep/' .. word)
	let settings = #{ function : 'wheel#line#grep' }
	call wheel#river#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#grep(' .. string(pattern) .. ', ' .. string(sieve) .. ')'
	" Context menu
	call wheel#boomerang#launch_map ('grep')
	" Useful if we choose edit mode on the context menu
	let b:wheel_settings.pattern = pattern
	let b:wheel_settings.sieve = sieve
	return lines
endfun

fun! wheel#frigate#outline (...)
	" Outline fold headers
	if a:0 > 0
		let mode = a:1
	else
		let prompt = 'Outline mode ? '
		let mode = confirm(prompt, "&Folds\n&Markdown\n&Org mode\nVimwiki", 1)
	endif
	if mode == 1
		let marker = split(&l:foldmarker, ',')[0]
		let grep_ex_command = g:wheel_config.grep
		if grep_ex_command =~ '^:\?grep' && &greppr !~ '^grep'
			let marker = escape(marker, '{')
		endif
		let lines = wheel#frigate#grep (marker)
	elseif mode == 2
		let lines = wheel#frigate#grep ('^#', '\.md$')
	elseif mode == 3
		let lines = wheel#frigate#grep ('^\*', '\.org$')
	elseif mode == 4
		let lines = wheel#frigate#grep ('^=.*=$', '\.wiki$')
	endif
	if ! empty(lines)
		call wheel#mandala#set_type ('outline')
		" reload
		let b:wheel_reload = 'wheel#frigate#outline(' .. string(mode) .. ")"
	endif
endfun
