" vim: set ft=vim fdm=indent iskeyword&:

" Filter for :
"   - prompt completion
"   - dedicated buffers (mandalas)
"
" A kyusu is a japanese traditional teapot,
" often provided with a filter inside

" Script constants

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" helpers

fun! wheel#kyusu#wordlist (wordlist, index, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	" index is not used, it’s just for compatibility with filter()
	let wordlist = copy(a:wordlist)
	eval wordlist->map({ _, val -> substitute(val, '|', '\\|', 'g') })
	let match = v:true
	for word in wordlist
		if word !~ '\m^!'
			if a:value !~ word
				let match = v:false
				break
			endif
		else
			if a:value =~ word[1:]
				let match = v:false
				break
			endif
		endif
	endfor
	return match
endfun

" prompt completion

fun! wheel#kyusu#candidates (wordlist, list)
	" Return elements of list matching words of wordlist
	let Matches = function('wheel#kyusu#wordlist', [a:wordlist])
	let candidates = filter(a:list, Matches)
	return candidates
endfun

" dedicated buffers

fun! wheel#kyusu#words_or_folds (wordlist, index, value)
	" Like kyusu#wordlist, but keep folds markers lines
	" index is not used, it’s just for compatibility with filter()
	let marker = s:fold_markers[0]
	let pattern = '\m' .. marker .. '[12]$'
	if a:value =~ pattern
		return v:true
	endif
	return wheel#kyusu#wordlist (a:wordlist, 0, a:value)
endfun

fun! wheel#kyusu#remove_folds (wordlist, matrix)
	" Remove non-matching empty folds
	let wordlist = a:wordlist
	let matrix = a:matrix
	let indexlist = matrix[0]
	let candidates = matrix[1]
	if empty(candidates)
		return [ [], [] ]
	endif
	let marker = s:fold_markers[0]
	let pattern = '\m' .. marker .. '[12]$'
	let filtered_indexes = []
	let filtered_values = []
	" ---- all but last element
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
			if wheel#kyusu#wordlist (wordlist, 0, cur_value)
				eval filtered_indexes->add(indexlist[index])
				eval filtered_values->add(cur_value)
			endif
		else
			" Always add line
			eval filtered_indexes->add(indexlist[index])
			eval filtered_values->add(cur_value)
		endif
	endfor
	" ---- last element
	let value = candidates[-1]
	if wheel#kyusu#wordlist (wordlist, 0, value)
		eval filtered_indexes->add(indexlist[index])
		eval filtered_values->add(value)
	endif
	return [filtered_indexes, filtered_values]
endfun

fun! wheel#kyusu#indexes_and_lines ()
	" Return lines matching words of first line
	let linelist = copy(b:wheel_lines)
	let first = getline(1)
	let wordlist = split(first)
	if empty(wordlist)
		let filtered_indexes = range(len(linelist))
		let filtered_values = linelist
		return [filtered_indexes, filtered_values]
	endif
	call wheel#scroll#record(first)
	" filter with word_or_folds
	let filtered_indexes = []
	let filtered_values = []
	for index in range(len(linelist))
		let value = linelist[index]
		if wordlist->wheel#kyusu#words_or_folds(0, value)
			eval filtered_indexes->add(index)
			eval filtered_values->add(value)
		endif
	endfor
	let matrix = [filtered_indexes, filtered_values]
	" remove folds two times : cleans a level each time
	let matrix = wheel#kyusu#remove_folds (wordlist, matrix)
	let matrix = wheel#kyusu#remove_folds (wordlist, matrix)
	" return
	return matrix
endfu

" alternative implementation
"
" also works : uses chain#filter, matrix#dual

" fun! wheel#kyusu#indexes_and_lines ()
" 	" Return lines matching words of first line
" 	let linelist = copy(b:wheel_lines)
" 	let first = getline(1)
" 	let wordlist = split(first)
" 	if empty(wordlist)
" 		return linelist
" 	endif
" 	call wheel#scroll#record(first)
" 	" filter function
" 	let Matches = function('wheel#kyusu#words_or_folds', [wordlist, 0])
" 	" filtering
" 	let matrix = linelist->wheel#chain#filter(Matches)
" 	" two times : cleans a level each time
" 	let matrix = wheel#kyusu#remove_folds (wordlist, matrix)
" 	let matrix = wheel#kyusu#remove_folds (wordlist, matrix)
" 	" Return
" 	return matrix
" endfu
