" vim: ft=vim fdm=indent:

" Wheel special buffers stack

fun! wheel#cylinder#push (...)
	" Push new wheel special buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	let buffers = g:wheel_buffers.stack
	let iden = g:wheel_buffers.iden
	call wheel#cylinder#check ()
	" First one
	if empty(buffers)
		enew
		let bufnum = bufnr('%')
		call add(buffers, bufnum)
		let g:wheel_buffers.current = 0
		let g:wheel_buffers.maxim = 0
		call add(iden, 0)
		call wheel#mandala#common_maps ()
		if mode == 'goback'
			silent buffer #
		endif
		echomsg 'Buffer' bufnum 'added'
		" done
		return v:true
	endif
	" Not the first one
	" Is current buffer a special wheel special buffer ?
	let bufnum = bufnr('%')
	if index(buffers, bufnum) >= 0
		let in_wheel_buf = v:true
	else
		let in_wheel_buf = v:false
	endif
	" Old current special buffer
	let current = g:wheel_buffers.current
	let elder = buffers[current]
	" New buffer
	enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'Wheel mandala push : buffer' novice 'already in stack'
		return v:false
	endif
	" Push
	call add(buffers, novice)
	let g:wheel_buffers.current = len(buffers) - 1
	let g:wheel_buffers.maxim += 1
	let maxim = g:wheel_buffers.maxim
	call add(iden, maxim)
	call wheel#mandala#common_maps ()
	if ! in_wheel_buf
		silent buffer #
	endif
	echomsg 'Buffer' elder 'saved'
	return v:true
endfun

fun! wheel#cylinder#pop ()
	" Pop wheel special buffer
	call wheel#cylinder#check ()
	let buffers = g:wheel_buffers.stack
	let iden = g:wheel_buffers.iden
	" Do not pop empty stack
	if empty(buffers)
		echomsg 'wheel mandala pop : empty buffer stack'
		return v:false
	endif
	" Do not pop one element stack
	if len(buffers) == 1
		echomsg 'Wheel mandala pop :' buffers[0] 'is the last remaining wheel special buffer'
		return v:false
	endif
	" Pop
	let current = g:wheel_buffers.current
	let removed = remove(buffers, current)
	call remove(iden, current)
	let g:wheel_buffers.maxim = max(iden)
	let current = (current - 1) % len(buffers)
	let g:wheel_buffers.current = current
	let bufnum = bufnr('%')
	if bufnum == removed || index(buffers, bufnum) >= 0
		let goto = buffers[current]
		exe 'silent buffer ' goto
	endif
	exe 'silent bwipe ' removed
	echomsg 'Buffer' removed 'removed'
	return removed
endfun

fun! wheel#cylinder#recall ()
	" Recall wheel special buffer
	call wheel#cylinder#check ()
	let buffers = g:wheel_buffers.stack
	let current = g:wheel_buffers.current
	if empty(buffers)
		echomsg 'wheel mandala recall : empty buffer stack'
		return v:false
	endif
	let bufnum = bufnr('%')
	let goto = buffers[current]
	let winnum =  bufwinnr(goto)
	if index(buffers, bufnum) >= 0
		" if current buf is already a special wheel buf,
		" no need to split
		exe 'silent buffer ' . goto
	elseif winnum < 0
		" if current buf is not a special wheel buf,
		" we need to split
		exe 'silent sbuffer ' . goto
	else
		" in case the special buf is already visible in a window,
		" just go to it
		exe winnum . 'wincmd w'
	endif
	return v:true
endfun

fun! wheel#cylinder#check ()
	" Remove non existent buffers from stack
	let buffers = g:wheel_buffers.stack
	let iden = g:wheel_buffers.iden
	for bufnum in buffers
		if ! bufexists(bufnum)
			let index = index(buffers, bufnum)
			call remove(buffers, index)
			call remove(iden, index)
			let current = g:wheel_buffers.current
			if current == index
				let g:wheel_buffers.current = 0
			endif
		endif
	endfor
endfun

fun! wheel#cylinder#cycle ()
	" Cycle wheel special buffers
	let buffers = g:wheel_buffers.stack
	let current = g:wheel_buffers.current
	let bufnum = bufnr('%')
	if index(buffers, bufnum) >= 0
		let current = (current + 1) % len(buffers)
		let g:wheel_buffers.current = current
	endif
	call wheel#cylinder#recall ()
endfun
