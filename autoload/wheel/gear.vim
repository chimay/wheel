" vim: set ft=vim fdm=indent iskeyword&:

" Gear
"
" Generic helpers

" ---- vim cmdline range

fun! wheel#gear#vim_cmd_range (...)
	" Return range for :[range]cmd
	" Arguments : first & last line
	if a:0 == 2
		let first = a:1
		let last = a:2
	elseif type(a:1) == v:t_list
		let first = a:1[0]
		let last = a:1[1]
	else
		echomsg 'wheel gear vim_cmd_range : bad argument format'
	endif
	let range = string(first) .. ',' .. string(last)
	return range
endfun

" ---- cursor, focus

fun! wheel#gear#restore_cursor (position, default_line = '$')
	" Restore cursor position
	let position = a:position
	let default_line = a:default_line
	if line('$') > position[1]
		call setpos('.', position)
	else
		call cursor(default_line, 1)
	endif
	normal! zv
endfun

fun! wheel#gear#win_gotoid (iden)
	" Go to win given by iden if iden is a number
	if type(a:iden) == v:t_number
		call win_gotoid (a:iden)
	endif
endfun

" ---- char representation

fun! wheel#gear#reverse_keytrans(keystring)
	" Convert char representation like <c-a> -> 
	let keystring = a:keystring
	if keystring == '<space>'
		return ' '
	endif
	if keystring[0] ==# '<' && keystring[-1:] ==# '>'
		let keystring = keystring[1:-2]
		execute 'let keystring =' '"\<' .. keystring .. '>"'
	endif
	let keystring = substitute(keystring, '\m\c<plug>', "\<plug>", '')
	return keystring
endfun

" ---- buffer

fun! wheel#gear#delete (first, ...)
	" Delete lines to black hole register
	let first = a:first
	if &modifiable == 0
		echomsg 'wheel gear delete : modifiable is off'
		return 0
	endif
	if a:0 > 0
		let last = a:1
	else
		let last = first
	endif
	if exists('*deletebufline')
		return deletebufline('%', first, last)
	else
		" delete lines -> underscore _ = no storing register
		let range = first .. ',' .. last
		execute 'silent!' range .. 'delete _'
		return 0
	endif
endfun

" ---- misc

" used by chain#tie

fun! wheel#gear#decrease_greater(number, treshold)
	" Return number - 1 if > treshold, else return number
	if a:number > a:treshold
		return a:number - 1
	else
		return a:number
	endif
endfun
