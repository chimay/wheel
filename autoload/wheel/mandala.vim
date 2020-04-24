" vim: ft=vim fdm=indent:

" Generic Wheel Buffers

" Search, Filter
" Select
" Trigger action

" Special Buffer
" A mandala is made of lines, like a buffer

" Script vars

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

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
	"call append(1, content)
	" Cannot use setline or append : does not work with yanks
	put =content
	call cursor(1,1)
endfun

fun! wheel#mandala#replace (content, ...)
	" Replace buffer lines with content
	" Optional argument handle the first line filtering input :
	" - keep : keep input
	" - blank : blank input
	" - delete : delete first line
	if a:0 > 0
		let first = a:1
	else
		let first = 'keep'
	endif
	let position = getcurpos()
	let content = a:content
	if exists('*deletebufline')
		call deletebufline('%', 2, '$')
	else
		2,$ delete _
	endif
	" Cannot use setline or append : does not work with yanks
	put =content
	if first == 'blank'
		call setline(1, '')
	elseif first == 'delete'
		1 delete _
	endif
	silent 2,$ global /^$/ delete _
	setlocal nomodified
	call wheel#gear#restore_cursor (position, 1)
endfun

fun! wheel#mandala#close ()
	" Close the wheel buffer
	" Go to alternate buffer if only one window
	if winnr('$') > 1
		quit
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
	call wheel#mandala#replace(lines)
	if mode == 'normal'
		if line('$') > 1
			call cursor(2, 1)
		endif
	elseif mode == 'insert'
		call cursor(1, 1)
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
	setlocal bufhidden=wipe
	let &filetype = a:type
endfun

fun! wheel#mandala#yank_options ()
	" Set local yank options
	setlocal nowrap
endfun

" Maps

fun! wheel#mandala#common_maps ()
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

fun! wheel#mandala#navigation_maps (settings)
	" Define local navigationation maps
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
	" Context menu
	nnoremap <buffer> <tab> :call wheel#boomerang#menu('navigation')<cr>
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
	" Define reorder autocommands
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
	" Define reorganize autocommands
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
	let &foldmarker = s:fold_markers
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
	else
		let level = 'none'
	endif
	let marker = split(&foldmarker, ',')[0]
	let pattern = '\m' . marker . '[12]'
	let repl = ':: ' . level
	let line = substitute(line, pattern, repl, '')
	let text = line . ' :: ' . numlines . ' lines ' . v:folddashes
	return text
endfun

" Templates

fun! wheel#mandala#template (...)
	" Templates
	if a:0 > 0
		let type = a:1
	else
		let type = 'generic'
	endif
	if a:0 > 1
		let settings = a:2
		let b:wheel_settings = settings
	elseif type == 'navigation' || type == 'yank'
		echomsg 'Wheel mandala' type 'template : missing settings'
	endif
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	call wheel#mandala#input_history_maps ()
	" By default, tell wheel#line#coordin it’s not a tree buffer
	" Overridden by folding_options
	setlocal nofoldenable
	if type == 'navigation'
		call wheel#mandala#select_maps ()
		call wheel#mandala#navigation_maps (settings)
	elseif type == 'yank'
		call wheel#mandala#yank_options ()
		call wheel#mandala#yank_maps (settings.mode)
	endif
endfun
