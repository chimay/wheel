" vim: ft=vim fdm=indent:

" Nested lists & dictionaries

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

" Dictionary as nested list of items

fun! wheel#matrix#items2dict (items)
	" Convert items list -> dictionary
	" items = [ [key1, val1], [key2, val2], ...]
	let dict = {}
	for [key, val] in a:items
		let dict[key] = val
	endfor
	return dict
endfun

fun! wheel#matrix#items2keys (items)
	" Return list of keys from dict given by items
	" items = [ [key1, val1], [key2, val2], ...]
	let keylist = []
	for [key, val] in a:items
		call add(keylist, key)
	endfor
	return keylist
endfun

fun! wheel#matrix#items2values (items)
	" Return list of values from dict given by items
	" items = [ [key1, val1], [key2, val2], ...]
	let valist = []
	for [key, val] in a:items
		call add(valist, val)
	endfor
	return valist
endfun
