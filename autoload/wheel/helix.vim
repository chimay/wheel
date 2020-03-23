" vim: set filetype=vim:

" Indexes

fun! wheel#helix#locations ()
	" Index of locations
	" Format : torus >> circle > location
endfu

fun! wheel#helix#circles ()
	" Index of circles
	" Format : torus >> circle
endfu

fun! wheel#helix#search_location ()
	" Search location in all toruses & circles
endfun

fun! wheel#helix#search_circle ()
	" Search circle in all toruses
endfun
