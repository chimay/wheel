" vim: set ft=vim fdm=indent iskeyword&:

" Multi-line operations on a buffer
"
" Narrow, filter and apply

" Mandalas

fun! wheel#polyphony#range (start, end)
	" Return range of buffer to display in narrow
	let start = a:start
	let end = a:end
	if start == end
		return '%'
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
