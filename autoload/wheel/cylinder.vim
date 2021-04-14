" vim: ft=vim fdm=indent:

" Mandala buffers stack

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
	call wheel#layer#init ()
	call wheel#mandala#pseudo_folders ('empty')
	call wheel#mandala#common_maps ()
	" if not in mandala buffer at start, go back to previous buffer
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
	let mandalas = g:wheel_mandalas.stack
	let current = g:wheel_mandalas.current
	if empty(mandalas)
		echomsg 'wheel mandala recall : empty buffer stack'
		return v:false
	endif
	let bufnum = bufnr('%')
	let goto = mandalas[current]
	let winum =  bufwinnr(goto)
	if index(mandalas, bufnum) >= 0
		" if current buf is already a mandala buf,
		" no need to split
		exe 'silent buffer' goto
	elseif winum >= 0
		" if the special buf is already visible in a window,
		" just go to it
		exe winum . 'wincmd w'
	else
		" if mandala is not visible and current buffer
		" is not a mandala, we need to split
		exe 'silent sbuffer' goto
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

fun! wheel#cylinder#cycle_right ()
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

fun! wheel#cylinder#cycle_left ()
	" Cycle mandalas buffers
	let mandalas = g:wheel_mandalas.stack
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if index(mandalas, bufnum) >= 0
		let current = (current - 1) % len(mandalas)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
endfun
