" vim: set ft=vim fdm=indent iskeyword&:

" Teapot
"
" Filter aspect of mandalas

" helpers

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

" global index of visible in line in b:wheel_lines

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

fun! wheel#teapot#prompt ()
	" Return prompt string
	if wheel#cuboctahedron#is_writable ()
		return g:wheel_config.display.prompt_writable
	else
		return g:wheel_config.display.prompt
	endif
endfun

fun! wheel#teapot#set_prompt (content = '')
	" Add prompt at first line if not already there
	" Optional argument :
	"   - line content, as string or word list
	"   - default : empty
	let content = a:content
	if type(content) == v:t_list
		let content = join(content)
	endif
	let mandala_prompt = wheel#teapot#prompt ()
	let pattern = '\m^' .. mandala_prompt
	if content !~ '\m^' .. mandala_prompt
		let content = mandala_prompt .. content
	endif
	call wheel#mandala#pre_edit ()
	call setline(1, content)
	call wheel#mandala#post_edit ()
endfun

fun! wheel#teapot#without_prompt (...)
	" Return line content without prompt
	" Optional argument :
	"   - line content, as string or word list
	"   - default : first line content, except prompt
	if a:0 > 0
		let content = a:1
		if type(content) == v:t_list
			let content = join(content)
		endif
	else
		let content = getline(1)
	endif
	let mandala_prompt = wheel#teapot#prompt ()
	let pattern = '\m^' .. mandala_prompt
	let content = substitute(content, pattern, '', '')
	return content
endfun

fun! wheel#teapot#wordlist ()
	" Return words of filtering first line, without prompt
	let mandala_prompt = wheel#teapot#prompt ()
	let pattern = '\m^' .. mandala_prompt
	let words = getline(1)
	let words = substitute(words, pattern, '', '')
	let words = split(words)
	return words
endfun

" run filter

fun! wheel#teapot#goto_filter_line (mode = 'normal')
	" Go to filter line
	" Optional argument mode :
	"   - normal : end in normal mode
	"   - insert : end in insert mode
	let mode = a:mode
	let mode = wheel#gear#long_mode (mode)
	call cursor(1, 1)
	normal! $
	call wheel#mandala#pre_edit ()
	if mode == 'insert'
		" ! means insert at the end of line
		startinsert!
	endif
endfun

fun! wheel#teapot#filter ()
	" Filter : keep only lines matching words of first line
	let words = wheel#teapot#wordlist ()
	call wheel#cuboctahedron#update_var_lines ()
	if empty(words)
		let lines = b:wheel_lines
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
	else
		let matrix = wheel#kyusu#gaiwan ()
		let indexes = matrix[0]
		let lines = matrix[1]
		let b:wheel_filter.words = words
		let b:wheel_filter.indexes = indexes
		let b:wheel_filter.lines = lines
	endif
	call wheel#mandala#pre_edit ()
	call wheel#mandala#replace (lines, 'prompt-first')
	call wheel#pencil#show ()
	call wheel#mandala#post_edit ()
	return v:true
endfun

" clear filter

fun! wheel#teapot#clear ()
	" Filter : keep only lines matching words of first line
	let words = wheel#teapot#wordlist ()
	if ! empty(words)
		let lines = b:wheel_lines
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
	endif
	call wheel#teapot#set_prompt()
	call wheel#mandala#replace (lines, 'prompt-first')
	call wheel#pencil#show ()
endfun

" all lines, unfiltered and without selection mark

fun! wheel#teapot#all_lines ()
	" Return all, unfiltered, lines
	return b:wheel_lines
endfun

" mappings

fun! wheel#teapot#wrapper (key, angle = 'no-angle', mode = 'normal')
	" Filter wrapper for mappings
	" Optional argument :
	"   - angle :
	"     - no-angle : plain key
	"     - with-angle, or '>' : special key -> "\<key>"
	"   - mode : normal or insert mode at the end
	let key = a:key
	let angle = a:angle
	let mode = a:mode
	let mode = wheel#gear#long_mode (mode)
	if angle == 'with-angle' || angle == '>'
		execute 'let key =' '"\<' .. key .. '>"'
	endif
	if mode == 'insert'
		execute 'normal! i' .. key
		call wheel#teapot#filter ()
		call cursor(1, col('$'))
		" to continue editing
		call wheel#mandala#pre_edit ()
		" ! = insert at the end of line
		"startinsert!
	else
		execute 'normal!' key
		call wheel#teapot#filter ()
		stopinsert
		echomsg line('$')
		if line('$') > 1
			call cursor(2, 1)
		endif
	endif
endfun

fun! wheel#teapot#ctrl_u ()
	" Ctrl-U on filter line
	let linum = line('.')
	if linum != 1
		return
	endif
	let mandala_prompt = wheel#teapot#prompt ()
	call wheel#teapot#set_prompt ()
	call wheel#teapot#filter()
endfun

fun! wheel#teapot#mappings ()
	" Define filter maps & set property
	" -- filter property
	let b:wheel_nature.has_filter = v:true
	" -- normal mode
	let nmap = 'nnoremap <buffer>'
	let goto_filter = 'wheel#teapot#goto_filter_line'
	exe nmap 'i     <cmd>call' goto_filter "('i')<cr>"
	exe nmap 'a     <cmd>call' goto_filter "('i')<cr>"
	exe nmap '<m-i> <cmd>call' goto_filter "('i')<cr>"
	exe nmap '<ins> <cmd>call' goto_filter "('i')<cr>"
	" -- insert mode
	let imap = 'inoremap <buffer>'
	let wrapper = 'wheel#teapot#wrapper'
	exe imap '<space> <cmd>call' wrapper "('space', '>', 'i')<cr>"
	exe imap '<c-w>   <cmd>call' wrapper "('c-w', '>', 'i')<cr>"
	exe imap '<cr>    <cmd>call' wrapper "('c-w', '>', 'n')<cr>"
	inoremap <silent> <buffer> <c-u> <cmd>call wheel#teapot#ctrl_u()<cr>
	inoremap <silent> <buffer> <esc> <esc>:call wheel#teapot#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
endfun
