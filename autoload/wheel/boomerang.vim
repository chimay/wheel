" vim: ft=vim fdm=indent:

" Contextual menus,
" acting back on a wheel buffer

fun! wheel#boomerang#maps (dictname)
	" Define local maps for menus
	let dictname = 'menu/' . a:dictname
	let settings = {'menu' : dictname, 'close' : 0, 'travel' : 1}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#layer#call('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(settings) . post
	let settings.close = 0
	exe map . 'g<cr>' . pre . string(settings) . post
	exe map . '<space>' . pre . string(settings) . post
endfun

fun! wheel#boomerang#common ()
	" Common things to all context menus
	let stack = b:wheel_stack
	" Sync selection with top (begin) of stack
	let b:wheel_selected = stack.selected[0]
endfun

fun! wheel#boomerang#switch ()
	" Switch context menu
endfun

fun! wheel#boomerang#grep ()
	" Grep context menu
endfun
