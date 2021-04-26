" vim: ft=vim fdm=indent:

" Mandala buffers stack / ring

" Check

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

" Push & pop

fun! wheel#cylinder#first (...)
	" Push first mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'furtive'
	endif
	let mandalas = g:wheel_mandalas.stack
	if ! empty(mandalas)
		echomsg 'wheel cylinder first : mandala stack is not empty.'
		return v:false
	endif
	let iden = g:wheel_mandalas.iden
	" new buffer
	if mode != 'furtive'
		split
	endif
	enew
	let novice = bufnr('%')
	" push
	call add(mandalas, novice)
	let g:wheel_mandalas.current = 0
	call add(iden, 0)
	call wheel#layer#init ()
	call wheel#mandala#set_empty ()
	call wheel#mandala#common_maps ()
	if mode == 'furtive'
		silent buffer #
	endif
	return v:true
endfun

fun! wheel#cylinder#push (...)
	" Push new mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'furtive'
	endif
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.stack
	let iden = g:wheel_mandalas.iden
	" -- First one
	if empty(mandalas)
		return call('wheel#cylinder#first', a:000)
	endif
	" -- Not the first one
	" is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" previous current mandala
	let current = g:wheel_mandalas.current
	let elder = mandalas[current]
	" new buffer
	let bufnum = bufnr('%')
	let winum =  bufwinnr(elder)
	if mode != 'furtive' && index(mandalas, bufnum) < 0
		" in non furtive mode, an action is needed
		" if current buffer is not a mandala
		if winum >= 0
			" if mandala is already visible in a window of the current tab,
			" just go to it
			exe winum . 'wincmd w'
		else
			" if mandala is not visible in the current tab
			" and current buffer is not a mandala, we need to split
			split
		endif
	endif
	enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala push : buffer' novice 'already in stack'
		return v:false
	endif
	" push
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
	call wheel#mandala#set_empty ()
	call wheel#mandala#common_maps ()
	" in furtive mode, if not in mandala buffer at start,
	" go back to previous buffer
	if mode == 'furtive' && ! was_mandala
		silent buffer #
	endif
	call wheel#status#cylinder ()
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
		echomsg 'wheel mandala pop :' mandalas[0] 'is the last remaining dedicated buffer'
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
	"echomsg 'Buffer' removed 'removed'
	call wheel#status#cylinder ()
	return removed
endfun

" Recall

fun! wheel#cylinder#recall ()
	" Recall mandala buffer
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.stack
	let current = g:wheel_mandalas.current
	if empty(mandalas)
		"echomsg 'wheel mandala recall : empty buffer stack'
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
		" if the mandala is already visible in a window of the current tab,
		" just go to it
		exe winum . 'wincmd w'
	else
		" if mandala is not visible in the current tab
		" and current buffer is not a mandala, we need to split
		exe 'silent sbuffer' goto
	endif
	return v:true
endfun

" Forward & backward

fun! wheel#cylinder#forward ()
	" Go forward in mandalas buffers
	let mandalas = g:wheel_mandalas.stack
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala forward : empty stack.'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if index(mandalas, bufnum) >= 0
		let current = wheel#gear#circular_plus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#cylinder ()
endfun

fun! wheel#cylinder#backward ()
	" Go backward in mandalas buffers
	let mandalas = g:wheel_mandalas.stack
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala backward : empty stack.'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if index(mandalas, bufnum) >= 0
		let current = wheel#gear#circular_minus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#cylinder ()
endfun

" Switch

fun! wheel#cylinder#switch ()
	" Switch to mandala with completion
	let bufnums = copy(g:wheel_mandalas.stack)
	if empty(bufnums)
		echomsg 'wheel cylinder switch : empty buffer stack.'
		return v:false
	endif
	let prompt = 'Switch to mandala : '
	let complete =  'custom,wheel#complete#mandala'
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '/wheel/', complete)
	endif
	let filenames = map(bufnums, {_,v->bufname(v)})
	let mandala = index(filenames, name)
	if mandala < 0
		return v:false
	endif
	let g:wheel_mandalas.current = mandala
	call wheel#cylinder#recall ()
	call wheel#status#cylinder ()
endfun
