" vim: set filetype=vim:

" Completion {{{1

fun! Complete(Arglead,Cmdline,CursorPos)
	let list = ['toto', 'tutu', 'titi']
	return join(list, "\n")
endfun

fun! CompleteList(arglead,cmdline,cursorPos)
	let list = ['toto', 'tutu', 'titi']
	let regex = a:arglead . '.*'
	call filter(list, {ind, val -> val =~ regex })
	return list
endfun

fun! TestArgs (...)
	echo 'test args : ' join(a:000, '/')
endfun

command! -nargs=* -complete=custom,Complete TestArgs :call TestArgs(<args>)
command! -nargs=* -complete=custom,Complete TestQargs :call TestArgs(<q-args>)
command! -nargs=* -complete=custom,Complete TestFargs :call TestArgs(<f-args>)

command! -nargs=* -complete=customlist,CompleteList TestFargs :call TestArgs(<f-args>)

com! In      :echo input('Var ? ', '', 'custom,Complete')
com! Inlist  :echo input('Var ? ', '', 'customlist,CompleteList')

" }}}1

" Dictionaries {{{1

let s:a = {'un':1, 'deux': 2}
let s:b = {'trois':1, 'quatre': 2}
call extend(s:a, s:b, 'error')
echo 'script a : ' s:a
echo 'script b : ' s:b

" }}}1

" Brace names {{{1

let s:a = 'win'
let s:b = 's:a'

echo 'Brace name {s:b} : ' {s:b}
echo 'Brace name winnr = {s:a}nr : ' {s:a}nr()

" }}}1

" Identity {{{1

fun! s:Function (list, dict)
	let list = a:list
	let dict = a:dict
	echomsg 'is ? ' list is a:list dict is a:dict
endfun

call s:Function([1,2], {'i':1,'ii':2})

" }}}1

" Functions {{{1

" Optional arguments {{{2

fun! s:Function (...)
	return s:Called (a:000)
endfun

fun! s:Called (...)
	return a:000
endfun

echo 'Optional args : ' s:Function (1, 2)

" }}}2

" Func ref {{{2

fun! s:Plus(a, b)
	return a:a + a:b
endfu

fun! s:Minus(a, b)
	return a:a - a:b
endfu

echo 'plus 3 : ' function('s:Plus', [3])(4)
let s:Plus3 = function('s:Plus', [3])
echo 'plus3 : ' s:Plus3(4)

echo 'minus 3 : ' function('s:Minus', [3])(2)
let s:TreeMinus = function('s:Minus', [3])
echo 'minus3 : ' s:TreeMinus(2)

fun! s:Multi (fn)
	let r = a:fn(1, 2) + a:fn(3, 4)
	return r
endfun

" }}}2

" Lambda {{{2

echo 'lambda : ' {a -> 2 * a}(2)
let s:L = {a -> 2 * a}
echo 'lambda var : ' s:L(3)

fun! s:ArgumentConstant(fn, value)
	return {arg -> a:fn(arg, a:value) }
endfu

" }}}2

" Closure {{{2

fun! s:Fonctionnelle(fn, value)
	fun! Function(arg) closure
		return a:fn(a:arg, a:value)
	endfun
	return funcref('Function')
endfun

echo 'functional : ' s:Fonctionnelle(function('s:Minus'), 3)(7)
let s:F = s:Fonctionnelle(function('s:Minus'), 3)
echo 'functional : ' s:F(5)

" }}}2

" Dict func {{{2

" fun! Dico (arg) dict
" 	echo self.name a:arg
" endfun
"
" let d = {'name' : 'john'}
" let d.fn = function('Dico')
" call d.fn('Doe')
"
" let F = function('Dico', d)
" call F('Smith')
"
" let G = function('Dico', [], d)
" call G('Foo')
"
" fun! d.iam (arg) dict
" 	echo self.name a:arg
" endfun
"
" call d.iam('Bar')

" }}}2

" Recursivity {{{2

fun! s:Factorial (n)
	if a:n == 0
		return 1
	else
		return a:n * s:Factorial(a:n -1)
endfun

echo 'Factorial 5 :' s:Factorial(5)

" }}}2

" }}}1

" Autocommands {{{1

" Use noau w to really write the file
"au BufWriteCmd <buffer> echo 'autocommand replacing write'

" }}}1
