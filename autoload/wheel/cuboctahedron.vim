" vim: ft=vim fdm=indent:

" Changes of internal structure

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
			echomsg 'Wheel cuboctahedron reorder : name not found'
		endif
		call add(new_list, elem)
	endfor
	let upper[key] = []
	let upper[key] = new_list
	let upper.glossary = new_names
	return new_list
endfun
