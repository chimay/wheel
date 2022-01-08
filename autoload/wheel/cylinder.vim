" vim: set ft=vim fdm=indent iskeyword&:

" Mandala buffers ring
"
" Cylinder of rotary printing press

" Helpers

fun! wheel#cylinder#is_mandala (...)
	" Return true if current buffer is a mandala buffer, false otherwise
	" Optional argument : number of buffer to test
	if a:0 > 0
		let bufnum = a:1
	else
		let bufnum = bufnr('%')
	endif
	let mandalas = g:wheel_mandalas.ring
	if wheel#chain#is_inside(bufnum, mandalas)
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#cylinder#new_iden (iden, ...)
	" Returns id for new mandala, that is not in iden list
	" As low as possible, starting from zero
	" If optional argument is quick, find new iden around iden
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let iden = a:iden
	" quick mode around iden
	if mode == 'quick'
		let minim = min(iden) - 1
		let maxim = max(iden) + 1
		if minim >= 0
			let novice = minim
		else
			let novice = maxim
		endif
		return novice
	endif
	" default mode
	let novice = 0
	while wheel#chain#is_inside(novice, iden)
		let novice += 1
	endwhile
	return novice
endfun

fun! wheel#cylinder#check ()
	" Remove non existent mandalas buffers from ring
	let mandalas = g:wheel_mandalas.ring
	let iden = g:wheel_mandalas.iden
	for bufnum in mandalas
		if ! bufexists(bufnum)
			echomsg 'wheel : removing deleted' bufnum 'buffer from mandala ring'
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

" Window

fun! wheel#cylinder#goto (...)
	" Find window of visible current mandala
	" Optional argument : if tab, search only in current tab
	let current = g:wheel_mandalas.current
	let mandalas = g:wheel_mandalas.ring
	if empty(mandalas)
		return v:false
	endif
	let bufnum = mandalas[current]
	call call('wheel#rectangle#goto', [bufnum] + a:000)
endfun

fun! wheel#cylinder#window (...)
	" Find window of current mandala or display it in a new split
	" Optional argument mode :
	" if mode == 'buffer' (default) :
	"     find or create the mandala window & load current mandala
	" if mode == 'window' :
	"    just find or create the mandala window
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'buffer'
	endif
	" ring
	let current = g:wheel_mandalas.current
	let mandalas = g:wheel_mandalas.ring
	" any mandala ?
	if empty(mandalas)
		return v:false
	endif
	" current mandala
	let goto = mandalas[current]
	" already there ?
	if wheel#cylinder#is_mandala ()
		if mode == 'buffer'
			exe 'silent buffer' goto
		endif
		return v:true
	endif
	" find window if mandala is visible
	let tab = tabpagenr()
	call wheel#cylinder#goto ()
	" if not in current tab,
	" close it and reopen it in current tab
	if tab != tabpagenr()
		call wheel#mandala#close ()
		exe 'tabnext' tab
		if mode == 'buffer'
			exe 'silent sbuffer' goto
		else
			split
		endif
		return v:true
	endif
	" current tab
	if ! wheel#cylinder#is_mandala ()
		if mode == 'buffer'
			exe 'silent sbuffer' goto
		else
			split
		endif
	endif
	return v:true
endfun

" Add & delete

fun! wheel#cylinder#first (...)
	" Add first mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'furtive'
	endif
	let mandalas = g:wheel_mandalas.ring
	if ! empty(mandalas)
		echomsg 'wheel cylinder first : mandala ring is not empty.'
		return v:false
	endif
	let iden = g:wheel_mandalas.iden
	" new buffer
	if mode != 'furtive'
		split
	endif
	enew
	let novice = bufnr('%')
	" add
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

fun! wheel#cylinder#add (...)
	" Add new mandala buffer
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'furtive'
	endif
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.ring
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
	let winds = win_findbuf(elder)
	if mode != 'furtive' && ! wheel#cylinder#is_mandala ()
		call wheel#cylinder#window ('window')
	endif
	enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala add : buffer' novice 'already in ring'
		return v:false
	endif
	" add
	let length = len(mandalas)
	let next = current + 1
	call insert(mandalas, novice, next)
	let g:wheel_mandalas.current = next
	let novice_iden = wheel#cylinder#new_iden (iden)
	call insert(iden, novice_iden, next)
	call wheel#layer#init ()
	call wheel#mandala#set_empty ()
	call wheel#mandala#common_maps ()
	if mode == 'furtive' && ! was_mandala
		" in furtive mode, if not in mandala buffer at start,
		" go back to previous buffer
		silent buffer #
	endif
	call wheel#status#cylinder ()
	return v:true
endfun

fun! wheel#cylinder#delete ()
	" Delete mandala buffer
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.ring
	let iden = g:wheel_mandalas.iden
	" do not delete element from empty ring
	if empty(mandalas)
		echomsg 'wheel mandala delete : empty buffer ring'
		return v:false
	endif
	" do not delete element from one element ring
	if len(mandalas) == 1
		echomsg 'wheel mandala delete :' mandalas[0] 'is the last remaining dedicated buffer'
		return v:false
	endif
	" delete
	let current = g:wheel_mandalas.current
	let removed = remove(mandalas, current)
	call remove(iden, current)
	let current = (current - 1) % len(mandalas)
	let g:wheel_mandalas.current = current
	let bufnum = bufnr('%')
	if bufnum == removed || wheel#cylinder#is_mandala ()
		let goto = mandalas[current]
		exe 'silent buffer' goto
	endif
	exe 'silent bwipe!' removed
	call wheel#status#cylinder ()
	return removed
endfun

" Recall

fun! wheel#cylinder#recall ()
	" Recall mandala buffer
	call wheel#cylinder#check ()
	return wheel#cylinder#window ()
endfun

" Forward & backward

fun! wheel#cylinder#forward ()
	" Go forward in mandalas buffers
	let mandalas = g:wheel_mandalas.ring
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala forward : empty ring.'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, mandalas)
		let current = wheel#gear#circular_plus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#cylinder ()
endfun

fun! wheel#cylinder#backward ()
	" Go backward in mandalas buffers
	let mandalas = g:wheel_mandalas.ring
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala backward : empty ring.'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, mandalas)
		let current = wheel#gear#circular_minus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#cylinder ()
endfun

" Switch

fun! wheel#cylinder#switch ()
	" Switch to mandala with completion
	let bufnums = copy(g:wheel_mandalas.ring)
	if empty(bufnums)
		echomsg 'wheel cylinder switch : empty buffer ring.'
		return v:false
	endif
	let prompt = 'Switch to mandala : '
	let complete =  'customlist,wheel#completelist#mandala'
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
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
