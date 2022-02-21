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
	if level ==# 'wheel'
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
	if level ==# 'wheel'
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
	if window ==# 'split'
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
	if window ==# 'furtive'
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
	if window ==# 'split'
		call wheel#cylinder#window ('window')
	endif
	" -- pre op buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" -- new buffer
	if window ==# 'split'
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
	if window ==# 'furtive' && ! was_mandala
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

fun! wheel#disc#write_session (...)
	" Write session layout to session file
	if a:0 > 0
		let session_file = fnamemodify(a:1, ':p')
	else
		if empty(g:wheel_config.session_file)
			echomsg 'Please configure g:wheel_config.session_file = my_session_file'
			return v:false
		else
			let session_file = fnamemodify(g:wheel_config.session_file, ':p')
		endif
	endif
	" backup value of sessionoptions
	let ampersand = &sessionoptions
	set sessionoptions=tabpages,winsize
	" create directory if needed
	let directory = fnamemodify(session_file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return v:false
	endif
	" backup old sessions
	call wheel#disc#roll_backups(session_file, g:wheel_config.backups)
	" writing session
	echomsg 'Writing session to file ..'
	execute 'mksession!' session_file
	" restore value of sessionoptions
	let &sessionoptions=ampersand
	echomsg 'Writing done !'
	return v:true
endfun

" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding in mandalas

" Script constants

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Fold for torus, circle and location

fun! wheel#origami#chord_level ()
	" Wheel level of fold line : torus, circle or location
	if ! &l:foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return v:false
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'torus'
	elseif line =~ s:fold_2
		return 'circle'
	else
		return 'location'
	endif
endfun

fun! wheel#origami#chord_parent ()
	" Go to line of parent fold in wheel tree
	let level = wheel#origami#chord_level ()
	if level ==# 'circle'
		let pattern = '\m' .. s:fold_1 .. '$'
	elseif level ==# 'location'
		let pattern = '\m' .. s:fold_2 .. '$'
	else
		" torus line : we stay there
		return
	endif
	call search(pattern, 'b')
endfun

fun! wheel#origami#chord ()
	" Return wheel coordinates of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = wheel#pencil#unmarked (cursor_line)
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		return []
	endif
	let level = wheel#origami#chord_level ()
	if level ==# 'torus'
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif level ==# 'circle'
		" circle line : search torus
		let circle = cursor_list[0]
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#unmarked (line)
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle]
	elseif level ==# 'location'
		" location line : search circle & torus
		let location = cursor_line
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#unmarked (line)
		let fields = split(line)
		let circle = fields[0]
		call wheel#origami#chord_parent ()
		let line = getline('.')
		let line = wheel#pencil#unmarked (line)
		let fields = split(line)
		let torus = fields[0]
		let coordin = [torus, circle, location]
	else
		echomsg 'wheel line coordin : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun

" Fold for tabs & windows

fun! wheel#origami#tabwin_level ()
	" Tab & window : level of fold line, tab or filename
	if ! &l:foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return v:false
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'tab'
	else
		return 'filename'
	endif
endfun

fun! wheel#origami#tabwin_parent ()
	" Go to line of parent fold in tabwin tree
	let level = wheel#origami#tabwin_level ()
	if level ==# 'filename'
		let pattern = '\m' .. s:fold_1 .. '$'
		call search(pattern, 'b')
	else
		" tab line : we stay there
		return
	endif
endfun

fun! wheel#origami#tabwin ()
	" Return tab & filename of line in folded mandala buffer
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = wheel#pencil#unmarked (cursor_line)
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		return []
	endif
	let level = wheel#origami#tabwin_level ()
	if level ==# 'tab'
		" tab line
		let tabnum = str2nr(cursor_list[1])
		let coordin = [tabnum]
	elseif level ==# 'filename'
		" filename line : find window tab-local number & tab index
		let filename = cursor_list[0]
		let fileline = line('.')
		call wheel#origami#tabwin_parent ()
		let tabline = line('.')
		let winum = fileline - tabline
		let line = getline('.')
		let line = wheel#pencil#unmarked (line)
		let fields = split(line)
		let tabnum = str2nr(fields[1])
		let coordin = [tabnum, winum, filename]
	else
		echomsg 'tabwin hierarchy : wrong fold level'
	endif
	call wheel#gear#restore_cursor (position)
	return coordin
endfun
