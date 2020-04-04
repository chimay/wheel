" vim: ft=vim fdm=indent:

" Changes of internal structure

fun! wheel#cuboctahedron#reorder (level, names)
	" Reorder current elements at level, following names
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
endfun
