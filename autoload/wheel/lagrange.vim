" vim: set ft=vim fdm=indent iskeyword&:

" Extrema

fun! wheel#lagrange#argmin (list)
	" Returns indexes where list[index] = min(list)
	let list = a:list
	let minimum = min(list)
	let indexes = []
	for ind in wheel#chain#rangelen(list)
		if list[ind] == minimum
			eval indexes->add(ind)
		endif
	endfor
	return indexes
endfun

fun! wheel#lagrange#argmax (list)
	" Returns indexes where list[index] = max(list)
	let list = a:list
	let maximum = max(list)
	let indexes = []
	for ind in wheel#chain#rangelen(list)
		if list[ind] == maximum
			eval indexes->add(ind)
		endif
	endfor
	return indexes
endfun
