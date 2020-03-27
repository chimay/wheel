" vim: ft=vim fdm=indent:

" Helpers

fun! wheel#gear#circular_plus (index, length)
	return float2nr(fmod(a:index + 1, a:length))
endfun

fun! wheel#gear#circular_minus (index, length)
	let index = float2nr(fmod(a:index - 1, a:length))
	if index < 0
		let index += a:length
	endif
	return index
endfun

fun! wheel#gear#project_root (marker)
	" Change local directory to root of project
	" where current buffer belongs
	let dir = expand('%:p:h')
	exe 'lcd ' . dir
	while ! filereadable(a:marker) && ! isdirectory(a:marker)
		if dir ==# '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun
