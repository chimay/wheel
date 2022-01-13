" vim: set ft=vim fdm=indent iskeyword&:

" Multi-line operations on a buffer
"
" Narrow, filter and apply

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
	let range = "'<,'>"
	let runme = range .. 'number'
	let linelist = execute(runme)
	return linelist
endfun

" Mandalas

fun! wheel#polyphony#range (start, end)
	" Return range of buffer to display in narrow
	let start = a:start
	let end = a:end
	if start == end
		return '%'
	endif
	if type(start) != v:t_string
		let start = string(start)
	endif
	if type(end) != v:t_string
		let end = string(end)
	endif
	let range = string(start) .. ',' .. string(end)
	return range
endfun

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
