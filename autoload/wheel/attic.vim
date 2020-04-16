" vim: ft=vim fdm=indent:

" Most recently used files

fun! wheel#attic#record (file)
	" Add file to most recently used file list
	" Add new entry at the beginning of the list
	let attic = g:wheel_attic
	let coordin = wheel#referen#names()
	let entry = {}
	let entry.coordin = coordin
	let entry.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#remove_if_present (entry)
	let g:wheel_history = insert(g:wheel_history, entry, 0)
	let max = g:wheel_config.maxim.history
	let g:wheel_history = g:wheel_history[:max - 1]
endfu

