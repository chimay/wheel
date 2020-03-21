" vim: set filetype=vim:

" Helpers

fun! wheel#gear#template(name)
	" Generate template to add to g:wheel lists
	let template = {}
	let template.name = a:name
	return template
endfun

