" vim: set ft=vim fdm=indent iskeyword&:

" Filter aspect of mandalas

" helpers

fun! wheel#teapot#has_filter ()
	" Return true if mandala has filter in first line, false otherwise
	return b:wheel_nature.has_filter
endfun

fun! wheel#teapot#is_filtered ()
	" Whether current mandala is filtered
	return ! empty(b:wheel_filter.words)
endfun

fun! wheel#teapot#first_data_line ()
	" First data line is 1 if mandala has no filter, 2 otherwise
	if wheel#teapot#has_filter ()
		return 2
	else
		return 1
	endif
endfun

fun! wheel#teapot#line_index (...)
	" Return index of line number in b:wheel_lines
	" Default : current line number
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let shift = wheel#teapot#first_data_line ()
	let index = linum - shift
	if wheel#teapot#is_filtered ()
		let indexlist = b:wheel_filter.indexes
		return indexlist[index]
	else
		return index
	endif
endfun

" run filter

fun! wheel#teapot#goto_filter_line (mode = 'normal')
	" Go to filter line
	" Optional argument mode :
	"   - normal : end in normal mode
	"   - insert : end in insert mode
	let mode = a:mode
	call cursor(1, 1)
	normal! $
	if mode == 'insert'
		" ! = insert at the end of line
		startinsert!
	endif
endfun

fun! wheel#teapot#filter (mode = 'normal')
	" Filter : keep only lines matching words of first line
	" Optional argument mode :
	"   - normal : end in normal mode
	"   - insert : end in insert mode
	let mode = a:mode
	let matrix = wheel#kyusu#indexes_and_lines ()
	let indexes = matrix[0]
	let lines = matrix[1]
	let b:wheel_filter.words = split(getline(1))
	let b:wheel_filter.indexes = indexes
	let b:wheel_filter.lines = lines
	let update_var_lines = v:false
	call wheel#mandala#replace (lines, 'keep-first', update_var_lines)
	call wheel#pencil#show ()
	if mode == 'normal'
		if line('$') > 1
			call cursor(2, 1)
		endif
	elseif mode == 'insert'
		"call cursor(1, 1)
		" ! = insert at the end of line
		startinsert!
	endif
endfun

" maps

fun! wheel#teapot#filter_maps ()
	" Define local filter maps
	" normal mode
	nnoremap <silent> <buffer> i <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	nnoremap <silent> <buffer> a <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	" insert mode
	inoremap <silent> <buffer> <space> <space><esc>:call wheel#teapot#filter('insert')<cr>
	inoremap <silent> <buffer> <c-w> <c-w><esc>:call wheel#teapot#filter('insert')<cr>
	inoremap <silent> <buffer> <c-u> <c-u><esc>:call wheel#teapot#filter('insert')<cr>
	inoremap <silent> <buffer> <cr> <esc>:call wheel#teapot#filter()<cr>
	inoremap <silent> <buffer> <esc> <esc>:call wheel#teapot#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
endfun
