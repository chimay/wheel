" vim: set ft=vim fdm=indent iskeyword&:

" Multi-line operations on a buffer
"
" Narrow, filter and apply

" Range of original buffer

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:field_separ_bar')
	let s:field_separ_bar = wheel#crystal#fetch('separator/field/bar')
	lockvar s:field_separ_bar
endif

" Operator

fun! wheel#polyphony#operator (argument = '')
	" Operator waiting for a movement or text object to select range
	" Use in a map like this :
	"   map <expr> <mykey> wheel#polyphony#operator()
	let argument = a:argument
	" -- when called to find the rhs of the map
	if argument == ''
		set operatorfunc=wheel#polyphony#operator
		return 'g@'
	endif
	" -- when called to execute wheel#polyphony#operator
	" -- then, argument is 'line', 'block' or 'char'
	let first = line("'[")
	let last = line("']")
	call wheel#polyphony#narrow_file (first, last)
endfun

" Actions

fun! wheel#polyphony#substitute (mode = 'file')
	" Substitute in narrow mandala
	let mode = a:mode
	" -- user input
	let prompt = 'Substitute pattern ? '
	let before = input(prompt)
	let prompt = 'Substitute with ? '
	let after = input(prompt)
	" -- patterns bricks
	let prelude = '\m\%('
	let field = '[^' .. s:field_separ_bar .. ']\+' .. s:field_separ
	let coda = '.*\)\@<='
	" -- check replacing pattern is not present if buffer
	" -- unless back references chars are included
	if after !~ '[&\\]'
		if mode == 'file'
			let columns = prelude .. field .. coda
		elseif mode == 'circle'
			let columns = prelude .. field .. field .. field .. coda
		else
			echomsg 'wheel polyphony substitute : mode must be file or circle'
		endif
		let check = columns .. '\<' .. after .. '\>'
		let found = search(check, 'nw')
		if found > 0
			let prompt = 'Replacing pattern ' .. after .. ' found in buffer. Continue ?'
			let continue = confirm(prompt, "&Yes\n&No", 2)
			if continue == 2
				return v:false
			endif
		endif
	endif
	" -- skip non-content columns
	if mode == 'file'
		let columns = prelude .. field .. coda
	elseif mode == 'circle'
		let columns = prelude .. field .. field .. field .. coda
	endif
	let before = columns .. before
	" -- escape separator of substitution
	let before = escape(before, '/')
	let after = escape(after, '/')
	" -- run substitution
	let runme = 'silent %substitute/' .. before .. '/' .. after .. '/g'
	execute runme
	return v:true
endfun

fun! wheel#polyphony#append (mode = 'below')
	" Append a line in narrow file mandala
	let mode = a:mode
	let mandala_linum = line('.')
	if mode == 'above'
		let mandala_linum -= 1
	endif
	let mandala_linum = max([mandala_linum, 2])
	let columns = 'added' .. s:field_separ
	call append(mandala_linum, columns)
	let mandala_linum += 1
	call cursor(mandala_linum, 1)
	startinsert!
endfun

fun! wheel#polyphony#duplicate (mode = 'below')
	" Duplicate a line in narrow file mandala
	let mode = a:mode
	let mandala_linum = line('.')
	let fields = split(getline('.'), s:field_separ)
	let length = len(fields)
	if length > 1
		let content = fields[1]
	else
		let content = ''
	endif
	if mode == 'above'
		let mandala_linum -= 1
	endif
	let mandala_linum = max([mandala_linum, 2])
	let columns = 'added' .. s:field_separ .. content
	call append(mandala_linum, columns)
	let mandala_linum += 1
	call cursor(mandala_linum, 1)
endfun

" Propagate mandala changes -> original buffer(s)

fun! wheel#polyphony#harmony ()
	" Write function for shape#narrow_file
	let bufnum = b:wheel_related_buffer
	if bufnum == 'unknown'
		return v:false
	endif
	let linelist = getline(2, '$')
	let mandala_num = 2
	let shift = 0
	for line in linelist
		let fields = split(line, s:field_separ)
		let length = len(fields)
		let object = fields[0]
		if length > 1
			let content = fields[1]
		else
			let content = ''
		endif
		if object == 'added'
			" added line
			let shift += 1
			let newnum = linum + shift
			let newline = newnum .. s:field_separ .. content
			call setline(mandala_num, newline)
			call appendbufline(bufnum, newnum - 1, content)
		else
			" unchanged or modified line
			let linum = str2nr(object)
			let newnum = linum + shift
			let newline = newnum .. s:field_separ .. content
			call setline(mandala_num, newline)
			call setbufline(bufnum, newnum, content)
		endif
		let mandala_num += 1
	endfor
	setlocal nomodified
	return v:true
endfun

fun! wheel#polyphony#counterpoint ()
	" Write function for shape#narrow_circle
	let linelist = getline(2, '$')
	for line in linelist
		let fields = split(line, s:field_separ)
		let length = len(fields)
		let bufnum = str2nr(fields[0])
		if ! bufloaded(bufnum)
			call bufload(bufnum)
		endif
		let linum = str2nr(fields[1])
		if length > 3
			let content = fields[3]
		else
			let content = ''
		endif
		call setbufline(bufnum, linum, content)
	endfor
	setlocal nomodified
	return v:true
endfun

" Mandalas

fun! wheel#polyphony#filter_maps ()
	" Define local filter maps
	" normal mode
	nnoremap <silent> <buffer> <ins> ggA
	nnoremap <silent> <buffer> <m-i> ggA
	nnoremap <silent> <buffer> <cr> ggA
	" insert mode
	inoremap <silent> <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
endfun

fun! wheel#polyphony#input_history_maps ()
	" Define local input history maps
	" Use M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <M-p> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <cmd>call wheel#scroll#newer()<cr>
	" M-r / M-s : next / prev matching line
	inoremap <buffer> <M-r> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <cmd>call wheel#scroll#filtered_newer()<cr>
endfun

fun! wheel#polyphony#action_maps (mode = 'file')
	" Define local action maps
	let mode = a:mode
	exe "nnoremap <buffer> <m-s> <cmd>call wheel#polyphony#substitute('" .. mode .. "')<cr>"
	if mode == 'file'
		exe "nnoremap <buffer> o <cmd>call wheel#polyphony#append('below')<cr>"
		exe "nnoremap <buffer> O <cmd>call wheel#polyphony#append('above')<cr>"
		exe "nnoremap <buffer> <m-y> <cmd>call wheel#polyphony#duplicate('below')<cr>"
		exe "nnoremap <buffer> <m-z> <cmd>call wheel#polyphony#duplicate('above')<cr>"
	endif
endfun

fun! wheel#polyphony#narrow_file (...) range
	" Lines matching pattern in current file
	call wheel#mandala#related ()
	if a:0 > 1
		let first = a:1
		let last = a:2
	else
		let first = a:firstline
		let last = a:lastline
	endif
	if first == last
		" assume the user does not launch it just for one line
		let first = 1
		let last = line('$')
	endif
	let bufnum = bufnr('%')
	let filename = bufname(bufnum)
	let filename = fnamemodify(filename, ':t')
	let lines = wheel#perspective#narrow_file (first, last)
	call wheel#mandala#open ('narrow/file/' .. filename)
	let &filetype = getbufvar(b:wheel_related_buffer, '&filetype')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#filter_maps ()
	call wheel#polyphony#input_history_maps ()
	let settings = #{ action : function('wheel#line#narrow_file'), bufnum : b:wheel_related_buffer}
	call wheel#sailing#maps (settings)
	call wheel#polyphony#action_maps ('file')
	call wheel#shape#write ('wheel#polyphony#harmony')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#polyphony#narrow_file('" .. first .. "', '" .. last .. "')"
endfun

fun! wheel#polyphony#narrow_circle (...)
	" Lines matching pattern in all circle files
	" Like grep but with filter & edit
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Narrow circle files with pattern : ')
	endif
	if a:0 > 1
		let sieve = a:2
	else
		let sieve = '\m.'
	endif
	let lines = wheel#perspective#narrow_circle (pattern, sieve)
	let word = substitute(pattern, '\W.*', '', '')
	call wheel#mandala#open ('narrow/circle/' .. word)
	call wheel#mandala#common_maps ()
	call wheel#polyphony#filter_maps ()
	call wheel#polyphony#input_history_maps ()
	let settings = {'action' : function('wheel#line#narrow_circle')}
	call wheel#sailing#maps (settings)
	call wheel#polyphony#action_maps ('circle')
	call wheel#shape#write ('wheel#polyphony#counterpoint')
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = "wheel#polyphony#narrow_circle('" .. pattern .. "', '" .. sieve .. "')"
	echomsg 'adding or removing lines is not supported.'
endfun
