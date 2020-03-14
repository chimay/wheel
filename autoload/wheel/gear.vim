" vim: set filetype=vim:

" Helpers

fun! wheel#gear#insert (sublist, mainlist, ...)
	" Insert sublist in mainlist just after index = a:1
	if a:0 > 0
		let index = a:1
	else
		let index = 0
	endif
	let li = a:mainlist
	return li[0:index] + a:sublist + li[index + 1:-1]
endfun
