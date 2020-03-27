" vim: ft=vim fdm=indent:

" Helpers

fun! wheel#gear#circular_plus (index, length)
	return (a:index + 1) % a:length
endfun

fun! wheel#gear#circular_minus (index, length)
	let index = (a:index - 1) % a:length
	if index < 0
		let index += a:length
	endif
	return index
endfun

fun! wheel#gear#project_root (markers)
	" Change local directory to root of project
	" where current buffer belongs
	if type(a:markers) == 1
		let markers = [a:markers]
	elseif type(a:markers) == 3
		let markers = a:markers
	else
		echomsg 'Wheel Project root : argument must be either a string or a list.'
	endif
	let dir = expand('%:p:h')
	exe 'lcd ' . dir
	let found = 0
	while 1
		for mark in markers
			if filereadable(mark) || isdirectory(mark)
				let found = 1
			endif
		endfor
		if found || dir == '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun
