" vim: set ft=vim fdm=indent iskeyword&:

" Scroll
"
" Input history

" script constants

" function

fun! wheel#scroll#record (content)
	" Add content to beginning of input history
	let content = a:content
	if type(content) == v:t_list
		let content = join(content)
	endif
	let input = g:wheel_input
	let index = input->index(content)
	if index >= 0
		eval input->remove(index)
	endif
	eval input->insert(content)
	let maxim = g:wheel_config.maxim.input
	" we need to use g:wheel_input here
	" because input[:maxim - 1] makes a copy
	let g:wheel_input = input[:maxim - 1]
endfun

fun! wheel#scroll#newer ()
	" Replace first line by newer element in input history
	if line('.') != 1
		return v:false
	endif
	let input = g:wheel_input
	let line = wheel#teapot#without_prompt ()
	if empty(line)
		call wheel#teapot#set_prompt (input[0], 'dont-lock')
		return v:true
	endif
	let g:wheel_input = wheel#taijitu#rotate_right (input)
	call wheel#teapot#set_prompt (g:wheel_input[0], 'dont-lock')
	return v:true
endfun

fun! wheel#scroll#older ()
	" Replace first line by older element in input history
	if line('.') != 1
		return v:false
	endif
	let input = g:wheel_input
	let line = wheel#teapot#without_prompt ()
	if empty(line)
		call wheel#teapot#set_prompt (input[0], 'dont-lock')
		return v:true
	endif
	let g:wheel_input = wheel#taijitu#rotate_left (input)
	call wheel#teapot#set_prompt (g:wheel_input[0], 'dont-lock')
	return v:true
endfun

fun! wheel#scroll#filtered_newer ()
	" Replace first line by newer element that matches line until cursor
	if line('.') != 1
		return v:false
	endif
	let input = copy(g:wheel_input)
	let line = getline(1)
	let colnum = col('.')
	if empty(line)
		call wheel#scroll#newer ()
		return v:true
	endif
	let before = strpart(line, 0, colnum - 1)
	let before = wheel#teapot#without_prompt (before)
	let pattern = '\m^' .. before
	let reversed = reverse(input)
	let index = match(reversed, pattern, 0)
	if index >= 0
		let reversed = reversed->wheel#taijitu#roll_right(index)
		let g:wheel_input = reverse(copy(reversed))
		call wheel#teapot#set_prompt (g:wheel_input[0], 'dont-lock')
	endif
	call cursor(1, colnum)
	return v:true
endfun

fun! wheel#scroll#filtered_older ()
	" Replace first line by older element that matches line until cursor
	if line('.') != 1
		return v:false
	endif
	let input = g:wheel_input
	let line = getline(1)
	let colnum = col('.')
	if empty(line)
		call wheel#scroll#older ()
		return v:true
	endif
	let before = strpart(line, 0, colnum - 1)
	let before = wheel#teapot#without_prompt (before)
	let pattern = '\m^' .. before
	let index = match(input, pattern, 1)
	if index >= 0
		let g:wheel_input = g:wheel_input->wheel#taijitu#roll_left(index)
		call wheel#teapot#set_prompt (g:wheel_input[0], 'dont-lock')
	endif
	call cursor(1, colnum)
	return v:true
endfun

" mandala

fun! wheel#scroll#mappings ()
	" Define local input history maps
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <up> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <down> <cmd>call wheel#scroll#newer()<cr>
	inoremap <buffer> <M-p> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <cmd>call wheel#scroll#newer()<cr>
	" PageUp / PageDown & M-r / M-s : next / prev matching line
	inoremap <buffer> <PageUp> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <PageDown> <cmd>call wheel#scroll#filtered_newer()<cr>
	inoremap <buffer> <M-r> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <cmd>call wheel#scroll#filtered_newer()<cr>
endfun
