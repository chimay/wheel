" vim: set ft=vim fdm=indent iskeyword&:

" Filter aspect of mandalas

" helpers

if ! exists('s:mandala_prompt')
	let s:mandala_prompt = wheel#crystal#fetch('mandala/prompt')
	lockvar s:mandala_prompt
endif

fun! wheel#teapot#has_filter ()
	" Whether mandala has filter in first line, false otherwise
	return b:wheel_nature.has_filter
endfun

fun! wheel#teapot#is_filtered ()
	" Whether mandala is filtered
	return ! empty(b:wheel_filter.words)
endfun

fun! wheel#teapot#first_data_line ()
	" First data line
	" Return 1 if mandala has no filter, 2 otherwise
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

" filter line

fun! wheel#teapot#prompt (...)
	" Add prompt at first line if not already there
	" Optional argument :
	"   - line content after prompt
	"   - default : first line content, except prompt
	if a:0 > 0
		let content = a:1
		if type(content) == v:t_list
			let content = join(content)
		endif
	else
		let content = getline(1)
	endif
	if content !~ '\m^' .. s:mandala_prompt
		let content = s:mandala_prompt .. content
	endif
	call setline(1, content)
endfun

fun! wheel#teapot#wordlist ()
	" Return words of filtering first line, except prompt
	let pattern = '\m^' .. s:mandala_prompt
	let words = getline(1)
	let words = substitute(words, pattern, '', '')
	return split(words)
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
	let words = wheel#teapot#wordlist ()
	if empty(words)
		let lines = b:wheel_lines
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
	else
		let matrix = wheel#kyusu#indexes_and_lines ()
		let indexes = matrix[0]
		let lines = matrix[1]
		let b:wheel_filter.words = words
		let b:wheel_filter.indexes = indexes
		let b:wheel_filter.lines = lines
	endif
	call wheel#mandala#replace (lines, 'keep-first')
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

" mappings

fun! wheel#teapot#ctrl_u ()
	" Ctrl-U on filter line
	let linum = line('.')
	if linum != 1
		return v:false
	endif
	call setline(1, s:mandala_prompt)
	call wheel#teapot#filter('insert')
endfun

fun! wheel#teapot#mappings ()
	" Define filter maps & set property
	" -- filter property
	let b:wheel_nature.has_filter = v:true
	" -- normal mode
	nnoremap <silent> <buffer> i <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	nnoremap <silent> <buffer> a <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	" -- insert mode
	inoremap <silent> <buffer> <space> <space><esc>:call wheel#teapot#filter('insert')<cr>
	inoremap <silent> <buffer> <c-w> <c-w><esc>:call wheel#teapot#filter('insert')<cr>
	inoremap <silent> <buffer> <c-u> <esc>:call wheel#teapot#ctrl_u()<cr>
	inoremap <silent> <buffer> <cr> <esc>:call wheel#teapot#filter()<cr>
	inoremap <silent> <buffer> <esc> <esc>:call wheel#teapot#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
endfun
