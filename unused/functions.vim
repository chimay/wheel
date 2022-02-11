" vim: set ft=vim fdm=indent iskeyword&:

" Unused functions

fun! wheel#disc#write (pointer, file, where = '>')
	" Write variable referenced by pointer to file
	" in a format that can be :sourced
	" Note : pointer = variable name in vim script
	" If optional argument 1 is :
	"   - '>' : replace file content (default)
	"   - '>>' : append to file content
	" Doesn't work well with some abbreviated echoed variables content in vim
	" disc#writefile is more reliable with vim
	let pointer = a:pointer
	if ! exists(pointer)
		return
	endif
	let file = fnamemodify(a:file, ':p')
	let where = a:where
	" create directory if needed
	let directory = fnamemodify(file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return v:false
	endif
	" write
	let var = {pointer}
	redir => content
	silent! echo 'let' pointer '=' var
	redir END
	let content = substitute(content, '\m[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\m\n\{2,\}', '\n', 'g')
	exec 'redir!' where file
	silent! echo content
	redir END
endfun

fun! wheel#disc#read (file)
	" Read file
	let file = fnamemodify(a:file, ':p')
	if ! filereadable(file)
		echomsg 'Could not read' file
	endif
	execute 'source' file
endfun

fun! wheel#pendulum#older (level = 'wheel')
	" Go to older entry in g:wheel_history.circuit
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel older :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#older_anywhere ()
	endif
	" current coordin
	let names = wheel#referen#names ()
	" index for range in coordin
	let level_index = wheel#referen#coordin_index (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_left (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_left (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" older found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel older : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a copy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#newer (level = 'wheel')
	" Go to newer entry in g:wheel_history.circuit
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel newer :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#newer_anywhere ()
	endif
	" current coordin
	let names = wheel#referen#names ()
	" index for range in coordin
	let level_index = wheel#referen#coordin_index (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_right (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_right (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" newer found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel newer : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a deepcopy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#cylinder#first (window = 'furtive')
	" Add first mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let bufring = g:wheel_bufring
	let mandalas = g:wheel_bufring.mandalas
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	" -- empty ring ?
	if ! empty(mandalas)
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
	let bufring.current = 0
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	eval mandalas->add(novice)
	eval iden->add(0)
	eval names->add('0')
	eval types->add('')
	" ---- set filename
	call wheel#cylinder#filename ()
	" ---- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" ---- coda
	if window == 'furtive'
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			execute 'silent hide buffer' cur_buffer
		endif
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

fun! wheel#cylinder#add (window = 'furtive')
	" Add new mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let bufring = g:wheel_bufring
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	call wheel#cylinder#check ()
	call wheel#cylinder#delete_unused ()
	" ---- first one
	let mandalas = bufring.mandalas
	if empty(mandalas)
		return wheel#cylinder#first (window)
	endif
	" ---- not the first one
	" -- is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" -- previous current mandala
	let current = bufring.current
	let elder = mandalas[current]
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
	call wheel#cylinder#filename ()
	" -- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- coda
	if window == 'furtive' && ! was_mandala
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			execute 'silent hide buffer' cur_buffer
		endif
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

fun! wheel#centre#commands ()
	" Define commands
	" ---- meta command
	command! -nargs=* -complete=customlist,wheel#complete#meta_command Wheel call wheel#centre#meta(<f-args>)
	" ---- status
	command! WheelDashboard call wheel#status#dashboard()
	command! WheelJump      call wheel#vortex#jump()
	command! WheelFollow    call wheel#projection#follow()
	" ---- read / write
	command! WheelRead         call wheel#disc#read_wheel()
	command! WheelWrite        call wheel#disc#write_wheel()
	command! WheelReadSession  call wheel#disc#read_session()
	command! WheelWriteSession call wheel#disc#write_session()
	" ---- batch
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
	" ---- autogroup
	command! WheelAutogroup call wheel#group#menu()
	" ---- disc
	command! -nargs=+ -complete=file WheelMkdir  call wheel#disc#mkdir(<f-args>)
	command! -nargs=+ -complete=file WheelRename call wheel#disc#rename(<f-args>)
	command! -nargs=+ -complete=file WheelCopy   call wheel#disc#copy(<f-args>)
	command! -nargs=+ -complete=file WheelDelete call wheel#disc#delete(<f-args>)
	" ---- tree of symlinks/files reflecting wheel structure
	command! WheelTreeScript  call wheel#disc#tree_script()
	command! WheelSymlinkTree call wheel#disc#symlink_tree()
	command! WheelCopiedTree  call wheel#disc#copied_tree()
endfun
