" vim: ft=vim fdm=indent:

" Input history

fun! wheel#scroll#record (input)
	" Add input = word or word list to input history
	if type(a:input) == v:t_list
		for elem in a:input
			call wheel#scroll#record (elem)
		endfor
	elseif type(a:input) == v:t_string
		if index(g:wheel_input, a:input) >= 0
			call wheel#chain#remove_element(a:input, g:wheel_input)
		endif
		call insert(g:wheel_input, a:input)
		let max = g:wheel_config.max_history
		let g:wheel_input = g:wheel_input[:max - 1]
	else
		echomsg 'Wheel scroll record : bad input format'
	endif
endfun

fun! wheel#scroll#newer ()
	" Replace current line by newer element in input history
	let g:wheel_input = wheel#chain#rotate_right (g:wheel_input)
	call cursor(1,1)
	call setline('.', g:wheel_input[0])
	startinsert!
endfun

fun! wheel#scroll#older ()
	" Replace current line by older element in input history
	let g:wheel_input = wheel#chain#rotate_left (g:wheel_input)
	call cursor(1,1)
	call setline('.', g:wheel_input[0])
	startinsert!
endfun
