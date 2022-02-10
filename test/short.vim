" vim: set ft=vim fdm=indent iskeyword&:

fun! s:local (arg)
	echo 'hello'
	return 2 * a:arg
endfun

echo s:local (6)

echo exists('*s:local')

echo wheel#chain#rotate_left(range(9))
echo wheel#chain#rotate_right(range(9))
echo wheel#chain#swap_first_two(range(9))
echo wheel#chain#sublist(range(9), [2,1,3])
