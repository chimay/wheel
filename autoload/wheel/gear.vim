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
	if type(a:markers) == v:t_string
		let markers = [a:markers]
	elseif type(a:markers) == v:t_list
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
				break
			endif
		endfor
		if found || dir == '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun

fun! wheel#gear#word_filter (wordlist, index, value)
	" Whether value matches all words of wordlist
	" index is not used, it’s just for compatibility with filter()
	let match = 1
	for word in a:wordlist
		let pattern = '.*' . word . '.*'
		if a:value !~ pattern
			let match = 0
			break
		endif
	endfor
	return match
endfun

fun! wheel#gear#fold_filter (wordlist, index, value)
	" Whether value matches all words of wordlist ; keep fold parents
	" index is not used, it’s just for compatibility with filter()
	let length = strlen(a:value)
	if a:value[length - 1] == '>' || a:value == '<'
		return 1
	endif
	let match = 1
	for word in a:wordlist
		let pattern = '.*' . word . '.*'
		if a:value !~ pattern
			let match = 0
			break
		endif
	endfor
	return match
endfun
