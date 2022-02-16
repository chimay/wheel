" vim: set ft=vim fdm=indent iskeyword&:

" Teapot
"
" Filter aspect of mandalas

" ---- helpers

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

" ---- global index of visible in line in b:wheel_lines

fun! wheel#teapot#line_index (...)
	" Return index of visible line number in b:wheel_lines
	" Visible line may be filtered
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

" ---- filter line

fun! wheel#teapot#prompt ()
	" Return prompt string
	if wheel#polyphony#is_writable ()
		return g:wheel_config.display.prompt_writable
	else
		return g:wheel_config.display.prompt
	endif
endfun

fun! wheel#teapot#set_prompt (content = '', lock = 'lock')
	" Add prompt at first line if not already there
	" Optional arguments :
	"   - content :
	"     + line content, as string or word list
	"     + default : empty
	"   - lock :
	"     + lock : relock if not writable
	"     + dont-lock : don't lock
	let content = a:content
	let lock = a:lock
	if type(content) == v:t_list
		let content = join(content)
	endif
	let mandala_prompt = wheel#teapot#prompt ()
	let pattern = '\m^' .. mandala_prompt
	if content !~ pattern
		let content = mandala_prompt .. content
	endif
	call wheel#mandala#unlock ()
	call setline(1, content)
	call wheel#mandala#post_edit (lock)
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

" ---- run filter

fun! wheel#teapot#goto_filter_line (mode = 'normal')
	" Go to filter line
	" Optional argument mode :
	"   - normal : end in normal mode
	"   - insert : end in insert mode
	let mode = a:mode
	let mode = wheel#ouroboros#long_mode (mode)
	call cursor(1, 1)
	normal! $
	call wheel#mandala#unlock ()
	if mode ==# 'insert'
		" ! means insert at the end of line
		startinsert!
	endif
endfun

fun! wheel#teapot#filter (update = 'update', lock = 'lock')
	" Filter : keep only lines matching words of first line
	" Optional argument :
	"   - update :
	"     + update : update lines in buffer local variables
	"     + dont-update : don't update lines in variables
	"   - lock :
	"     + lock : relock if not writable
	"     + dont-lock : don't lock
	let update = a:update
	let lock = a:lock
	let wordlist = wheel#teapot#wordlist ()
	if update ==# 'update'
		call wheel#polyphony#update_var_lines ()
	endif
	if empty(wordlist)
		let lines = b:wheel_lines
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
		setlocal foldlevel=0
	else
		call wheel#scroll#record(wordlist)
		let matrix = wheel#kyusu#gaiwan (wordlist)
		let indexes = matrix[0]
		let lines = matrix[1]
		let b:wheel_filter.words = wordlist
		let b:wheel_filter.indexes = indexes
		let b:wheel_filter.lines = lines
		setlocal foldlevel=2
	endif
	call wheel#mandala#replace (lines, 'prompt-first', lock)
	call wheel#pencil#show (lock)
	call wheel#mandala#post_edit (lock)
	return v:true
endfun

fun! wheel#teapot#reset (update = 'update', lock = 'lock')
	" Reset filter
	call wheel#teapot#set_prompt ('', a:lock)
	call wheel#teapot#filter(a:update, a:lock)
endfun

" ---- clear filter

fun! wheel#teapot#clear ()
	" Filter : keep only lines matching words of first line
	let words = wheel#teapot#wordlist ()
	if ! empty(words)
		let lines = b:wheel_lines
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
	endif
	call wheel#mandala#replace (lines)
	call wheel#pencil#show ()
endfun

" all lines, unfiltered and without selection mark

fun! wheel#teapot#all_lines ()
	" Return all, unfiltered, lines
	return b:wheel_lines
endfun

" ---- mappings

fun! wheel#teapot#wrapper (key, angle = 'no-angle', mode = 'normal')
	" Filter wrapper for mappings
	" Optional argument :
	"   - angle :
	"     - no-angle, or '' : plain key
	"     - with-angle, or '>' : special key -> "\<key>"
	"   - mode : normal or insert mode at the end
	let key = a:key
	let angle = a:angle
	let mode = a:mode
	let mode = wheel#ouroboros#long_mode (mode)
	if line('.') != 1
		call cursor(1, 1)
		call cursor(1, col('$'))
	endif
	if angle ==# 'with-angle' || angle ==# '>'
		execute 'let key =' '"\<' .. key .. '>"'
	endif
	call wheel#mandala#unlock ()
	if mode ==# 'insert'
		execute 'normal! i' .. key
		call wheel#teapot#filter ('update', 'dont-lock')
		call cursor(1, col('$'))
	else
		execute 'normal!' key
		call wheel#teapot#filter ()
		stopinsert
		if line('$') > 1
			call cursor(2, 1)
		endif
	endif
endfun

fun! wheel#teapot#normal_cc ()
	" Normal command cc in mandala with filter
	call wheel#teapot#reset ('update', 'dont-lock')
	call cursor(1, 1)
	call cursor(1, col('$'))
	startinsert!
endfun

fun! wheel#teapot#insert_ctrl_a ()
	" Insert ctrl-a : go to begin of line, after prompt
	let prompt = wheel#teapot#prompt ()
	let colnum = len(prompt) + 1
	call cursor(1, 1)
	call cursor(1, colnum)
endfun

fun! wheel#teapot#insert_ctrl_k ()
	" Insert ctrl-k to delete until end of line in mandala with filter
	let line = getline(1)
	let colnum = col('.')
	let before = strpart(line, 0, colnum - 1)
	call wheel#teapot#set_prompt (before, 'dont-lock')
	call wheel#teapot#filter('update', 'dont-lock')
	startinsert!
endfun

fun! wheel#teapot#mappings ()
	" Define filter maps & set property
	" ---- filter property
	let b:wheel_nature.has_filter = v:true
	let goto_filter = 'wheel#teapot#goto_filter_line'
	let wrapper = 'wheel#teapot#wrapper'
	" ---- normal mode
	let nmap = 'nnoremap <buffer>'
	exe nmap 'i     <cmd>call' goto_filter "('i')<cr>"
	exe nmap 'a     <cmd>call' goto_filter "('i')<cr>"
	exe nmap '<m-i> <cmd>call' goto_filter "('i')<cr>"
	exe nmap '<ins> <cmd>call' goto_filter "('i')<cr>"
	exe nmap 'cc    <cmd>call wheel#teapot#normal_cc()<cr>'
	exe nmap 'dd    <cmd>call wheel#teapot#reset()<cr>'
	" ---- insert mode
	let imap = 'inoremap <buffer>'
	exe imap '<space> <cmd>call' wrapper "('space', '>', 'i')<cr>"
	exe imap '<c-w>   <cmd>call' wrapper "('c-w', '>', 'i')<cr>"
	exe imap '<c-u>   <cmd>call' wrapper "('c-u', '>', 'i')<cr>"
	exe imap '<cr>    <cmd>call' wrapper "('c-w', '>', 'n')<cr>"
	exe imap '<esc>   <cmd>call' wrapper "('esc', '>', 'n')<cr>"
	exe imap '<c-k>   <cmd>call wheel#teapot#insert_ctrl_k()<cr>'
	" <c-c> is not mapped, in case you need a regular escape
	inoremap <buffer> <m-f> <c-o>w
	inoremap <buffer> <m-b> <c-o>b
	inoremap <buffer> <c-a> <cmd>call wheel#teapot#insert_ctrl_a()<cr>
	inoremap <buffer> <c-e> <c-o>$
endfun
