" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding helpers

fun! wheel#origami#view_cursor ()
	" Unfold to view cursor line
	if &foldopen =~ 'jump'
		normal! zv
	endif
endfun
