" vim: ft=vim fdm=indent:

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
	" lengthes
	let lenlist = []
	for elem in nested
		call add(lenlist, len(elem))
	endfor
	let innerlen = min(lenlist)
	if innerlen < max(lenlist)
		echomsg 'wheel matrix dual : inner lists are not of the same length.'
		return v:false
	endif
	let outerlen = len(nested)
	" span
	let in_span = range(innerlen)
	let out_span = range(outerlen)
	" double loop
	let dual = []
	for inner in in_span
		let dualelem = []
		for outer in out_span
			call add(dualelem, nested[outer][inner])
		endfor
		call add(dual, dualelem)
	endfor
	" return
	return dual
endfun

" Dictionary as nested list of items
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
