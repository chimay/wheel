" vim: set ft=vim fdm=indent iskeyword&:

" Mandala buffers ring
"
" Cylinder of rotary printing press

" script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

" helpers

fun! wheel#cylinder#is_mandala (...)
	" Return true if current buffer is a mandala buffer, false otherwise
	" Optional argument : number of buffer to test
	if a:0 > 0
		let bufnum = a:1
	else
		let bufnum = bufnr('%')
	endif
	let mandalas = g:wheel_mandalas.ring
	return wheel#chain#is_inside(bufnum, mandalas)
endfun

fun! wheel#cylinder#new_iden (iden, mode = 'default')
	" Returns id for new mandala, that is not in iden list
	" As low as possible, starting from zero
	" If optional argument is quick, find new iden around iden
	let iden = a:iden
	let mode = a:mode
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

fun! wheel#cylinder#split ()
	" Create a new split window and put it at the bottom
	split
	wincmd J
endfun

" window

fun! wheel#cylinder#goto (...)
	" Find window of visible current mandala
	" Optional argument : if tab, search only in current tab
	if wheel#cylinder#is_mandala()
		" already there
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let mandalas = g:wheel_mandalas.ring
	if empty(mandalas)
		return v:false
	endif
	let bufnum = mandalas[current]
	return call('wheel#rectangle#goto', [bufnum] + a:000)
endfun

fun! wheel#cylinder#window (mode = 'buffer')
	" Find window of current mandala or display it in a new split
	" Optional argument mode :
	"  - buffer (default) : find or create the mandala window &
	"    load current mandala
	"  - window : just find or create the mandala window,
	"    don't load current mandala
	let mode = a:mode
	" -- ring
	let current = g:wheel_mandalas.current
	let mandalas = g:wheel_mandalas.ring
	" -- any mandala ?
	if empty(mandalas)
		return v:false
	endif
	" -- current mandala
	let goto = mandalas[current]
	" -- already there ?
	if wheel#cylinder#is_mandala ()
		if mode == 'buffer'
			execute 'silent buffer' goto
		endif
		return v:true
	endif
	" -- find window if mandala is visible
	let tab = tabpagenr()
	call wheel#cylinder#goto ()
	" -- if not in same tab, mandala is open
	" -- and we are inside
	" -- close it and go to the right tab
	if tab != tabpagenr()
		close
		execute 'tabnext' tab
	endif
	" -- current tab
	if ! wheel#cylinder#is_mandala ()
		call wheel#cylinder#split ()
		if mode == 'buffer'
			execute 'silent buffer' goto
		endif
	endif
	return v:true
endfun

" add

fun! wheel#cylinder#first (mode = 'furtive')
	" Add first mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - linger : use a split
	let mode = a:mode
	" -- pre-checks
	if ! mode->wheel#chain#is_inside(['linger', 'furtive'])
		echomsg 'wheel cylinder first : bad mode argument'
		return v:false
	endif
	let mandalas = g:wheel_mandalas.ring
	if ! empty(mandalas)
		echomsg 'wheel cylinder first : mandala ring is not empty.'
		return v:false
	endif
	call wheel#cylinder#delete_unused ()
	" -- mandalas ring
	let iden = g:wheel_mandalas.iden
	" -- current buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" -- new buffer
	if mode == 'linger'
		call wheel#cylinder#split ()
		enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current one has no name
			" so we need to use :new
			new
		else
			enew
		endif
	endif
	let novice = bufnr('%')
	" -- add
	call add(mandalas, novice)
	let g:wheel_mandalas.current = 0
	call add(iden, 0)
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- coda
	if mode == 'furtive'
		" call status before going back to previous buffer
		call wheel#status#mandala_leaf ()
		if empty_cur_buffer
			" :new has opened a split, close it
			close
		else
			execute 'silent buffer' cur_buffer
		endif
	endif
	return v:true
endfun

fun! wheel#cylinder#add (mode = 'furtive')
	" Add new mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - linger : use a split
	let mode = a:mode
	" ---- pre-checks
	if ! mode->wheel#chain#is_inside(['linger', 'furtive'])
		echomsg 'wheel cylinder first : bad mode argument'
		return v:false
	endif
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas.ring
	let iden = g:wheel_mandalas.iden
	call wheel#cylinder#delete_unused ()
	" ---- first one
	if empty(mandalas)
		return wheel#cylinder#first (mode)
	endif
	" ---- not the first one
	" -- is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" -- previous current mandala
	let current = g:wheel_mandalas.current
	let elder = mandalas[current]
	" -- mandala window
	let winds = win_findbuf(elder)
	if mode != 'furtive'
		call wheel#cylinder#window ('window')
	endif
	" -- current buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" -- new buffer
	if mode == 'linger'
		call wheel#cylinder#split ()
		enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current want has no name
			" so we need to use :new
			new
		else
			enew
		endif
	endif
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala add : buffer' novice 'already in ring'
		return v:false
	endif
	" -- add
	let next = current + 1
	call insert(mandalas, novice, next)
	let g:wheel_mandalas.current = next
	let novice_iden = wheel#cylinder#new_iden (iden)
	call insert(iden, novice_iden, next)
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- call status before going back to previous buffer
	call wheel#status#mandala_leaf ()
	" -- coda
	if mode == 'furtive' && ! was_mandala
		" in furtive mode, if not in mandala buffer at start,
		" go back to previous buffer
		if empty_cur_buffer
			" :new has opened a split, close it
			close
		else
			silent buffer #
		endif
	endif
	return v:true
endfun

" delete

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
		execute 'silent buffer' goto
	endif
	execute 'silent bwipe!' removed
	call wheel#status#mandala_leaf ()
	return removed
endfun

fun! wheel#cylinder#delete_unused ()
	" Delete old, unused mandalas
	let mandalas = g:wheel_mandalas.ring
	" -- unused buffer list
	let buflist = getbufinfo({'buflisted' : 1})
	let numlist = []
	let filelist = []
	for buffer in buflist
		let bufnum = buffer.bufnr
		let filename = buffer.name
		let not_mandala = ! wheel#chain#is_inside(bufnum, mandalas)
		let wheel_filename = filename =~ s:is_mandala_file
		if not_mandala && wheel_filename
			call add(numlist, bufnum)
			call add(filelist, filename)
		endif
	endfor
	if empty(numlist)
		return [ [], [] ]
	endif
	" -- confirm
	echomsg 'wheel : old, unused mandalas are lingering :'
	echomsg join(filelist, ' - ')
	let prompt = 'Delete them ?'
	let overwrite = confirm(prompt, "&Yes\n&No", 2)
	if overwrite != 1
		return [numlist, filelist]
	endif
	" -- wipe
	for bufnum in numlist
		execute 'silent bwipe!' bufnum
	endfor
endfun

" recall

fun! wheel#cylinder#recall ()
	" Recall mandala buffer : find its window or load it in a split
	call wheel#cylinder#check ()
	return wheel#cylinder#window ()
endfun

" forward & backward

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
	call wheel#status#mandala_leaf ()
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
	call wheel#status#mandala_leaf ()
endfun

" switch

fun! wheel#cylinder#switch ()
	" Switch to mandala with completion
	let bufnums = copy(g:wheel_mandalas.ring)
	if empty(bufnums)
		echomsg 'wheel cylinder switch : empty buffer ring.'
		return v:false
	endif
	let prompt = 'Switch to mandala : '
	let complete = 'customlist,wheel#complete#mandala'
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
	endif
	let filenames = bufnums->map({ _, val->bufname(val) })
	let mandala = index(filenames, name)
	if mandala < 0
		return v:false
	endif
	let g:wheel_mandalas.current = mandala
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun
