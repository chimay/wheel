" vim: ft=vim fdm=indent:

" Special Wheel Buffers

" Search, Filter
" Select
" Trigger action

" Special Buffer
" A mandala is made of lines, like a buffer

" Helpers

fun! wheel#mandala#open (...)
	" Open a wheel buffer
	if a:0 > 0
		let type = a:1
	else
		let type = 'wheel'
	endif
	new
	call wheel#mandala#common_options (type)
endfun

fun! wheel#mandala#fill (content)
	" Fill buffer with content
	" Content can be :
	" - a monoline string
	" - a list of lines
	let content = a:content
	if exists('*appendbufline')
		call appendbufline('%', 1, content)
	else
		put =content
	endif
	setlocal nomodified
	call cursor(1,1)
endfun

fun! wheel#mandala#replace (content, ...)
	" Replace buffer lines with content
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'all'
	endif
	let content = a:content
	if mode == 'all'
		let begin = 1
	elseif mode == 'not_first'
		let begin = 2
	endif
	if exists('*deletebufline')
		call deletebufline('%', begin, '$')
	else
		exe begin . ',$ delete _'
	endif
	" Cannot use appendbufline : does not work with yanks
	put =content
	setlocal nomodified
	if line('$') > 1
		2
	endif
endfun

fun! wheel#mandala#close ()
	" Close the wheel buffer
	" Go to alternate buffer if only one window
	if winnr('$') > 1
		quit!
	else
		buffer #
	endif
endfun

fun! wheel#mandala#previous ()
	" Go to previous window
	" Go to alternate buffer if only one window
	if winnr('$') > 1
		wincmd p
	else
		buffer #
	endif
endfun

fun! wheel#mandala#wrap_up ()
	" Line up, or line 1 -> end of file
	if line('.') == 1
		call cursor(line('$'), 1)
	else
		normal! k
	endif
endfun

fun! wheel#mandala#wrap_down ()
	" Line down, or line end of file -> 1
	if line('.') == line('$')
		call cursor(1, 1)
	else
		normal! j
	endif
endfun

fun! wheel#mandala#filter (...)
	" Keep lines matching words of first line
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'normal'
	endif
	let lines = wheel#line#filter ()
	call wheel#mandala#replace(lines, 'not_first')
	if mode == 'insert'
		call cursor(1,1)
		startinsert!
	endif
endfu

" Options

fun! wheel#mandala#common_options (type)
	" Set local common options
	setlocal cursorline
	setlocal nobuflisted
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
	let &filetype = a:type
endfun

fun! wheel#mandala#yank_options ()
	" Set local yank options
	setlocal nowrap
endfun

" Maps

fun! wheel#mandala#common_maps (...)
	" Define local common maps
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	nnoremap <buffer> j :call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> k :call wheel#mandala#wrap_up()<cr>
	nnoremap <buffer> <down> :call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> <up> :call wheel#mandala#wrap_up()<cr>
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps
	" Normal mode
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	" Insert mode
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter('insert')<cr><space>
	inoremap <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular esc
endfun

fun! wheel#mandala#input_history_maps ()
	" Define local input history maps
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <up> <esc>:call wheel#scroll#older()<cr>
	inoremap <buffer> <down> <esc>:call wheel#scroll#newer()<cr>
	inoremap <buffer> <M-p> <esc>:call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <esc>:call wheel#scroll#newer()<cr>
	" PageUp / PageDown & C-r / C-s : next / prev matching line
	inoremap <buffer> <PageUp> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <PageDown> <esc>:call wheel#scroll#filtered_newer()<cr>
	inoremap <buffer> <M-r> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <esc>:call wheel#scroll#filtered_newer()<cr>
endfun

fun! wheel#mandala#select_maps ()
	" Define local toggle selection maps
	nnoremap <buffer> <space> :call wheel#line#toggle()<cr>
endfun

fun! wheel#mandala#switch_maps (dict)
	" Define local switch maps
	let dict = copy(a:dict)
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#line#switch('
	let post = ')<cr>'
	" Close after switch
	let dict.close = v:true
	let dict.target = 'within'
	exe map . '<cr>' . pre . string(dict) . post
	let dict.target = 'tab'
	exe map . 't' . pre . string(dict) . post
	let dict.target = 'horizontal_split'
	exe map . 's' . pre . string(dict) . post
	let dict.target = 'vertical_split'
	exe map . 'v' . pre . string(dict) . post
	let dict.target = 'horizontal_golden'
	exe map . 'S' . pre . string(dict) . post
	let dict.target = 'vertical_golden'
	exe map . 'V' . pre . string(dict) . post
	" Leave open after switch
	let dict.close = v:false
	let dict.target = 'within'
	exe map . 'g<cr>' . pre . string(dict) . post
	let dict.target = 'tab'
	exe map . 'gt' . pre . string(dict) . post
	let dict.target = 'horizontal_split'
	exe map . 'gs' . pre . string(dict) . post
	let dict.target = 'vertical_split'
	exe map . 'gv' . pre . string(dict) . post
	let dict.target = 'horizontal_golden'
	exe map . 'gS' . pre . string(dict) . post
	let dict.target = 'vertical_golden'
	exe map . 'gV' . pre . string(dict) . post
endfun

fun! wheel#mandala#yank_maps (mode)
	" Define local yank maps
	if a:mode == 'list'
		nnoremap <buffer> <cr> :call wheel#line#paste_list ('close')<cr>
		nnoremap <buffer> <tab> :call wheel#line#paste_list ('open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_list ('open')<cr>
	elseif a:mode == 'plain'
		nnoremap <buffer> <cr> :call wheel#line#paste_plain ('close')<cr>
		nnoremap <buffer> <tab> :call wheel#line#paste_plain ('open')<cr>
		nnoremap <buffer> p :call wheel#line#paste_plain ('open')<cr>
		" Visual mode
		vnoremap <buffer> <cr> :<c-u>call wheel#line#paste_visual('close')<cr>
		vnoremap <buffer> <tab> :<c-u>call wheel#line#paste_visual('open')<cr>
		vnoremap <buffer> p :<c-u>call wheel#line#paste_visual('open')<cr>
	endif
endfun

" Write commands

fun! wheel#mandala#reorder_write (level)
	" Define reorder autocommands in wheel buffer
	setlocal buftype=
	let autocommand = "autocmd BufWriteCmd <buffer> call wheel#cuboctahedron#reorder ('"
	let autocommand .= a:level . "')"
	" Need a name when writing, even with BufWriteCmd
	file /wheel/reorder
	augroup wheel
		autocmd!
		exe autocommand
	augroup END
endfun

fun! wheel#mandala#reorganize_write ()
	" Define reorganize autocommands in wheel buffer
	setlocal buftype=
	let autocommand = "autocmd BufWriteCmd <buffer> call wheel#cuboctahedron#reorganize ()"
	" Need a name when writing, even with BufWriteCmd
	file /wheel/reorganize
	augroup wheel
		autocmd!
		exe autocommand
	augroup END
endfun

" Folding

fun! wheel#mandala#folding_options ()
	" Folding options for wheel buffers
	setlocal foldenable
	setlocal foldminlines=1
	setlocal foldlevel=0
	setlocal foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
	setlocal foldclose=
	setlocal foldmethod=marker
	setlocal foldmarker=>,<
	setlocal foldcolumn=2
	setlocal foldtext=wheel#mandala#folding_text()
endfun

fun! wheel#mandala#folding_text ()
	" Folding text for wheel buffers
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	if v:foldlevel == 1
		let level = 'torus'
	elseif v:foldlevel == 2
		let level = 'circle'
	elseif v:foldlevel == 3
		let level = 'location'
	endif
	let marker = split(&foldmarker, ',')[0]
	let pattern = '\m' . marker . '[12]'
	let repl = ':: ' . level
	let line = substitute(line, pattern, repl, '')
	let text = line . ' :: ' . numlines . ' lines ' . v:folddashes
	return text
endfun

" Templates

fun! wheel#mandala#template (type)
	" Templates
	if a:type == 'switch'
		call wheel#mandala#common_maps ()
		call wheel#mandala#filter_maps ()
		call wheel#mandala#input_history_maps ()
		call wheel#mandala#select_maps ()
		" By default, tell whee#line#coordin it’s not a tree buffer
		" Overridden by folding_options
		setlocal nofoldenable
	elseif a:type == 'yank'
		call wheel#mandala#common_maps ()
		call wheel#mandala#filter_maps ()
		call wheel#mandala#input_history_maps ()
		call wheel#mandala#yank_options ()
		" By default, tell whee#line#coordin it’s not a tree buffer
		" Overridden by folding_options
		setlocal nofoldenable
	endif
endfun

" Switch

fun! wheel#mandala#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-switch-' . level)
	call wheel#mandala#template ('switch')
	let dict = {'level' : level}
	call wheel#mandala#switch_maps (dict)
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		let lines = upper.glossary
		call wheel#mandala#fill(lines)
	else
		echomsg 'Wheel mandala switch : empty or incomplete' level
	endif
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to switch to
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-location-index')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#helix')}
	call wheel#mandala#switch_maps (dict)
	let lines = wheel#helix#locations ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to switch to
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-circle-index')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#grid')}
	call wheel#mandala#switch_maps (dict)
	let lines = wheel#helix#circles ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#tree ()
	" Choose an element in the wheel tree
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tree')
	call wheel#mandala#template ('switch')
	call wheel#mandala#folding_options ()
	let dict = {'action' : function('wheel#line#tree')}
	call wheel#mandala#switch_maps (dict)
	let lines = wheel#helix#tree ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-history')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#history')}
	call wheel#mandala#switch_maps (dict)
	let lines = wheel#pendulum#sorted ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#grep (...)
	" Grep results
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Search in circle files for pattern ? ')
	endif
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-grep')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#grep')}
	call wheel#mandala#switch_maps (dict)
		call wheel#vector#grep(pattern)
	let lines = wheel#vector#quickfix ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#outline ()
	" Outline fold headers
	let marker = split(&foldmarker, ',')[0]
	if &grepprg !~ '^grep'
		let marker = escape(marker, '{')
	endif
	call wheel#mandala#grep (marker)
endfun

fun! wheel#mandala#attic ()
	" Most recenty used files
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-mru')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#attic')}
	call wheel#mandala#switch_maps (dict)
	let lines = wheel#attic#sorted ()
	call wheel#mandala#fill(lines)
endfun

fun! wheel#mandala#locate ()
	" Search files using locate
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-locate')
	call wheel#mandala#template ('switch')
	let dict = {'action' : function('wheel#line#locate')}
	call wheel#mandala#switch_maps (dict)
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

" Yank wheel

fun! wheel#mandala#yank (mode)
	" Choose a yank wheel element to paste
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-yank-' . a:mode)
	call wheel#mandala#template('yank')
	call wheel#mandala#yank_maps (a:mode)
	let lines = wheel#codex#lines (a:mode)
	" Appendbufline does not work with lists of list
	put =lines
	setlocal nomodified
	call cursor(1,1)
endfun

" Reorder

fun! wheel#mandala#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder-' . level)
	call wheel#mandala#common_maps ()
	call wheel#mandala#reorder_write (level)
	let upper = wheel#referen#upper(level)
	if ! empty(upper) && ! empty(upper.glossary)
		let lines = upper.glossary
		call wheel#mandala#fill(lines)
		global /^$/delete
		setlocal nomodified
	else
		echomsg 'Wheel mandala reorder : empty or incomplete' level
	endif
endfun

" Reorganize

fun! wheel#mandala#reorganize ()
	" Reorganize the wheel tree
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorganize')
	call wheel#mandala#common_maps ()
	call wheel#mandala#reorganize_write ()
	call wheel#mandala#folding_options ()
	let lines = wheel#helix#reorganize ()
	call wheel#mandala#fill(lines)
	global /^$/delete
	setlocal nomodified
endfun
