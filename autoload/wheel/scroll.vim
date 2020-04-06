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
