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

" Operator function

fun! wheel#polyphony#operator (argument = '')
	" Manage operator
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
	call wheel#shape#narrow(first, last)
endfun

fun! wheel#polyphony#visual ()
	" Manage visual mode
	let first = line("'<")
	let last = line("'>")
	call wheel#shape#narrow(first, last)
endfun

" Mandalas

fun! wheel#polyphony#filter_maps ()
	" Define local filter maps
	" normal mode
	nnoremap <silent> <buffer> <ins> ggA
	nnoremap <silent> <buffer> <cr> ggA
	" insert mode
	inoremap <silent> <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
endfun

" Write mandala -> related buffer

fun! wheel#polyphony#harmony ()
	" Write function for shape#narrow
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
