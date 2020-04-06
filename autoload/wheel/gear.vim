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

fun! wheel#gear#filter (wordlist, index, value)
	" Whether value matches all words of wordlist. Keep surrounding folds.
	" index is not used, it’s just for compatibility with filter()
	let marker = split(&foldmarker, ',')[0]
	let length = strchars(a:value)
	let prelast = strcharpart(a:value, length - 2, 1)
	if prelast == marker
		return 1
	endif
	return wheel#gear#word_filter(a:wordlist, a:index, a:value)
endfun

fun! wheel#gear#fold_filter (wordlist, candidates)
	" Remove non-matching empty folds
	let marker = split(&foldmarker, ',')[0]
	let wordlist = a:wordlist
	let candidates = a:candidates
	let filtered = []
	if empty(candidates)
		return []
	endif
	for index in range(len(candidates) - 1)
		" --- Current line
		let cur_value = candidates[index]
		let cur_length = strchars(cur_value)
		" ending = >1 or >2 if fold start
		let cur_prelast = strcharpart(cur_value, cur_length - 2, 1)
		let cur_last = strcharpart(cur_value, cur_length - 1, 1)
		" --- Next line
		let next_value = candidates[index + 1]
		let next_length = strchars(next_value)
		let next_prelast = strcharpart(next_value, next_length - 2, 1)
		let next_last = strcharpart(next_value, next_length - 1, 1)
		" --- Comparison
		" if empty fold, value and next will contain marker
		" and current fold level will be >= than next one
		if cur_prelast == marker && next_prelast == marker && cur_last >= next_last
			" Add line only if matches wordlist
			if wheel#gear#word_filter(wordlist, index, cur_value)
				call add(filtered, cur_value)
			endif
		else
			call add(filtered, cur_value)
		endif
	endfor
	let value = candidates[-1]
	if wheel#gear#word_filter(wordlist, -1, value)
		call add(filtered, value)
	endif
	return filtered
endfun

