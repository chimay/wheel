" vim: set ft=vim fdm=indent iskeyword&:

" Filter for :
"   - prompt completion
"   - dedicated buffers (mandalas)
"
" A kyusu is a japanese traditional teapot,
" often provided with a filter inside
"
" A gaiwan is a chinese tea cup

" script constants

if ! exists('s:fold_pattern')
	let s:fold_pattern = wheel#crystal#fetch('fold/pattern')
	lockvar s:fold_pattern
endif

if ! exists('s:unused')
	let s:unused = 0
	lockvar s:unused
endif

" helpers

fun! wheel#kyusu#steep (wordlist, unused, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	" unused argument is for compatibility with filter()
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

fun! wheel#kyusu#pour (wordlist, list)
	" Return elements of list matching words of wordlist
	let list = deepcopy(a:list)
	let Matches = function('wheel#kyusu#steep', [a:wordlist])
	let candidates = filter(list, Matches)
	return candidates
endfun

" dedicated buffers

fun! wheel#kyusu#intermix (wordlist, index, value, ternar)
	" Like kyusu#steep, but take special keywords into account
	" Arguments :
	"   - wordlist : filtering words
	"   - index : index in b:wheel_lines of value
	"   - value : mandala line tested with wordlist
	"   - ternar : ternary switches
	"     + selection
	"       * 1 if selection only
	"       * 0 if neutral
	"       * -1 is non-selection only
	let wordlist = a:wordlist
	let index = a:index
	let value = a:value
	let ternar = a:ternar
	" selection
	let sel_ter = ternar.selection
	let sel_indexes = b:wheel_selection.indexes
	let found = index->wheel#chain#is_inside(sel_indexes)
	let yang = sel_ter != 1 || found
	let yin = sel_ter != -1 || ! found
	" steep
	let steep = wordlist->wheel#kyusu#steep(s:unused, value)
	" coda
	let pass = yang && yin && steep
	return pass
endfun

fun! wheel#kyusu#remove_folds (wordlist, matrix, ternar)
	" Remove non-matching empty folds
	let wordlist = a:wordlist
	let matrix = a:matrix
	let ternar = a:ternar
	let indexlist = matrix[0]
	let candidates = matrix[1]
	if empty(candidates)
		return [ [], [] ]
	endif
	let length = len(candidates)
	let filtered_indexes = []
	let filtered_values = []
	" ---- all but last element
	for index in range(length - 1)
		" -- current line
		let cur_value = candidates[index]
		let cur_length = strchars(cur_value)
		let cur_last = strcharpart(cur_value, cur_length - 1, 1)
		let cur_last = str2nr(cur_last)
		" -- next line
		let next_value = candidates[index + 1]
		let next_length = strchars(next_value)
		let next_last = strcharpart(next_value, next_length - 1, 1)
		let next_last = str2nr(next_last)
		" -- comparison
		" if empty fold, value and next will contain marker
		" and current fold level will be >= than next one
		let empty_fold = cur_value =~ s:fold_pattern
		let empty_fold = empty_fold && next_value =~ s:fold_pattern
		let empty_fold = empty_fold && cur_last >= next_last
		let line_index = indexlist[index]
		if empty_fold
			" add line only if matches wordlist
			if wheel#kyusu#intermix (wordlist, line_index, cur_value, ternar)
				eval filtered_indexes->add(line_index)
				eval filtered_values->add(cur_value)
			endif
		else
			" always add line
			eval filtered_indexes->add(line_index)
			eval filtered_values->add(cur_value)
		endif
	endfor
	" ---- last element
	let index = length - 1
	let value = candidates[-1]
	if wheel#kyusu#intermix (wordlist, indexlist[index], value, ternar)
		let line_index = indexlist[index]
		eval filtered_indexes->add(line_index)
		eval filtered_values->add(value)
	endif
	return [filtered_indexes, filtered_values]
endfun

" indexes & lines

fun! wheel#kyusu#gaiwan ()
	" Return lines matching words of first line
	" Special keywords :
	"   - =s[selection] enable selection only filter
	"   - !=s[selection] enable non-selection only filter
	let linelist = copy(b:wheel_lines)
	let input = wheel#teapot#without_prompt ()
	if empty(input)
		let filtered_indexes = range(len(linelist))
		let filtered_values = linelist
		return [filtered_indexes, filtered_values]
	endif
	call wheel#scroll#record(input)
	let wordlist = split(input)
	" special words
	let ternar = {}
	let ternar.selection = 0
	for index in range(len(wordlist))
		if wordlist[index] =~ '^=s'
			let ternar.selection = 1
			eval wordlist->remove(index)
			break
		elseif wordlist[index] =~ '^!=s'
			let ternar.selection = -1
			eval wordlist->remove(index)
			break
		endif
	endfor
	" filter
	let filtered_indexes = []
	let filtered_values = []
	for index in range(len(linelist))
		let value = linelist[index]
		let pass = wheel#kyusu#intermix (wordlist, index, value, ternar)
		let pass = pass || value =~ s:fold_pattern
		if pass
			eval filtered_indexes->add(index)
			eval filtered_values->add(value)
		endif
	endfor
	let matrix = [filtered_indexes, filtered_values]
	" remove folds two times : cleans a level each time
	let matrix = wheel#kyusu#remove_folds (wordlist, matrix, ternar)
	let matrix = wheel#kyusu#remove_folds (wordlist, matrix, ternar)
	" return
	return matrix
endfun
