" vim: ft=vim fdm=indent:

" Auto grouping

fun! wheel#group#extension()
	" Filename extension
endfun

fun! wheel#group#directory(depth)
	" Depth levels of directory
endfun

fun! wheel#group#auto(dispatch)
	" Auto grouping
	if type(a:dispatch) == v:t_func
		let Fun = a:dispatch
	elseif type(a:dispatch) == v:t_string
		let Fun = function(a:dispatch)
	else
		echoerr 'wheel#group#auto : bad argument format'
	endif
	let torus = wheel#referen#current('torus')
	for circle in torus.circles
		for location in circle.locations
		endfor
	endfor
endfun
