" vim: ft=vim fdm=indent:

" Wheel buffers stack

fun! wheel#cylinder#push (...)
	" Push new wheel buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	let buffers = g:wheel_shelve.buffers
	call wheel#cylinder#check ()
	" First one
	if empty(buffers)
		enew
		let bufnum = bufnr('%')
		call insert(buffers, bufnum)
		call wheel#mandala#common_maps ()
		if mode == 'goback'
			silent buffer #
		endif
		echomsg 'Buffer' bufnum 'added'
		return v:true
	endif
	" Current buffer
	let current = bufnr('%')
	if index(buffers, current) >= 0
		let in_wheel_buf = v:true
	else
		let in_wheel_buf = v:false
	endif
	" Saved buffer
	let saved = buffers[0]
	" New buffer
	enew
	let new_buf = bufnr('%')
	if new_buf == saved
		echomsg 'Wheel mandala push : buffer' new_buf 'already in stack'
		return v:false
	endif
	" Push
	call insert(buffers, new_buf)
	call wheel#mandala#common_maps ()
	if ! in_wheel_buf
		silent buffer #
	endif
	echomsg 'Buffer' saved 'saved'
	return v:true
endfun

fun! wheel#cylinder#pop ()
	" Pop wheel buffer
	call wheel#cylinder#check ()
	let buffers = g:wheel_shelve.buffers
	" Do not pop empty stack
	if empty(buffers)
		echomsg 'wheel mandala pop : empty buffer stack'
		return v:false
	endif
	" Do not pop one element stack
	if len(buffers) == 1
		echomsg 'Wheel mandala pop :' buffers[0] 'is the last remaining wheel buffer'
		return v:false
	endif
	" Pop
	let removed = wheel#chain#pop(buffers)
	let current = bufnr('%')
	if current == removed || index(buffers, current) >= 0
		let bufnum = buffers[0]
		exe 'silent buffer ' bufnum
	endif
	exe 'silent bwipe ' removed
	echomsg 'Buffer' removed 'removed'
	return removed
endfun

fun! wheel#cylinder#recall ()
	" Recall wheel buffer
	call wheel#cylinder#check ()
	let buffers = g:wheel_shelve.buffers
	if empty(buffers)
		echomsg 'wheel mandala recall : empty buffer stack'
		return v:false
	endif
	let current = bufnr('%')
	let bufnum = buffers[0]
	let winnum =  bufwinnr(bufnum)
	if index(buffers, current) >= 0
		exe 'silent buffer ' bufnum
	elseif winnum < 0
		exe 'silent sbuffer ' . bufnum
	else
		exe winnum . 'wincmd w'
	endif
	return v:true
endfun

fun! wheel#cylinder#check ()
	" Remove non existent buffers from stack
	let buffers = g:wheel_shelve.buffers
	for bufnum in buffers
		if ! bufexists(bufnum)
			call wheel#chain#remove_element(bufnum, buffers)
		endif
	endfor
endfun

fun! wheel#cylinder#cycle ()
	" Cycle wheel buffers
	let buffers = g:wheel_shelve.buffers
	let current = bufnr('%')
	if index(buffers, current) >= 0
		let buffers = wheel#chain#rotate_left(buffers)
		let g:wheel_shelve.buffers = buffers
	endif
	call wheel#cylinder#recall ()
endfun
