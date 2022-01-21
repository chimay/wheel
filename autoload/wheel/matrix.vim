" vim: set ft=vim fdm=indent iskeyword&:

" Nested lists & dictionaries

" Booleans

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

" Duality

fun! wheel#matrix#dual (nested)
	" Return transposed of nested list
	let nested = a:nested
	" -- outer length
	let outer_length = len(nested)
	" -- inner length
	let lengthes = []
	for elem in nested
		call add(lengthes, len(elem))
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
			call add(dualelem, nested[outer][inner])
		endfor
	endfor
	" -- coda
	return dual
endfun

" Dictionary as nested list of items
"
" items list = [ [key1, val1], [key2, val2], ...]

fun! wheel#matrix#items2dict (items)
	" Convert items list -> dictionary
	let dict = {}
	for [key, val] in a:items
		let dict[key] = val
	endfor
	return dict
endfun

fun! wheel#matrix#items2keys (items)
	" Return list of keys from dict given by items list
	let keylist = []
	for [key, val] in a:items
		call add(keylist, key)
	endfor
	return keylist
endfun

fun! wheel#matrix#items2values (items)
	" Return list of values from dict given by items list
	let valist = []
	for [key, val] in a:items
		call add(valist, val)
	endfor
	return valist
endfun
