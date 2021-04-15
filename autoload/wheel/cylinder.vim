" vim: ft=vim fdm=indent:

" Mandala buffers stack / ring

fun! wheel#cylinder#is_mandala (...)
	" Return true if current buffer is a mandala buffer, false otherwise
	" Optional argument : number of buffer to test
	if a:0 > 0
		let bufnum = a:1
	else
		let bufnum = bufnr('%')
	endif
	let mandalas = g:wheel_mandalas.stack
	if index(mandalas, bufnum) >= 0
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#cylinder#first (...)
	" Push first mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	enew
	let novice = bufnr('%')
	call add(mandalas, novice)
	let g:wheel_mandalas.current = 0
	call add(iden, 0)
	call wheel#layer#init ()
	call wheel#mandala#pseudo_filename ('empty')
	call wheel#mandala#common_maps ()
	if mode == 'goback'
		silent buffer #
	endif
	echomsg 'Buffer' novice 'added to mandala stack with iden' 0
endfun

fun! wheel#cylinder#push (...)
	" Push new mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'goback'
	endif
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	" First one
	if empty(mandalas)
		call wheel#cylinder#first (mode)
		return v:true
	endif
	" Not the first one
	" Is current buffer a mandala buffer ?
	let in_mandala_buf = wheel#cylinder#is_mandala ()
	" Old current special buffer
	let current = g:wheel_mandalas.current
	let elder = mandalas[current]
	" New buffer
	enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala push : buffer' novice 'already in stack'
		return v:false
	endif
	" Push
	call add(mandalas, novice)
	let g:wheel_mandalas.current = len(mandalas) - 1
	let minim = min(iden) - 1
	let maxim = max(iden) + 1
	if minim >= 0
		let novice_iden = minim
	else
		let novice_iden = maxim
	endif
	call add(iden, novice_iden)
	call wheel#layer#init ()
	call wheel#mandala#pseudo_filename ('empty')
	call wheel#mandala#common_maps ()
	" if not in mandala buffer at start, go back to previous buffer
	if ! in_mandala_buf
		silent buffer #
	endif
	echomsg 'Buffer' novice 'added to mandala stack with iden' novice_iden
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

fun! wheel#cylinder#rotate_right ()
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

fun! wheel#cylinder#rotate_left ()
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
