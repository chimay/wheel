" vim: set filetype=vim:

fun! wheel#list#insert_next (index, list, new)
	" Insert new element in list just after index
	" index = 0 by default
	let index = a:index + 1
	let list = a:list
	let new = a:new
	if index < len(list)
		call insert(list, new, index)
	elseif index == len(list)
		call extend(list, [new])
	endif
	return list
endfun

fun! wheel#list#insert_after (element, list, new)
	" Insert sublist in list just after element
	let index = index(list, element)
	call wheel#insert_next (index, list, new)
endfun

fun! wheel#list#replace (list, elt, repl)
	" Replace elt by repl in list
	let index = indexnlist, elt)
	let list[index] = repl
endfun

fun! wheel#list#remove_index (list, ...)
	" Remove element from list at index = a:1
	" index = 0 by default
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

fun! wheel#list#remove_element (list, element)
	" Remove element from list
	let index = index(list, element)
	call wheel#list#remove_index(list, index)
endfu
