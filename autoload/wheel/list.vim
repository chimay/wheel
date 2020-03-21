" vim: set filetype=vim:

fun! wheel#list#insert_next (index, new, list)
	" Insert new element in list just after index
	" index = 0 by default
	let index = a:index + 1
	let list = a:list
	let new = a:new
	if index < len(list)
		return insert(list, new, index)
	elseif index == len(list)
		return add(list, new)
	endif
endfun

fun! wheel#list#insert_after (element, new, list)
	" Insert sublist in list just after element
	let index = index(a:list, a:element)
	return wheel#list#insert_next (index, a:list, a:new)
endfun

fun! wheel#list#replace (element, repl, list)
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

fun! wheel#list#remove_index (index, list)
	" Remove element at index from list
	if a:0 > 0
		let index = a:1
	else
		let index = 0
	endif
	if index == 0
		let li = a:list[1:-1]
	else
		let li = a:list[0 : index - 1] + a:list[index + 1 : -1]
	endif
	return li
endfun

fun! wheel#list#remove_element (element, list)
	" Remove element from list
	let index = index(list, element)
	call wheel#list#remove_index(list, index)
endfu
