" vim: ft=vim fdm=indent:

" Generic Wheel Buffers
"
" A mandala is made of lines, like a buffer
"
" Sane defaults : may be overriden by more specific buffers
"
" Search, Filter
" Select
" Trigger action

" Script vars

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" Buffer

fun! wheel#mandala#push (...)
	" Push new wheel buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	let buffers = g:wheel_shelve.buffers
	call wheel#mandala#check ()
	" First one
	if empty(buffers)
		enew
		let bufnum = bufnr('%')
		call insert(buffers, bufnum)
		call wheel#mandala#common_maps ()
		if mode == 'goback'
			silent buffer #
		endif
		echomsg 'Buffer' bufnum 'added'
		return v:true
	endif
	" Current buffer
	let current = bufnr('%')
	if index(buffers, current) >= 0
		let in_wheel_buf = v:true
	else
		let in_wheel_buf = v:false
	endif
	" Saved buffer
	let saved = buffers[0]
	" New buffer
	enew
	let new_buf = bufnr('%')
	if new_buf == saved
		echomsg 'Wheel mandala push : buffer' new_buf 'already in stack'
		return v:false
	endif
	" Push
	call insert(buffers, new_buf)
	call wheel#mandala#common_maps ()
	if ! in_wheel_buf
		silent buffer #
	endif
	echomsg 'Buffer' saved 'saved'
	return v:true
endfun

fun! wheel#mandala#pop ()
	" Pop wheel buffer
	call wheel#mandala#check ()
	let buffers = g:wheel_shelve.buffers
	" Do not pop empty stack
	if empty(buffers)
		echomsg 'wheel mandala pop : no more buffer left'
		return v:false
	endif
	" Do not pop one element stack
	if len(buffers) == 1
		echomsg 'Wheel mandala pop :' buffers[0] 'is the last remaining wheel buffer'
		return v:false
	endif
	" Pop
	let removed = wheel#chain#pop(buffers)
	let current = bufnr('%')
	if current == removed || index(buffers, current) >= 0
		let bufnum = buffers[0]
		exe 'silent buffer ' bufnum
	endif
	exe 'silent bwipe ' removed
	echomsg 'Buffer' removed 'removed'
	return removed
endfun

fun! wheel#mandala#recall ()
	" Recall wheel buffer
	call wheel#mandala#check ()
	let buffers = g:wheel_shelve.buffers
	if empty(buffers)
		echomsg 'wheel mandala recall : no more buffer left'
		return v:false
	endif
	let current = bufnr('%')
	let bufnum = buffers[0]
	let winnum =  bufwinnr(bufnum)
	if index(buffers, current) >= 0
		exe 'silent buffer ' bufnum
	elseif winnum < 0
		exe 'silent sbuffer ' . bufnum
	else
		exe winnum . 'wincmd w'
	endif
	return v:true
endfun

fun! wheel#mandala#check ()
	" Check if current wheel buffer
	let buffers = g:wheel_shelve.buffers
	if empty(buffers)
		return
	endif
	let bufnum = buffers[0]
	if ! bufexists(bufnum)
		echomsg 'Wheel mandala check :' bufnum 'deleted'
		call remove(buffers, 0)
	endif
endfun

fun! wheel#mandala#cycle ()
	" Cycle wheel buffers
	let buffers = g:wheel_shelve.buffers
	let buffers = wheel#chain#rotate_left(buffers)
	let g:wheel_shelve.buffers = buffers
	call wheel#mandala#recall ()
endfun

fun! wheel#mandala#open (...)
	" Open a wheel buffer
	if a:0 > 0
		let type = a:1
	else
		let type = 'wheel'
	endif
	if wheel#mandala#recall ()
		1,$ delete _
		call wheel#layer#fresh ()
	else
		new
		call wheel#mandala#push ('rest')
	endif
	call wheel#mandala#common_options (type)
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

fun! wheel#mandala#previous ()
	" Go to previous window, before wheel buffer opening
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
	setlocal bufhidden=
	let &filetype = a:type
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
	" PageUp / PageDown & M-r / M-s : next / prev matching line
	inoremap <buffer> <PageUp> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <PageDown> <esc>:call wheel#scroll#filtered_newer()<cr>
	inoremap <buffer> <M-r> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <esc>:call wheel#scroll#filtered_newer()<cr>
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

" Template

fun! wheel#mandala#template (...)
	" Template with filter & input history
	if a:0 > 0
		let b:wheel_settings = a:1
	endif
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	call wheel#mandala#input_history_maps ()
	" By default, tell wheel#line#coordin it’s not a tree buffer
	" Overridden by folding_options
	setlocal nofoldenable
endfun
