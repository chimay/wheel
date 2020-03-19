" vim: set filetype=vim:

" Helpers

fun! wheel#gear#template(name)
	" Generate template to add to g:wheel lists
	let template = [{}]
	let template[0].name = a:name
	return template
endfun

fun! wheel#gear#insert (sublist, mainlist, ...)
	" Insert sublist in mainlist just after index = a:1
	" index = 0 by default
	if a:0 > 0
		let index = a:1
	else
		let index = 0
	endif
	let li = a:mainlist
	return li[0:index] + a:sublist + li[index + 1:-1]
endfun

fun! wheel#gear#remove_at_index (list, ...)
	" Remove element at index from list = a:1
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

fun! wheel#gear#remove_element (list, element)
	" Remove element from list
	let index = index(list, element)
	call wheel#gear#remove_at_index(list, index)
endfu
