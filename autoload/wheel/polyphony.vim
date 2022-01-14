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

" Operator function

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
	let first = line("'[")
	let last = line("']")
	call wheel#shape#narrow_file (first, last)
endfun

" Actions

fun! wheel#polyphony#substitute (mode = 'file')
	" Substitute in narrow mandala
	let mode = a:mode
	let prompt = 'Substitute pattern ? '
	let before = input(prompt)
	let prompt = 'Substitute with ? '
	let after = input(prompt)
	" skip non-content columns
	if mode == 'file'
		let columns = '[^' .. s:field_separ_bar .. ']\+' .. s:field_separ
	elseif mode == 'circle'
		let columns = '[^' .. s:field_separ_bar .. ']\+' .. s:field_separ
		let columns ..= columns
	else
		echomsg 'wheel polyphony substitute : mode must be file or circle'
	endif
	let columns = '\m^' .. columns .. '.*' .. '\zs'
	let before = columns .. before
	" escape separator of substitute
	let before = escape(before, '/')
	let after = escape(after, '/')
	let runme = '%substitute/' .. before .. '/' .. after .. '/g'
	echomsg runme
	execute runme
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
endfun

" Propagate mandala changes -> original buffer(s)

fun! wheel#polyphony#harmony ()
	" Write function for shape#narrow_file
	let linelist = getline(2, '$')
	let bufnum = b:wheel_related_buffer
	if bufnum == 'unknown'
		return v:false
	endif
	for line in linelist
		let fields = split(line, s:field_separ)
		let length = len(fields)
		let linum = str2nr(fields[0])
		if length > 1
			let content = fields[1]
		else
			let content = ''
		endif
		call setbufline(bufnum, linum, content)
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
