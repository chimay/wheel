" vim: set ft=vim fdm=indent iskeyword&:

" Multi-line operations on a buffer
"
" Narrow, filter and apply

" Range of original buffer

" Operator function

fun! wheel#polyphony#operatorfunc (argument = '')
	" Manage operator
	" Use in a map like this :
	"   map <expr> <F3> wheel#polyphony#operatorfunc()
	let argument = a:argument
	" called to find the rhs of the map
	if argument == ''
		set operatorfunc=wheel#polyphony#operatorfunc
		return 'g@'
	endif
	" called to execute operatorfunc
	let first = line("'[")
	let last = line("']")
	call wheel#shape#narrow([first, last])
endfun

" Mandalas

fun! wheel#polyphony#filter_maps ()
	" Define local filter maps
	" normal mode
	nnoremap <silent> <buffer> <ins> ggA
	nnoremap <silent> <buffer> <m-a> ggA
	" insert mode
	inoremap <silent> <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
endfun

" Write mandala -> related buffer

fun! wheel#polyphony#narrow ()
	" Write function for shape#narrow
	setlocal nomodified
endfun
