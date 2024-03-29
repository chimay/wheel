" vim: set ft=vim fdm=indent iskeyword&:

" Triangle
"
" Undo list dedicated buffer

fun! wheel#triangle#undolist ()
	" Undo list mandala
	call wheel#mandala#goto_related ()
	let bufname = bufname('%')
	let filename = fnamemodify(bufname, ':t')
	let lines = wheel#perspective#undolist ()
	call wheel#mandala#blank('undo/' .. filename)
	call wheel#mandala#template ()
	call wheel#delta#mappings ()
	call wheel#mandala#fill (lines)
	let b:wheel_settings.undo_iden = wheel#delta#undo_iden(1)
	" reload
	call wheel#mandala#set_reload('wheel#triangle#undolist')
endfun
