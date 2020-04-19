" vim: ft=vim fdm=indent:

" Contextual menus,
" acting back on a wheel buffer

fun! wheel#boomerang#common ()
	" Common things to all context menus
	let stack = b:wheel_stack
	" Sync selection with top (begin) of stack
	let b:wheel_selected = stack.selected[0]
endfun
