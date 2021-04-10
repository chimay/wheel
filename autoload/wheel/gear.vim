" vim: ft=vim fdm=indent:

" Generic helpers

" Script vars

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Rotating

fun! wheel#gear#circular_plus (index, length)
	" Rotate/increase index with modulo
	return (a:index + 1) % a:length
endfun

fun! wheel#gear#circular_minus (index, length)
	" Rotate/decrease index with modulo
	let index = (a:index - 1) % a:length
	if index < 0
		let index += a:length
	endif
	return index
endfun

" Cursor

fun! wheel#gear#restore_cursor (position, ...)
	" Restore cursor position
	if a:0 > 0
		let default = a:1
	else
		let default = '$'
	endif
	let position = a:position
	if line('$') > position[1]
		call setpos('.', position)
	else
		call cursor(default, 1)
	endif
endfun

" Fold for torus, circle and location

fun! wheel#gear#fold_level ()
	" Wheel level of fold line : torus, circle or location
	if ! &foldenable
		echomsg 'Wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'torus'
	elseif line =~ s:fold_2
		return 'circle'
	else
		return 'location'
	endif
endfun

fun! wheel#gear#parent_fold ()
	" Go to line of parent fold in wheel tree
	let level = wheel#gear#fold_level ()
	if level == 'circle'
		let pattern = '\m' . s:fold_1 . '$'
	elseif level == 'location'
		let pattern = '\m' . s:fold_2 . '$'
	else
		" torus line : we stay there
		return
	endif
	call search(pattern, 'b')
endfun

" Fold for tab & windows

fun! wheel#gear#tabwin_level ()
	" Level of fold line : tab or filename
	if ! &foldenable
		echomsg 'Wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'tab'
	else
		return 'filename'
	endif
endfun

fun! wheel#gear#parent_tabwin ()
	" Go to line of parent fold in tabwin tree
	let level = wheel#gear#tabwin_level ()
	if level == 'filename'
		let pattern = '\m' . s:fold_1 . '$'
		call search(pattern, 'b')
	else
		" tab line : we stay there
		return
	endif
endfun

" Directory

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
	exe 'lcd' dir
	let found = 0
	while v:true
		for mark in markers
			if filereadable(mark) || isdirectory(mark)
				let found = 1
				break
			endif
		endfor
		if found || dir ==# '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun

" Filter

fun! wheel#gear#word_filter (wordlist, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	let wordlist = copy(a:wordlist)
	call map(wordlist, {_, val -> substitute(val, '|', '\\|', 'g')})
	let match = 1
	for word in wordlist
		if word !~ '\m^!'
			if a:value !~ word
				let match = 0
				break
			endif
		else
			if a:value =~ word[1:]
				let match = 0
				break
			endif
		endif
	endfor
	return match
endfun

fun! wheel#gear#tree_filter (wordlist, index, value)
	" Like word_filter, but keep surrounding folds
	" index is not used, it’s just for compatibility with filter()
	let marker = s:fold_markers[0]
	let pattern = '\m' . marker . '[12]$'
	if a:value =~ pattern
		return v:true
	endif
	return wheel#gear#word_filter(a:wordlist, a:value)
endfun

fun! wheel#gear#fold_filter (wordlist, candidates)
	" Remove non-matching empty folds
	let wordlist = a:wordlist
	let candidates = a:candidates
	if empty(candidates)
		return []
	endif
	let marker = s:fold_markers[0]
	let pattern = '\m' . marker . '[12]$'
	let filtered = []
	for index in range(len(candidates) - 1)
		" --- Current line
		let cur_value = candidates[index]
		let cur_length = strchars(cur_value)
		" Last char of fold start line contains fold level 1 or 2
		let cur_last = strcharpart(cur_value, cur_length - 1, 1)
		" --- Next line
		let next_value = candidates[index + 1]
		let next_length = strchars(next_value)
		" Last char of fold start line contains fold level 1 or 2
		let next_last = strcharpart(next_value, next_length - 1, 1)
		" --- Comparison
		" if empty fold, value and next will contain marker
		" and current fold level will be >= than next one
		if cur_value =~ pattern && next_value =~ pattern && cur_last >= next_last
			" Add line only if matches wordlist
			if wheel#gear#word_filter(wordlist, cur_value)
				call add(filtered, cur_value)
			endif
		else
			call add(filtered, cur_value)
		endif
	endfor
	let value = candidates[-1]
	if wheel#gear#word_filter(wordlist, value)
		call add(filtered, value)
	endif
	return filtered
endfun

" Unmap

fun! wheel#gear#unmap (key, mode)
	" Unmap buffer mapping key in mode
	" Dictionary with map caracteristics
	let key = a:key
	let mode = a:mode
	let typekey = type(key)
	if typekey == v:t_string
		let dict = maparg(key, mode, 0, 1)
		if ! empty(dict) && dict.buffer
			let pre = mode . 'unmap <buffer> '
			let runme = pre . key
			exe runme
		endif
	elseif typekey == v:t_list
		for elem in key
			call wheel#gear#unmap(elem, mode)
		endfor
	else
		echomsg 'Wheel gear unmap : bad key format'
	endif
endfun

" Misc

fun! wheel#gear#decrease_greater(number, treshold)
	" Return number - 1 if > treshold, else return number
	if a:number > a:treshold
		return a:number - 1
	else
		return a:number
	endif
endfun
