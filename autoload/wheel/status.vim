" vim: ft=vim fdm=indent:

fun! wheel#status#dashboard ()
	" Display dashboard, summary of current wheel status
	if has('nvim')
		let [cur_torus, cur_circle, cur_location] = wheel#referen#location('all')
		let string = cur_torus.name . ' > '
		let string .= cur_circle.name . ' > '
		let string .= cur_location.name . ' : '
		let string .= cur_location.file . ':' . cur_location.line . ':' . cur_location.col
		echomsg string
		redraw!
	endif
endfun

fun! wheel#status#tabline ()
	" Tab line text
	let g:wheel_shelve.tabline_backup = &tabline
endfun
