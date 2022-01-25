" vim: set ft=vim fdm=indent iskeyword&:

"  Dedicated buffers for non-wheel navigation

fun! wheel#frigate#buffers (scope = 'listed')
	" Buffers
	" To be run before opening the mandala buffer
	" Optional argument scope :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	let scope = a:scope
	let lines = wheel#perspective#buffers (scope)
	if empty(lines)
		echomsg 'wheel sailing buffers : empty result'
		return v:false
	endif
	" mandala buffer
	if scope == 'listed'
		let type = 'buffers'
	elseif scope == 'all'
		let type = 'buffers/all'
	else
		echomsg 'wheel sailing buffers : bad optional argument'
		return []
	endif
	call wheel#mandala#blank (type)
	let settings = {'function' : function('wheel#line#buffers')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" context menu
	call wheel#boomerang#launch_map (type)
	" reload
	let b:wheel_reload = "wheel#frigate#buffers('" .. scope .. "')"
endfun

fun! wheel#frigate#tabwins_tree ()
	" Buffers visible in tree of tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins_tree ()
	if empty(lines)
		echomsg 'wheel sailing tabwins tree : empty result'
		return v:false
	endif
	call wheel#mandala#blank ('tabwins/tree')
	let settings = {'function' : function('wheel#line#tabwins_tree')}
	call wheel#sailing#template (settings)
	call wheel#mandala#folding_options ('tabwins_folding_text')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#tabwins_tree'
	" Context menu
	call wheel#boomerang#launch_map ('tabwins_tree')
endfun

fun! wheel#frigate#tabwins ()
	" Buffers visible in tabs & wins
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#tabwins ()
	if empty(lines)
		echomsg 'wheel sailing tabwins : empty result'
		return v:false
	endif
	call wheel#mandala#blank ('tabwins')
	let settings = {'function' : function('wheel#line#tabwins')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#tabwins'
	" Context menu
	call wheel#boomerang#launch_map ('tabwins')
endfun

" vim lists

fun! wheel#frigate#markers ()
	" Markers
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#previous ()
	endif
	call wheel#sailing#generic('markers')
	" reload
	let b:wheel_reload = 'wheel#frigate#markers'
endfun

fun! wheel#frigate#jumps ()
	" Jumps list
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#previous ()
	endif
	let lines = wheel#perspective#jumps ()
	if empty(lines)
		echomsg 'wheel sailing jumps : empty result'
		return v:false
	endif
	" mandala buffer
	call wheel#mandala#blank ('jumps')
	let settings = {'function' : function('wheel#line#jumps')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#jumps'
endfun

fun! wheel#frigate#changes ()
	" Jumps list
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#previous ()
	endif
	let lines = wheel#perspective#changes ()
	if empty(lines)
		echomsg 'wheel sailing changes : empty result'
		return v:false
	endif
	" mandala buffer
	call wheel#mandala#blank ('changes')
	let settings = {'function' : function('wheel#line#changes')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#frigate#changes'
endfun

fun! wheel#frigate#tags ()
	" Tags file
	call wheel#sailing#generic('tags')
	" reload
	let b:wheel_reload = 'wheel#frigate#tags'
endfun

" search files

fun! wheel#frigate#mru ()
	" Most recenty used files
	call wheel#sailing#generic('mru')
	" reload
	let b:wheel_reload = 'wheel#frigate#mru'
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
		echomsg 'wheel sailing locate : no match found'
		return v:false
	endif
	call wheel#mandala#blank ('locate')
	let settings = {'function' : function('wheel#line#locate')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#frigate#locate('" .. pattern .. "')"
endfun

fun! wheel#frigate#find (...)
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
	if empty(lines)
		echomsg 'wheel sailing find : no match found'
		return v:false
	endif
	call wheel#mandala#blank ('find')
	let settings = {'function' : function('wheel#line#find')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#frigate#find('" .. pattern .. "')"
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
	call wheel#mandala#blank ('async_find')
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
	let b:wheel_reload = "wheel#frigate#async_find('" .. pattern .. "')"
endfun

" search inside files

fun! wheel#frigate#occur (...)
	" Lines matching pattern
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Lines matching pattern : ')
	endif
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#previous ()
	endif
	" To be run before opening the mandala buffer
	let lines = wheel#perspective#occur (pattern)
	if empty(lines)
		echomsg 'wheel sailing occur : no match found'
		return v:false
	endif
	call wheel#mandala#blank ('occur')
	let settings = {'function' : function('wheel#line#occur')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#frigate#occur('" .. pattern .. "')"
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
		echomsg 'wheel sailing grep : no match found'
		return v:false
	endif
	if wheel#cylinder#is_mandala ()
		call wheel#rectangle#previous ()
	endif
	let word = substitute(pattern, '\W.*', '', '')
	call wheel#mandala#blank ('grep/' .. word)
	let settings = {'function' : function('wheel#line#grep')}
	call wheel#sailing#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#frigate#grep('" .. pattern .. "', '" .. sieve .. "')"
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
		let marker = split(&foldmarker, ',')[0]
		let grep_ex_command = g:wheel_config.grep
		if grep_ex_command =~ '^:\?grep' && &grepprg !~ '^grep'
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
		call wheel#mandala#filename ('outline')
		" reload
		let b:wheel_reload = "wheel#frigate#outline('" .. mode .. "')"
	endif
endfun
