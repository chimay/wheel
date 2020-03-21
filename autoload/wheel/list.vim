" vim: set filetype=vim:

fun! wheel#list#insert_next (sublist, mainlist, ...)
	" Insert sublist in list just after index = a:1
	" index = 0 by default
	if a:0 > 0
		let index = a:1
	else
		let index = 0
	endif
	let li = a:mainlist
	return li[0:index] + a:sublist + li[index + 1:-1]
endfun

fun! wheel#list#insert_after (sublist, mainlist, element)
	" Insert sublist in list just after element
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
