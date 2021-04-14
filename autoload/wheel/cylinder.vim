" vim: ft=vim fdm=indent:

" mandala buffers stack

fun! wheel#cylinder#push (...)
	" Push new mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	call wheel#cylinder#check ()
	" First one
	if empty(mandalas)
		enew
		let bufnum = bufnr('%')
		call add(mandalas, bufnum)
		let g:wheel_mandalas.current = 0
		let g:wheel_mandalas.maxim = 0
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
	" Is current buffer a mandala buffer ?
	let bufnum = bufnr('%')
	if index(mandalas, bufnum) >= 0
		let in_mandala_buf = v:true
	else
		let in_mandala_buf = v:false
	endif
	" Old current special buffer
	let current = g:wheel_mandalas.current
	let elder = mandalas[current]
	" New buffer
	enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'Wheel mandala push : buffer' novice 'already in stack'
		return v:false
	endif
	" Push
	call add(mandalas, novice)
	let g:wheel_mandalas.current = len(mandalas) - 1
	let g:wheel_mandalas.maxim += 1
	let maxim = g:wheel_mandalas.maxim
	call add(iden, maxim)
	call wheel#mandala#common_maps ()
	if ! in_mandala_buf
		silent buffer #
	endif
	echomsg 'Buffer' elder 'saved'
	return v:true
endfun

fun! wheel#cylinder#pop ()
	" Pop mandala buffer
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	" Do not pop empty stack
	if empty(mandalas)
		echomsg 'wheel mandala pop : empty buffer stack'
		return v:false
	endif
	" Do not pop one element stack
	if len(mandalas) == 1
		echomsg 'wheel mandala pop :' mandalas[0] 'is the last remaining wheel special buffer'
		return v:false
	endif
	" Pop
	let current = g:wheel_mandalas.current
	let removed = remove(mandalas, current)
	call remove(iden, current)
	let g:wheel_mandalas.maxim = max(iden)
	let current = (current - 1) % len(mandalas)
	let g:wheel_mandalas.current = current
	let bufnum = bufnr('%')
	if bufnum == removed || index(mandalas, bufnum) >= 0
		let goto = mandalas[current]
		exe 'silent buffer' goto
	endif
	exe 'silent bwipe!' removed
	echomsg 'Buffer' removed 'removed'
	return removed
endfun

fun! wheel#cylinder#recall ()
	" Recall mandala buffer
	call wheel#cylinder#check ()
	let buffers = g:wheel_mandalas.stack
	let current = g:wheel_mandalas.current
	if empty(buffers)
		echomsg 'wheel mandala recall : empty buffer stack'
		return v:false
	endif
	let bufnum = bufnr('%')
	let goto = buffers[current]
	let winnum =  bufwinnr(goto)
	if index(buffers, bufnum) >= 0
		" if current buf is already a mandala buf,
		" no need to split
		exe 'silent buffer' goto
	elseif winnum < 0
		" if current buf is not a mandala buf,
		" we need to split
		exe 'silent sbuffer' goto
	else
		" in case the special buf is already visible in a window,
		" just go to it
		exe winnum . 'wincmd w'
	endif
	return v:true
endfun

fun! wheel#cylinder#check ()
	" Remove non existent mandalas buffers from stack
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	for bufnum in mandalas
		if ! bufexists(bufnum)
			let index = index(mandalas, bufnum)
			call remove(mandalas, index)
			call remove(iden, index)
			let current = g:wheel_mandalas.current
			if current == index
				let g:wheel_mandalas.current = 0
			endif
		endif
	endfor
endfun

fun! wheel#cylinder#cycle ()
	" Cycle mandalas buffers
	let mandalas = g:wheel_mandalas.stack
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if index(mandalas, bufnum) >= 0
		let current = (current + 1) % len(mandalas)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
endfun
