" vim: set ft=vim fdm=indent iskeyword&:

" Chain
"
" Lists operations

" ---- booleans

fun! wheel#chain#is_inside (element, list)
	" Whether element is in list
	let index = a:list->index(a:element)
	if index >= 0
		return v:true
	else
		return v:false
	endif
endfun

" ---- insert

fun! wheel#chain#insert_next (list, index, new)
	" Insert new element in list just after index
	let list = a:list
	let index = a:index + 1
	let new = a:new
	if empty(list)
		return add(list, new)
	endif
	if index < len(list)
		return list->insert(new, index)
	elseif index == len(list)
		" could be done with
		" insert(list, new, len(list))
		return list->add(new)
	endif
endfun

fun! wheel#chain#insert_after (list, element, new)
	" Insert new in list just after element
	let index = a:list->index(a:element)
	return a:list->wheel#chain#insert_next(index, a:new)
endfun

fun! wheel#chain#insert_sublist (list, sublist, index)
	" Insert sublist at index in sublist
	let list = a:list
	let sublist = a:sublist
	let index = a:index
	if index == 0
		return deepcopy(sublist) + deepcopy(list)
	endif
	return deepcopy(list[:index - 1]) + deepcopy(sublist) + deepcopy(list[index:])
endfun

" ---- remove

fun! wheel#chain#remove_index (list, index)
	" Remove element at index from list ; return list
	eval a:list->remove(a:index)
	" note : remove() returns the removed element
	" so we need to explicitly return the list
	return a:list
endfun

fun! wheel#chain#remove_element (list, element)
	" Remove element from list
	let list = a:list
	let element = a:element
	let index = list->index(element)
	if index >= 0
		eval list->remove(index)
	endif
	return list
endfun

fun! wheel#chain#remove_all_elements (list, element)
	" Remove all elements == element from list
	let list = a:list
	let element = a:element
	let index = list->index(element)
	while index >= 0
		eval list->remove(index)
		let index = list->index(element)
	endwhile
	return list
endfun

" ---- move

fun! wheel#chain#move (list, from, target)
	" Move element at index from -> target in list
	let list = a:list
	let from = a:from
	let target = a:target
	if from < target
		if from == 0
			let list = list[1:target] + [list[0]] + list[target+1:]
		else
			let list = list[:from-1] + list[from+1:target] + [list[from]] + list[target+1:]
		endif
	elseif from > target
		if target == 0
			let list = [list[from]] + list[target:from-1] + list[from+1:]
		else
			let list = list[:target-1] + [list[from]] + list[target:from-1] + list[from+1:]
		endif
	endif
	return list
endfun

" ---- replace

fun! wheel#chain#replace (list, old, new)
	" Replace old by new in list
	let list = a:list
	let old = a:old
	let new = a:new
	let index = list->index(old)
	if index >= 0
		let list[index] = new
	endif
	return list
endfun

fun! wheel#chain#replace_all (list, old, new)
	" Replace all occurences of old by new in list
	let list = a:list
	let old = a:old
	let new = a:new
	let index = list->index(old)
	while index >= 0
		let list[index] = new
		let index = list->index(old)
	endwhile
	return list
endfun

" ---- stack

fun! wheel#chain#push_unique (list, element)
	" Push element at beginning of list and remove duplicates
	let list = a:list
	let element = a:element
	eval list->wheel#chain#remove_all_elements(element)
	eval list->insert(element)
	return list
endfun

fun! wheel#chain#push_max (list, element, maxim)
	" Push element at beginning of list and remove elements beyond maxim
	let list = a:list
	let element = a:element
	let maxim = a:maxim
	eval list->insert(element)
	let list = list[:maxim - 1]
	return list
endfun

fun! wheel#chain#pop (list)
	" Remove first element from list ; return it
	return remove(a:list, 0)
endfun

" ---- rotation

fun! wheel#chain#rotate_left (list)
	" Rotate list to the left
	if len(a:list) > 1
		let rotated = deepcopy(a:list[1:]) + deepcopy([a:list[0]])
	else
		let rotated = deepcopy(a:list)
	endif
	return rotated
endfun

fun! wheel#chain#rotate_right (list)
	" Rotate list to the right
	if len(a:list) > 1
		let rotated = deepcopy([a:list[-1]]) + deepcopy(a:list[:-2])
	else
		let rotated = deepcopy(a:list)
	endif
	return rotated
endfun

fun! wheel#chain#roll_left (list, index)
	" Roll index in list until left = beginning
	let index = a:index
	let list = a:list
	if index > 0 && index < len(list)
		return deepcopy(list[index:]) + deepcopy(list[0:index - 1])
	else
		return deepcopy(list)
	endif
endfun

fun! wheel#chain#roll_right (list, index)
	" Roll index of list until right = end
	let index = a:index
	let list = a:list
	if index >= 0 && index < len(list) - 1
		return deepcopy(list[index + 1:-1]) + deepcopy(list[0:index])
	else
		return deepcopy(list)
	endif
endfun

" ---- swap

fun! wheel#chain#swap_first_two (list)
	" Swap first and second element of list
	if len(a:list) > 1
		return deepcopy([a:list[1]]) + deepcopy([a:list[0]]) + deepcopy(a:list[2:])
	else
		return deepcopy(a:list)
	endif
endfun

" ---- sublist at indexes of list

fun! wheel#chain#sublist (list, indexes)
	" Returns list[indexes]
	let sublist = []
	for ind in a:indexes
		eval sublist->add(deepcopy(a:list[ind]))
	endfor
	return sublist
endfun

" ---- range of indexes

fun! wheel#chain#rangelen (list)
	" Return range from 0 -> length list - 1
	return range(len(a:list))
endfun

" ---- list indexes from filtered sublist

fun! wheel#chain#indexes (list, sublist)
	" Returns indexes of list that give sublist
	" Reverse function of chain#sublist.
	" If indexes are sorted in ascending order, after :
	"   let sublist = list->wheel#chain#sublist(indexes)
	"   let other_indexes = list->wheel#chain#indexes(sublist)
	" you should have indexes = other_indexes
	" Unfortunate that filter() doesnt return this
	let list = a:list
	let sublist = a:sublist
	let stardict = {}
	let indexes = []
	for element in sublist
		if ! has_key(stardict, element)
			let where = list->index(element)
		else
			let start = stardict[element]
			let where = list->index(element, start)
		endif
		let stardict[element] = where + 1
		eval indexes->add(where)
	endfor
	return indexes
endfun

" ---- extrema

fun! wheel#chain#argmin (list)
	" Returns indexes where list[index] = min(list)
	let list = a:list
	let minimum = min(list)
	let indexes = []
	for ind in wheel#chain#rangelen(list)
		if list[ind] == minimum
			eval indexes->add(ind)
		endif
	endfor
	return indexes
endfun

fun! wheel#chain#argmax (list)
	" Returns indexes where list[index] = max(list)
	let list = a:list
	let maximum = max(list)
	let indexes = []
	for ind in wheel#chain#rangelen(list)
		if list[ind] == maximum
			eval indexes->add(ind)
		endif
	endfor
	return indexes
endfun

" ---- filter

fun! wheel#chain#filter (list, function, indexes = [])
	" Return filtered [indexes, elements] of list
	let list = deepcopy(a:list)
	let Fun = wheel#gear#function(a:function)
	let indexes = deepcopy(a:indexes)
	if empty(indexes)
		let indexes = wheel#chain#rangelen(list)
	endif
	let matrix = [indexes, list]
	" list of pairs [ind, elem]
	let dual = wheel#matrix#dual (matrix)
	eval dual->filter({ _, pair -> Fun(pair[1]) })
	let matrix = wheel#matrix#dual (dual)
	if empty(matrix)
		return [ [], [] ]
	endif
	return matrix
endfun

" ---- sort

fun! wheel#chain#compare (first, second)
	" Compare arguments ; used to sort
	let first = a:first
	let second = a:second
	if first > second
		return 1
	elseif first == second
		return 0
	else
		return -1
	endif
endfun

fun! wheel#chain#compare_first (first, second)
	" Compare first elements of lists arguments
	return wheel#chain#compare(a:first[0], a:second[0])
endfun

fun! wheel#chain#fun_cmp_1st (...)
	" Returns function that compare first elements of lists
	if a:0 > 0
		if type(a:1) == v:t_func
			let Fun = a:1
		elseif type(a:1) == v:t_string
			let Fun = funcref(a:1)
		else
			echomsg 'wheel chain fun cmp 1st : bad argument format'
		endif
	else
		lef Fun = funcref('wheel#chain#compare')
	endif
	fun! s:compare (first, second) closure
		return Fun(a:first[0], a:second[0])
	endfun
	return funcref('s:compare')
endfun

fun! wheel#chain#sort (list, ...)
	" Returns sorted list and indexes to recover the original list
	" Returns [shuffled_indexes, sorted_list], where :
	" - sorted_list is ... the sorted list
	" - shuffled_indexes are the indexes shuffled by the sorting
	if a:0 > 0
		let Cmp = wheel#chain#fun_cmp_1st (a:1)
	else
		let Cmp = 'wheel#chain#compare_first'
	endif
	let list = deepcopy(a:list)
	let indexes = wheel#chain#rangelen(list)
	let dual = wheel#matrix#dual([list, indexes])
	call sort(dual, Cmp)
	let [sorted, indexes] = wheel#matrix#dual(dual)
	return [indexes, sorted]
endfun

fun! wheel#chain#revert_sort (list, indexes)
	" Revert sort in list by reordering indexes from smallest to biggest
	" Returns [revert_indexes, original_list]
	let Cmp = 'wheel#chain#compare_first'
	let list = deepcopy(a:list)
	let indexes = a:indexes
	if len(list) != len(indexes)
		echomsg 'wheel chain revert sort : arguments are not of the same length'
	endif
	let matrix = [indexes, list]
	let dual = wheel#matrix#dual(matrix)
	let [revert_indexes, nested] = wheel#chain#sort(dual, Cmp)
	let [indexes, list] = wheel#matrix#dual(nested)
	return [revert_indexes, list]
endfun

" ---- unique

fun! wheel#chain#unique (list, ...)
	" Remove duplicates elements, preserve original order
	if a:0 > 0
		let Cmp = wheel#chain#fun_cmp_1st (a:1)
	else
		let Cmp = 'wheel#chain#compare_first'
	endif
	" wheel#chain#sort makes a copy
	let list = a:list
	" sort
	let [indexes, sorted] = call('wheel#chain#sort', [list] + a:000)
	" uniq
	let dual = wheel#matrix#dual ([sorted, indexes])
	call uniq(dual, Cmp)
	" revert sort
	let [sorted, indexes] = wheel#matrix#dual (dual)
	let [rev_ind, unique] = wheel#chain#revert_sort (sorted, indexes)
	" return
	return unique
endfun

" ---- fill the gaps

fun! wheel#chain#tie (list)
	" Shift integer elements of the list to fill the gaps
	let list = a:list
	let minim = min(list)
	let maxim = max(list)
	let numbers = reverse(range(minim, maxim))
	let index = 0
	let length = len(numbers)
	let gaps = []
	for elem in numbers
		if ! wheel#chain#is_inside(elem, list)
			eval list->map({ _, val -> wheel#gear#decrease_greater(val, elem) })
			eval gaps->add(elem)
		endif
	endfor
	return [list, gaps]
endfun

fun! wheel#chain#lowest_outside (list, start = 0)
	" Returns lowest integer >= start that is not in list
	let list = a:list
	let start = a:start
	let engulf = start
	while wheel#chain#is_inside(engulf, list)
		let engulf += 1
	endwhile
	return engulf
endfun
