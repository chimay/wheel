" vim: set ft=vim fdm=indent iskeyword&:

" Input history

fun! wheel#scroll#record (input)
	" Add input = string or list to beginning of input history
	if type(a:input) == v:t_list
		for elem in a:input
			call wheel#scroll#record (elem)
		endfor
	elseif type(a:input) == v:t_string
		if wheel#chain#is_inside(a:input, g:wheel_input)
			call wheel#chain#remove_element(a:input, g:wheel_input)
		endif
		call insert(g:wheel_input, a:input)
		let max = g:wheel_config.maxim.input
		let g:wheel_input = g:wheel_input[:max - 1]
	else
		echomsg 'wheel scroll record : bad input format'
	endif
endfun

fun! wheel#scroll#newer ()
	" Replace current line by newer element in input history
	if ! empty(getline('.'))
		let g:wheel_input = wheel#chain#rotate_right (g:wheel_input)
	endif
	call cursor(1,1)
	call setline('.', g:wheel_input[0])
	startinsert!
endfun

fun! wheel#scroll#older ()
	" Replace current line by older element in input history
	if ! empty(getline('.'))
		let g:wheel_input = wheel#chain#rotate_left (g:wheel_input)
	endif
	call cursor(1,1)
	call setline('.', g:wheel_input[0])
	startinsert!
endfun

fun! wheel#scroll#filtered_newer ()
	" Replace current line by newer element in input history
	if line('.') != 1
		return
	endif
	let col = col('.')
	let line = getline('.')
	if empty(line)
		call wheel#scroll#newer ()
		return
	endif
	let before = strcharpart(line, 0, col)
	let pattern = '\m^' .. before
	let reversed = reverse(copy(g:wheel_input))
	let index = match(reversed, pattern, 0)
	if index >= 0
		let reversed = wheel#chain#roll_right (index, reversed)
		let g:wheel_input = reverse(copy(reversed))
		call setline('.', g:wheel_input[0])
	endif
	call cursor(1, col + 1)
	startinsert
endfun

fun! wheel#scroll#filtered_older ()
	" Replace current line by older element in input history
	if line('.') != 1
		return
	endif
	let col = col('.')
	let line = getline('.')
	if empty(line)
		call wheel#scroll#older ()
		return
	endif
	let before = strcharpart(line, 0, col)
	let pattern = '\m^' .. before
	let index = match(g:wheel_input, pattern, 1)
	if index >= 0
		let g:wheel_input = wheel#chain#roll_left (index, g:wheel_input)
		call setline('.', g:wheel_input[0])
	endif
	call cursor(1, col + 1)
	startinsert
endfun
