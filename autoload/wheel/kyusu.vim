" vim: set ft=vim fdm=indent iskeyword&:

" Filter for prompt completion & mandalas
"
" A kyusu is a japanese traditional teapot,
" often provided with a filter inside

" Script constants

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" Filters

fun! wheel#kyusu#word (wordlist, index, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	" index is not used, it’s just for compatibility with filter()
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

fun! wheel#kyusu#tree (wordlist, index, value)
	" Like word filter, but keep folds markers lines
	" index is not used, it’s just for compatibility with filter()
	let marker = s:fold_markers[0]
	let pattern = '\m' . marker . '[12]$'
	if a:value =~ pattern
		return v:true
	endif
	return wheel#kyusu#word(a:wordlist, 0, a:value)
endfun

fun! wheel#kyusu#fold (wordlist, candidates)
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
			if wheel#kyusu#word(wordlist, 0, cur_value)
				call add(filtered, cur_value)
			endif
		else
			call add(filtered, cur_value)
		endif
	endfor
	let value = candidates[-1]
	if wheel#kyusu#word(wordlist, 0, value)
		call add(filtered, value)
	endif
	return filtered
endfun

fun! wheel#kyusu#line ()
	" Return lines matching words of first line
	let linelist = copy(b:wheel_lines)
	let first = getline(1)
	let wordlist = split(first)
	if empty(wordlist)
		return linelist
	endif
	call wheel#scroll#record(first)
	let Matches = function('wheel#kyusu#tree', [wordlist])
	let candidates = filter(linelist, Matches)
	" two times : cleans a level each time
	let filtered = wheel#kyusu#fold(wordlist, candidates)
	let filtered = wheel#kyusu#fold(wordlist, filtered)
	" Return
	return filtered
endfu
