" vim: ft=vim fdm=indent:

" Lists operations

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

fun! wheel#chain#replace (old, new, list)
	" Replace old by new in list
	let old = a:old
	let new = a:new
	let list = a:list
	let index = index(list, old)
	if index >= 0
		let list[index] = new
	else
		echomsg 'List' join(list,  ', ') 'does not contain' old
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

fun! wheel#chain#pop (list)
	" Remove first element from list ; return it
	let elem = a:list[0]
	call remove(a:list, 0)
	return elem
endfu

fun! wheel#chain#rotate_left (list)
	" Rotate list to the left
	if len(a:list) > 1
		return a:list[1:] + [a:list[0]]
	else
		return a:list
	endif
endfu

fun! wheel#chain#rotate_right (list)
	" Rotate list to the right
	if len(a:list) > 1
		return [a:list[-1]] + a:list[:-2]
	else
		return a:list
	endif
endfu

fun! wheel#chain#roll_left (index, list)
	" Roll index in list -> left = beginning
	let index = a:index
	let list = a:list
	if index > 0 && index < len(list)
		return list[index:] + list[0:index-1]
	else
		return list
	endif
endfu

fun! wheel#chain#roll_right (index, list)
	" Roll index of list -> right = end
	let index = a:index
	let list = a:list
	if index >= 0 && index < len(list) - 1
		return list[index+1:-1] + list[0:index]
	else
		return list
	endif
endfu

fun! wheel#chain#swap (list)
	" Swap first and second element of list
	if len(a:list) > 1
		return [a:list[1]] + [a:list[0]] + a:list[2:]
	else
		return a:list
	endif
endfun
