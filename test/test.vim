" vim: set filetype=vim:

" call wheel#referen#print()
" call wheel#vortex#next_torus()
" call wheel#vortex#prev_torus()
" call wheel#vortex#next_circle()
" call wheel#vortex#prev_circle()
" call wheel#vortex#next_location()
" call wheel#vortex#prev_location()

"au bufwritepost ~/racine/public/wheel/**.vim echomsg "Wheel buffer"

fun! Complete(Arglead,Cmdline,CursorPos)
	return "toto\ntutu\ntiti\n"
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

fun! Plus(a, b)
	return a:a + a:b
endfu

fun! Minus(a, b)
	return a:a - a:b
endfu

" Ne marche pas
fun! Fonctionnelle(fn, value)
	fun! l:A(arg)
		return a:fn(arg, a:value)
	endfun
	return A
endfun

fun! ArgumentConstant(fn, value)
	return {arg -> a:fn(arg, a:value) }
endfu
