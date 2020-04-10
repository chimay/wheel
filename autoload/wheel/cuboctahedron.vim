" vim: ft=vim fdm=indent:

" Changes of internal structure

" Helpers

fun! wheel#cuboctahedron#reorganize_line ()
	" Treat current line in reorganize buffer
	" TODO
	let position = getcurpos()
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, '\m^\* ', '', '')
	let cursor_list = split(cursor_line)
	if empty(cursor_line)
		echomsg 'Wheel line coordin : empty line'
		return
	endif
	if foldlevel('.') == 2 && len(cursor_list) == 1
		" location line : search circle & torus
		let location = cursor_line
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line)
		let circle = list[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line)
		let torus = list[0]
		let coordin = [torus, circle, location]
	elseif foldlevel('.') == 2
		" circle line : search torus
		let circle = cursor_list[0]
		normal! [z
		let line = getline('.')
		let line = substitute(line, '\m^\* ', '', '')
		let list = split(line)
		let torus = list[0]
		let coordin = [torus, circle]
	elseif foldlevel('.') == 1
		" torus line
		let torus = cursor_list[0]
		let coordin = [torus]
	elseif foldlevel('.') == 0
		" simple name line of level depending of buffer
		let coordin = cursor_line
	else
		echomsg 'Wheel line coordin : wrong fold level'
	endif
	call setpos('.', position)
	return coordin
endfun

" Buffers

fun! wheel#cuboctahedron#reorder (level)
	" Reorder current elements at level, after buffer content
	let level = a:level
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let key = wheel#referen#list_key (upper_level_name)
	let old_list = deepcopy(wheel#referen#elements (upper))
	let old_names = deepcopy(old_list)
	let old_names = map(old_names, {_,val -> val.name})
	let new_names = getline(1, '$')
	let new_list = []
	for name in new_names
		let index = index(old_names, name)
		if index >= 0
			let elem = old_list[index]
		else
			echomsg 'Wheel cuboctahedron reorder : ' name  'not found'
		endif
		call add(new_list, elem)
	endfor
	if len(new_list) < len(old_list)
		echomsg 'Some elements seem to be missing : changes not written'
	elseif len(new_list) > len(old_list)
		echomsg 'Elements in excess : changes not written'
	else
		let upper[key] = []
		let upper[key] = new_list
		let upper.glossary = new_names
		setlocal nomodified
		echomsg 'Changes written to wheel'
		return new_list
	endif
endfun

fun! wheel#cuboctahedron#reorganize ()
	" Rebuild wheel by adding elements contained in buffer
	" Follow folding tree
	let b:wheel_copy = deepcopy(g:wheel)
endfun
