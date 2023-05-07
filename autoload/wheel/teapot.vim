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
	" First data line number
	" Return line 1 if mandala has no filter, line 2 otherwise
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
	let wordlist = getline(1)
	let wordlist = substitute(wordlist, pattern, '', '')
	let wordlist = split(wordlist)
	return wordlist
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
		call wheel#origami#close ()
	else
		call wheel#scroll#record(wordlist)
		let matrix = wheel#kyusu#gaiwan (wordlist)
		let indexes = matrix[0]
		let lines = matrix[1]
		let b:wheel_filter.words = wordlist
		let b:wheel_filter.indexes = indexes
		let b:wheel_filter.lines = lines
		call wheel#origami#open ()
	endif
	call wheel#mandala#replace (lines, 'prompt-first', lock)
	call wheel#pencil#show (lock)
	call wheel#mandala#post_edit (lock)
	return v:true
endfun

" ---- clear filter

fun! wheel#teapot#reset (update = 'update', lock = 'lock')
	" Reset filter
	let update = a:update
	let lock = a:lock
	if update ==# 'update'
		call wheel#polyphony#update_var_lines ()
	endif
	let lines = b:wheel_lines
	let b:wheel_filter.words = []
	let b:wheel_filter.indexes = []
	let b:wheel_filter.lines = []
	call wheel#mandala#replace (lines, 'empty-prompt-first', lock)
	call wheel#pencil#show (lock)
	call wheel#origami#close ()
	call wheel#origami#view_cursor ()
endfun

" ---- lines

fun! wheel#teapot#filter_to_default_line ()
	" If on filter line, put the cursor on line 2 if possible
	let is_filtered = wheel#teapot#is_filtered ()
	let has_filter = wheel#teapot#has_filter()
	if is_filtered && line('$') == 1
		call wheel#teapot#reset()
	endif
	if has_filter && line('$') == 1
		echomsg 'wheel teapot filter_to_default_line : mandala is empty'
		return v:false
	endif
	let cur_line = line('.')
	let last_line = line('$')
	if has_filter && cur_line == 1 && last_line > 1
		call cursor(2, 1)
	endif
	call wheel#origami#view_cursor ()
	return v:true
endfun

fun! wheel#teapot#all_lines ()
	" Return all, unfiltered, unmarked lines
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
		"execute 'let key =' '"\<' .. key .. '>"'
		let fullkey = '<' .. key .. '>'
		let key = wheel#gear#reverse_keytrans(fullkey)
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
	execute nmap 'i     <cmd>call' goto_filter "('i')<cr>"
	execute nmap 'a     <cmd>call' goto_filter "('i')<cr>"
	execute nmap '<m-i> <cmd>call' goto_filter "('i')<cr>"
	execute nmap '<ins> <cmd>call' goto_filter "('i')<cr>"
	execute nmap 'cc    <cmd>call wheel#teapot#normal_cc()<cr>'
	execute nmap 'dd    <cmd>call wheel#teapot#reset()<cr>'
	" ---- insert mode
	let imap = 'inoremap <buffer>'
	execute imap '<space> <cmd>call' wrapper "('space', '>', 'i')<cr>"
	execute imap '<c-w>   <cmd>call' wrapper "('c-w', '>', 'i')<cr>"
	execute imap '<c-u>   <cmd>call' wrapper "('c-u', '>', 'i')<cr>"
	execute imap '<cr>    <cmd>call' wrapper "('cr', '>', 'n')<cr>"
	execute imap '<esc>   <cmd>call' wrapper "('esc', '>', 'n')<cr>"
	execute imap '<c-k>   <cmd>call wheel#teapot#insert_ctrl_k()<cr>'
	" <c-c> is not mapped, in case you need a regular escape
	inoremap <buffer> <m-f> <c-o>w
	inoremap <buffer> <m-b> <c-o>b
	inoremap <buffer> <c-a> <cmd>call wheel#teapot#insert_ctrl_a()<cr>
	inoremap <buffer> <c-e> <c-o>$
endfun
