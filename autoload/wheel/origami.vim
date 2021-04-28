" vim: ft=vim fdm=indent:

" Folding

" Script constants

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Fold for torus, circle and location

fun! wheel#origami#fold_level ()
	" Wheel level of fold line : torus, circle or location
	if ! &foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'torus'
	elseif line =~ s:fold_2
		return 'circle'
	else
		return 'location'
	endif
endfun

fun! wheel#origami#parent_fold ()
	" Go to line of parent fold in wheel tree
	let level = wheel#origami#fold_level ()
	if level == 'circle'
		let pattern = '\m' . s:fold_1 . '$'
	elseif level == 'location'
		let pattern = '\m' . s:fold_2 . '$'
	else
		" torus line : we stay there
		return
	endif
	call search(pattern, 'b')
endfun

" Fold for tabs & windows

fun! wheel#origami#tabwin_level ()
	" Level of fold line : tab or filename
	if ! &foldenable
		echomsg 'wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'tab'
	else
		return 'filename'
	endif
endfun

fun! wheel#origami#parent_tabwin ()
	" Go to line of parent fold in tabwin tree
	let level = wheel#origami#tabwin_level ()
	if level == 'filename'
		let pattern = '\m' . s:fold_1 . '$'
		call search(pattern, 'b')
	else
		" tab line : we stay there
		return
	endif
endfun

