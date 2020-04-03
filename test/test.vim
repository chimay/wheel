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
	echo join(a:000, '/')
endfun

command! -nargs=* -complete=custom,Complete TestArgs :call TestArgs(<args>)
command! -nargs=* -complete=custom,Complete TestQargs :call TestArgs(<q-args>)
command! -nargs=* -complete=custom,Complete TestFargs :call TestArgs(<f-args>)

command! -nargs=* -complete=customlist,CompleteList TestFargs :call TestArgs(<f-args>)

com! In      :echo input('Var ? ', '', 'custom,Complete')
com! Inlist  :echo input('Var ? ', '', 'customlist,CompleteList')

" }}}1

" Functions {{{1

fun! Plus(a, b)
	return a:a + a:b
endfu

fun! Minus(a, b)
	return a:a - a:b
endfu

" Func ref {{{2

echo function('Plus', [3])(4)
let Plus3 = function('Plus', [3])
echo Plus3(4)

echo function('Minus', [3])(2)
let TreeMinus = function('Minus', [3])
echo TreeMinus(2)

" }}}2

" Lambda {{{2

echo {a -> 2 * a}(2)
let L = {a -> 2 * a}
echo L(3)

fun! ArgumentConstant(fn, value)
	return {arg -> a:fn(arg, a:value) }
endfu

" }}}2

" Closure {{{2

fun! Fonctionnelle(fn, value)
	fun! Fun(arg) closure
		return a:fn(a:arg, a:value)
	endfun
	return funcref('Fun')
endfun

echo Fonctionnelle(function('Minus'), 3)(7)
let F = Fonctionnelle(function('Minus'), 3)
echo F(5)

" }}}2

" Dict func {{{2

fun! Dico (arg) dict
	echo self.name a:arg
endfun

let d = {'name' : 'john'}
let d.fn = function('Dico')
call d.fn('Doe')

let F = function('Dico', d)
call F('Smith')

let G = function('Dico', [], d)
call G('Foo')

fun! d.iam (arg) dict
	echo self.name a:arg
endfun

call d.iam('Bar')

fun! Retour ()
	return
endfu

" }}}2

" }}}1

" Autocommands {{{1

" Use noau w to really write the file
"au BufWriteCmd <buffer> echo 'autocommand replacing write'

" }}}1
