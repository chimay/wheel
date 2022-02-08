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
	" Return true if current buffer is a mandala, false otherwise
	" Optional argument : number of buffer to test
	if a:0 > 0
		let bufnum = a:1
	else
		let bufnum = bufnr('%')
	endif
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	return wheel#chain#is_inside(bufnum, mandalas)
endfun

fun! wheel#cylinder#update_type ()
	" Update last used type of current mandala buffer
	let bufring = g:wheel_bufring
	let current = bufring.current
	let types = bufring.types
	let types[current] = b:wheel_nature.type
endfun

fun! wheel#cylinder#check ()
	" Remove non existent mandala buffers from ring
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	for bufnum in mandalas
		if ! bufexists(bufnum)
			echomsg 'wheel : removing deleted' bufnum 'buffer from mandala ring'
			let index = mandalas->index(bufnum)
			eval mandalas->remove(index)
			eval iden->remove(index)
			eval names->remove(index)
			eval types->remove(index)
			let current = bufring.current
			if current == index
				let bufring.current = 0
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
	let bufring = g:wheel_bufring
	let current = bufring.current
	let iden = bufring.iden[current]
	let pseudo = '/wheel/' .. iden
	return pseudo
endfun

fun! wheel#cylinder#set_filename ()
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
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	if empty(mandalas)
		return v:false
	endif
	let current = bufring.current
	let bufnum = mandalas[current]
	return call('wheel#rectangle#goto', [bufnum] + a:000)
endfun

fun! wheel#cylinder#goto_or_split ()
	" Find window of current mandala or create a new split for it
	" -- already there ?
	if wheel#cylinder#is_mandala ()
		return v:true
	endif
	" -- pre op tab
	let base_tab = tabpagenr()
	" -- find window if mandala is visible
	" -- else, just split
	if ! wheel#cylinder#goto ()
		call wheel#cylinder#split ()
		return v:true
	endif
	" -- if not in same tab, mandala is open and we are inside
	" -- close it and go to the right tab
	let mandala_tab = tabpagenr()
	if base_tab != mandala_tab
		noautocmd close
		execute 'noautocmd tabnext' base_tab
	endif
	" -- if tab has changed, window was closed and we need
	" -- to create a new split
	if ! wheel#cylinder#is_mandala ()
		call wheel#cylinder#split ()
	endif
	" -- coda
	return v:true
endfun

fun! wheel#cylinder#goto_or_load ()
	" Go to current mandala window or load the buffer in a new split
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	let current = bufring.current
	" -- check
	if empty(mandalas)
		return v:false
	endif
	" -- goto existing mandala window or create it
	call wheel#cylinder#goto_or_split ()
	" -- buffer
	let bufnum = mandalas[current]
	if bufnum == bufnr('%')
		return v:true
	endif
	execute 'silent hide buffer' bufnum
	return v:true
endfun

fun! wheel#cylinder#recall ()
	" Recall mandala buffer : find its window or load it in a split
	call wheel#cylinder#check ()
	return wheel#cylinder#goto_or_load ()
endfun

" add

fun! wheel#cylinder#first (mood = 'linger')
	" Add first mandala buffer
	" Optional argument :
	"   - linger (default) : stay opened after operation
	"   - furtive : close after operation
	let mood = a:mood
	let bufring = g:wheel_bufring
	let mandalas = g:wheel_bufring.mandalas
	" -- empty ring ?
	if ! empty(mandalas)
		echomsg 'wheel cylinder first : mandala ring is not empty'
		return v:false
	endif
	call wheel#cylinder#delete_unused ()
	" ---- new buffer
	call wheel#cylinder#split ()
	hide enew
	let novice = bufnr('%')
	" ---- add
	let bufring.current = 0
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	eval mandalas->add(novice)
	eval iden->add(0)
	eval names->add('0')
	eval types->add('')
	" ---- set filename
	call wheel#cylinder#set_filename ()
	" ---- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" ---- coda
	if mood == 'furtive'
		noautocmd close
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

fun! wheel#cylinder#add (mood = 'linger')
	" Add new mandala buffer
	" Optional argument :
	"   - linger (default) : stay opened after operation
	"   - furtive : close after operation
	let mood = a:mood
	let bufring = g:wheel_bufring
	" ---- pre-checks
	call wheel#cylinder#check ()
	call wheel#cylinder#delete_unused ()
	" ---- first one
	let mandalas = bufring.mandalas
	if empty(mandalas)
		return wheel#cylinder#first (mood)
	endif
	" ---- not the first one
	" -- is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" -- previous current mandala
	let current = bufring.current
	let elder = mandalas[current]
	" -- mandala window
	call wheel#cylinder#goto_or_split ()
	" -- new buffer
	hide enew
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala add : buffer' novice 'already in ring'
		return v:false
	endif
	" -- add
	let next = current + 1
	eval mandalas->insert(novice, next)
	let bufring.current = next
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	let novice_iden = wheel#chain#lowest_outside (iden)
	let novice_name = string(novice_iden)
	eval iden->insert(novice_iden, next)
	eval names->insert(novice_name, next)
	eval types->insert('', next)
	" -- set filename
	call wheel#cylinder#set_filename ()
	" -- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- coda
	if mood == 'furtive' && ! was_mandala
		noautocmd close
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

" delete

fun! wheel#cylinder#delete ()
	" Delete mandala buffer
	call wheel#cylinder#check ()
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
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
	let current = bufring.current
	let removed = mandalas->remove(current)
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	eval iden->remove(current)
	eval names->remove(current)
	eval types->remove(current)
	let length = len(mandalas)
	let current = wheel#gear#circular_minus(current, length)
	let g:wheel_bufring.current = current
	let bufnum = bufnr('%')
	if bufnum == removed || wheel#cylinder#is_mandala ()
		let goto = mandalas[current]
		execute 'silent hide buffer' goto
	endif
	execute 'silent bwipe!' removed
	call wheel#status#mandala_leaf ()
	return removed
endfun

fun! wheel#cylinder#delete_unused ()
	" Delete old, unused mandala
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
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
	let bufring = g:wheel_bufring
	let current = bufring.current
	let names = bufring.names
	let prompt = 'Relabel current dedicated buffer as ? '
	let new_name = input(prompt)
	let names[current] = new_name
	call wheel#status#mandala_leaf ()
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
	" Go forward in mandalas ring
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	let types = bufring.types
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala forward : empty ring'
		return v:false
	endif
	let current = g:wheel_bufring.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, mandalas)
		let current = wheel#gear#circular_plus (current, length)
		let g:wheel_bufring.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun

fun! wheel#cylinder#backward ()
	" Go backward in mandalas ring
	let bufring = g:wheel_bufring
	let mandalas = bufring.mandalas
	let types = bufring.types
	let length = len(mandalas)
	if length == 0
		echomsg 'wheel mandala backward : empty ring'
		return v:false
	endif
	let current = g:wheel_bufring.current
	let bufnum = bufnr('%')
	if wheel#chain#is_inside(bufnum, mandalas)
		let current = wheel#gear#circular_minus (current, length)
		let g:wheel_bufring.current = current
	endif
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun

" switch

fun! wheel#cylinder#switch ()
	" Switch to mandala with completion
	let bufring = g:wheel_bufring
	let names = bufring.names
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
	let index = names->index(chosen)
	if index < 0
		return v:false
	endif
	let g:wheel_bufring.current = index
	call wheel#cylinder#recall ()
	call wheel#status#mandala_leaf ()
endfun
