" vim: ft=vim fdm=indent:

fun! wheel#chain#insert_next (index, new, list)
	" Insert new element in list just after index
	" index = 0 by default
	let index = a:index + 1
	let list = a:list
	let new = a:new
	if empty(list)
		return add(list, new)
	endif
	if index < len(list)
		return insert(list, new, index)
	elseif index == len(list)
		return add(list, new)
	endif
endfun

fun! wheel#chain#insert_after (element, new, list)
	" Insert sublist in list just after element
	let index = index(a:list, a:element)
	return wheel#chain#insert_next (index, a:list, a:new)
endfun

fun! wheel#chain#replace (element, repl, list)
	" Replace element by repl in list
	let element = a:element
	let repl = a:repl
	let list = a:list
	let index = index(list, element)
	if index >= 0
		let list[index] = repl
	else
		echomsg 'List' join(list,  ', ') 'does not contain' element
	endif
	return list
endfun

fun! wheel#chain#remove_index (index, list)
	" Remove element at index from list
	let index = a:index
	let list = a:list
	call remove(list, index)
	return list
endfun

fun! wheel#chain#remove_element (element, list)
	" Remove element from list
	let element = a:element
	let list = a:list
	let index = index(list, element)
	return wheel#chain#remove_index(index, list)
endfu
