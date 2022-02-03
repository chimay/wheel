
fun! s:local (arg)
	echo 'hello'
	return 2 * a:arg
endfun

echo s:local (6)
