" vim: set ft=vim fdm=indent iskeyword&:

" Input history

" script constants

if ! exists('s:mandala_prompt')
	let s:mandala_prompt = wheel#crystal#fetch('mandala/prompt')
	lockvar s:mandala_prompt
endif

" function

fun! wheel#scroll#record (input)
	" Add input = string or list to beginning of input history
	let input = a:input
	if type(input) == v:t_list
		for elem in input
			call wheel#scroll#record (elem)
		endfor
	elseif type(input) == v:t_string
		if input->wheel#chain#is_inside(g:wheel_input)
			eval g:wheel_input->wheel#chain#remove_element(input)
		endif
		eval g:wheel_input->insert(input)
		let max = g:wheel_config.maxim.input
		let g:wheel_input = g:wheel_input[:max - 1]
	else
		echomsg 'wheel scroll record : bad input format'
	endif
endfun

fun! wheel#scroll#newer ()
	" Replace first line by newer element in input history
	if line('.') != 1
		return v:false
	endif
	let line = getline(1)
	if ! empty(line)
		let g:wheel_input = wheel#chain#rotate_right (g:wheel_input)
	endif
	let content = s:mandala_prompt .. g:wheel_input[0]
	call setline(1, content)
	" not necessary with <cmd> maps
	"startinsert!
endfun

fun! wheel#scroll#older ()
	" Replace first line by older element in input history
	if line('.') != 1
		return v:false
	endif
	let line = getline(1)
	if ! empty(line)
		let g:wheel_input = wheel#chain#rotate_left (g:wheel_input)
	endif
	let content = s:mandala_prompt .. g:wheel_input[0]
	call setline(1, content)
	" not necessary with <cmd> maps
	"startinsert!
endfun

fun! wheel#scroll#filtered_newer ()
	" Replace first line by newer element that matches line until cursor
	if line('.') != 1
		return v:false
	endif
	let colnum = col('.')
	let line = getline(1)
	if empty(line)
		call wheel#scroll#newer ()
		return v:true
	endif
	let before = strcharpart(line, 0, colnum)
	let before = wheel#teapot#without_prompt (before)
	let pattern = '\m^' .. before
	let reversed = reverse(copy(g:wheel_input))
	let index = match(reversed, pattern, 0)
	if index >= 0
		let reversed = reversed->wheel#chain#roll_right(index)
		let g:wheel_input = reverse(copy(reversed))
		let content = s:mandala_prompt .. g:wheel_input[0]
		call setline(1, content)
	endif
	call cursor(1, colnum)
	" not necessary with <cmd> maps
	"startinsert
endfun

fun! wheel#scroll#filtered_older ()
	" Replace first line by older element that matches line until cursor
	if line('.') != 1
		return v:false
	endif
	let colnum = col('.')
	let line = getline(1)
	if empty(line)
		call wheel#scroll#older ()
		return v:true
	endif
	let before = strcharpart(line, 0, colnum)
	let before = wheel#teapot#without_prompt (before)
	let pattern = '\m^' .. before
	let index = match(g:wheel_input, pattern, 1)
	if index >= 0
		let g:wheel_input = g:wheel_input->wheel#chain#roll_left(index)
		let content = s:mandala_prompt .. g:wheel_input[0]
		call setline(1, content)
	endif
	call cursor(1, colnum)
	" not necessary with <cmd> maps
	"startinsert
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
