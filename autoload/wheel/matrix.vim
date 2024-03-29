" vim: set ft=vim fdm=indent iskeyword&:

" Matrix
"
" Nested lists & dictionaries

" ---- booleans

fun! wheel#matrix#is_nested_list (argument)
	" Whether argument is a nested list
	" Empty list is not considered nested
	let argument = a:argument
	if type(argument) != v:t_list
		return v:false
	endif
	if empty(argument)
		return v:false
	endif
	for elem in argument
		if type(elem) != v:t_list
			return v:false
		endif
	endfor
	return v:true
endfun

fun! wheel#matrix#is_nested_dict (argument)
	" Whether argument is a nested dict
	" Empty dict is not considered nested
	let argument = a:argument
	if type(argument) != v:t_dict
		return v:false
	endif
	if empty(argument)
		return v:false
	endif
	for elem in values(argument)
		if type(elem) != v:t_dict
			return v:false
		endif
	endfor
	return v:true
endfun

" ---- duality

fun! wheel#matrix#dual (nested)
	" Return transposed of nested list
	let nested = a:nested
	" -- outer length
	let outer_length = len(nested)
	" -- inner length
	let lengthes = []
	for elem in nested
		eval lengthes->add(len(elem))
	endfor
	let inner_length = min(lengthes)
	if inner_length < max(lengthes)
		echomsg 'wheel matrix dual : inner lists are not of the same length'
		return v:false
	endif
	" -- span
	let outer_span = range(outer_length)
	let inner_span = range(inner_length)
	" -- init dual
	" can't use repeat() with nested list :
	" it uses references to the same inner list
	let dual = copy(inner_span)->map('[]')
	" -- double loop
	for inner in inner_span
		let dualelem = dual[inner]
		for outer in outer_span
			eval dualelem->add(nested[outer][inner])
		endfor
	endfor
	" -- coda
	return dual
endfun

" ---- flatten

fun! wheel#matrix#flatten (nested)
	" Return concatenated lists of nested
	let nested = deepcopy(a:nested)
	let flat = []
	for list in nested
		eval flat->extend(list)
	endfor
	return flat
endfun

" ---- dictionary as nested list of items
"
" items list = [ [key1, val1], [key2, val2], ...]

fun! wheel#matrix#items2dict (items)
	" Convert items list -> dictionary
	let items = a:items
	if ! wheel#matrix#is_nested_list (items)
		return {}
	endif
	let dict = {}
	for [key, val] in items
		let dict[key] = val
	endfor
	return dict
endfun

fun! wheel#matrix#items2keys (items)
	" Return list of keys from dict given by items list
	let items = a:items
	if ! wheel#matrix#is_nested_list (items)
		return []
	endif
	let keylist = []
	for [key, val] in items
		eval keylist->add(key)
	endfor
	return keylist
endfun

fun! wheel#matrix#items2values (items)
	" Return list of values from dict given by items list
	let items = a:items
	if ! wheel#matrix#is_nested_list (items)
		return []
	endif
	let valist = []
	for [key, val] in items
		eval valist->add(val)
	endfor
	return valist
endfun
