" vim: set ft=vim fdm=indent iskeyword&:

" Cylinder
"
" Mandala buffers ring
"
" A cylinder is a stack of discs =~ circles =~ mandalas
"
" Cylinder of rotary printing press

" script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
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
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	return wheel#chain#is_inside(bufnum, ring)
endfun

fun! wheel#cylinder#update_type ()
	" Update type of current mandala
	let mandalas = g:wheel_mandalas
	let current = mandalas.current
	let types = mandalas.types
	let types[current] = b:wheel_nature.type
endfun

fun! wheel#cylinder#check ()
	" Remove non existent mandalas buffers from ring
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	let iden = mandalas.iden
	let names = mandalas.names
	let types = mandalas.types
	for bufnum in ring
		if ! bufexists(bufnum)
			echomsg 'wheel : removing deleted' bufnum 'buffer from mandala ring'
			let index = ring->index(bufnum)
			eval ring->remove(index)
			eval iden->remove(index)
			eval names->remove(index)
			eval types->remove(index)
			let current = mandalas.current
			if current == index
				let mandalas.current = 0
			endif
		endif
	endfor
endfun

fun! wheel#cylinder#split ()
	" Create a new split window and put it at the bottom
	noautocmd split
	wincmd J
endfun

" filename

fun! wheel#cylinder#pseudo ()
	" Return pseudo filename /wheel/<buf-id>
	let mandalas = g:wheel_mandalas
	let current = mandalas.current
	let iden = mandalas.iden[current]
	let pseudo = '/wheel/' .. iden
	return pseudo
endfun

fun! wheel#cylinder#filename ()
	" Set buffer filename to pseudo filename
	" Add unique buf id, so (n)vim does not complain about existing filename
	let pseudo = wheel#cylinder#pseudo ()
	execute 'silent file' pseudo
endfun

" window

fun! wheel#cylinder#goto (...)
	" Find window of visible current mandala
	" Optional argument : if tab, search only in current tab
	if wheel#cylinder#is_mandala ()
		" already there
		return v:false
	endif
	" ---- user update autocmd
	silent doautocmd User WheelUpdate
	" ---- go to mandala
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	if empty(ring)
		return v:false
	endif
	let current = mandalas.current
	let bufnum = ring[current]
	return call('wheel#rectangle#goto', [bufnum] + a:000)
endfun

fun! wheel#cylinder#window (load_buffer = 'load-buffer')
	" Find window of current mandala or display it in a new split
	" Optional argument load_buffer :
	"  - load-buffer (default) : find or create the mandala window &
	"    load current mandala
	"  - dont-load-buffer : just find or create the mandala window,
	"    don't load current mandala
	let load_buffer = a:load_buffer
	" -- ring
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	" -- any mandala ?
	if empty(ring)
		return v:false
	endif
	" -- current mandala
	let current = g:wheel_mandalas.current
	let goto = ring[current]
	" -- already there ?
	if wheel#cylinder#is_mandala ()
		if load_buffer == 'load-buffer'
			execute 'silent hide buffer' goto
		endif
		return v:true
	endif
	" -- find window if mandala is visible
	let good_tab = tabpagenr()
	call wheel#cylinder#goto ()
	" -- if not in same tab, mandala is open and we are inside
	" -- close it and go to the right tab
	let mandala_tab = tabpagenr()
	if good_tab != mandala_tab
		noautocmd close
		execute 'noautocmd tabnext' good_tab
	endif
	" -- coda
	if ! wheel#cylinder#is_mandala ()
		call wheel#cylinder#split ()
		if load_buffer == 'load-buffer'
			execute 'silent hide buffer' goto
		endif
	endif
	return v:true
endfun

" add

fun! wheel#cylinder#first (window = 'furtive')
	" Add first mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let mandalas = g:wheel_mandalas
	let ring = g:wheel_mandalas.ring
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	" -- empty ring ?
	if ! empty(ring)
		echomsg 'wheel cylinder first : mandala ring is not empty'
		return v:false
	endif
	call wheel#cylinder#delete_unused ()
	" ---- pre op buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" ---- new buffer
	if window == 'split'
		call wheel#cylinder#split ()
		hide enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current one has no name
			" so we need to use :new
			new
		else
			hide enew
		endif
	endif
	let novice = bufnr('%')
	" ---- add
	let mandalas.current = 0
	let iden = mandalas.iden
	let names = mandalas.names
	let types = mandalas.types
	eval ring->add(novice)
	eval iden->add(0)
	eval names->add(0)
	eval types->add('')
	" ---- set filename
	call wheel#cylinder#filename ()
	" ---- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" ---- coda
	" call status before going back to previous buffer
	call wheel#status#mandala_leaf ()
	if window == 'furtive'
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			execute 'silent hide buffer' cur_buffer
		endif
	endif
	return v:true
endfun

fun! wheel#cylinder#add (window = 'furtive')
	" Add new mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let mandalas = g:wheel_mandalas
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	call wheel#cylinder#check ()
	call wheel#cylinder#delete_unused ()
	" ---- first one
	let ring = mandalas.ring
	if empty(ring)
		return wheel#cylinder#first (window)
	endif
	" ---- not the first one
	" -- is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" -- previous current mandala
	let current = mandalas.current
	let elder = ring[current]
	" -- mandala window
	if window == 'split'
		call wheel#cylinder#window ('window')
	endif
	" -- pre op buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" -- new buffer
	if window == 'split'
		call wheel#cylinder#split ()
		hide enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current want has no name
			" so we need to use :new
			new
		else
			hide enew
		endif
	endif
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala add : buffer' novice 'already in ring'
		return v:false
	endif
	" -- add
	let next = current + 1
	eval ring->insert(novice, next)
	let mandalas.current = next
	let iden = mandalas.iden
	let names = mandalas.names
	let types = mandalas.types
	let novice_iden = wheel#chain#lowest_outside (iden)
	eval iden->insert(novice_iden, next)
	eval names->insert(novice_iden, next)
	eval types->insert('', next)
	" -- set filename
	call wheel#cylinder#filename ()
	" -- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- coda
	if window == 'furtive' && ! was_mandala
		" in furtive window, if not in mandala buffer at start,
		" go back to previous buffer
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			silent hide buffer #
		endif
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

" delete

fun! wheel#cylinder#delete ()
	" Delete mandala buffer
	call wheel#cylinder#check ()
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	" do not delete element from empty ring
	if empty(ring)
		echomsg 'wheel mandala delete : empty buffer ring'
		return v:false
	endif
	" do not delete element from one element ring
	if len(ring) == 1
		echomsg 'wheel mandala delete :' ring[0] 'is the last remaining dedicated buffer'
		return v:false
	endif
	" delete
	let current = mandalas.current
	let removed = ring->remove(current)
	let iden = mandalas.iden
	let names = mandalas.names
	let types = mandalas.types
	eval iden->remove(current)
	eval names->remove(current)
	eval types->remove(current)
	let length = len(ring)
	let current = wheel#gear#circular_minus(current, length)
	let g:wheel_mandalas.current = current
	let bufnum = bufnr('%')
	if bufnum == removed || wheel#cylinder#is_mandala ()
		let goto = ring[current]
		execute 'silent hide buffer' goto
	endif
	execute 'silent bwipe!' removed
	call wheel#status#mandala_leaf ()
	return removed
endfun

fun! wheel#cylinder#delete_unused ()
	" Delete old, unused mandalas
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	" -- unused buffer list
	let buflist = getbufinfo({'buflisted' : 1})
	let numlist = []
	let filelist = []
	for buffer in buflist
		let bufnum = buffer.bufnr
		let filename = buffer.name
		let not_mandala = ! wheel#chain#is_inside(bufnum, ring)
		let wheel_filename = filename =~ s:is_mandala_file
		if not_mandala && wheel_filename
			eval numlist->add(bufnum)
			eval filelist->add(filename)
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

" rename

fun! wheel#cylinder#rename ()
	" Rename current mandala
	" Used in status#mandala_leaf
	let mandalas = g:wheel_mandalas
	let current = mandalas.current
	let names = mandalas.names
	let prompt = 'Relabel current dedicated buffer as ? '
	let new_name = input(prompt)
	let names[current] = new_name
	call wheel#status#mandala_leaf ()
endfun

" recall

fun! wheel#cylinder#recall ()
	" Recall mandala buffer : find its window or load it in a split
	call wheel#cylinder#check ()
	return wheel#cylinder#window ()
endfun

" close

fun! wheel#cylinder#close ()
	" Close the mandala buffer
	" -- if we are not in a mandala buffer,
	" -- go to its window if it is visible
	if ! wheel#cylinder#is_mandala()
		call wheel#cylinder#goto ()
	endif
	" -- if we are still not in a mandala buffer,
	" -- none is visible and there is nothing to do
	if ! wheel#cylinder#is_mandala()
		return v:false
	endif
	" -- if preview was used, go to original buffer
	call wheel#orbiter#original ()
	" -- mandala buffer
	if winnr('$') > 1
		" more than one window in tab ? close it.
		noautocmd close
	else
		" only one window in tab ? jump to current wheel location
		call wheel#vortex#jump ()
	endif
	return v:true
endfun

" forward & backward

fun! wheel#cylinder#forward ()
	" Go forward in mandalas buffers
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	let types = mandalas.types
	let length = len(ring)
	if length == 0
		echomsg 'wheel mandala forward : empty ring'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, ring)
		let current = wheel#gear#circular_plus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun

fun! wheel#cylinder#backward ()
	" Go backward in mandalas buffers
	let mandalas = g:wheel_mandalas
	let ring = mandalas.ring
	let types = mandalas.types
	let length = len(ring)
	if length == 0
		echomsg 'wheel mandala backward : empty ring'
		return v:false
	endif
	let current = g:wheel_mandalas.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, ring)
		let current = wheel#gear#circular_minus (current, length)
		let g:wheel_mandalas.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun

" switch

fun! wheel#cylinder#switch ()
	" Switch to mandala with completion
	let mandalas = g:wheel_mandalas
	let names = mandalas.names
	if empty(names)
		echomsg 'wheel cylinder switch : empty buffer ring'
		return v:false
	endif
	let prompt = 'Switch to mandala : '
	let complete = 'customlist,wheel#complete#mandala'
	if a:0 > 0
		let chosen = a:1
	else
		let chosen = input(prompt, '', complete)
	endif
	let chosen = split(chosen, s:field_separ)[0]
	let mandala = names->index(chosen)
	if mandala < 0
		return v:false
	endif
	let g:wheel_mandalas.current = mandala
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun
