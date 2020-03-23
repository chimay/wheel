" vim: set filetype=vim:

" call wheel#referen#print()
" call wheel#vortex#next_torus()
" call wheel#vortex#prev_torus()
" call wheel#vortex#next_circle()
" call wheel#vortex#prev_circle()
" call wheel#vortex#next_location()
" call wheel#vortex#prev_location()

"au bufwritepost ~/racine/public/wheel/**.vim echomsg "Wheel buffer"

fun! TestArgs (...)
	echo join(a:000, '/')
endfun

command -nargs=* TestArgs :call TestArgs(<args>)
