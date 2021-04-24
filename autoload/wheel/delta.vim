" vim: ft=vim fdm=indent:

" Undo list & diff

" Script constants

if ! exists('s:diff_options')
	let s:diff_options = wheel#crystal#fetch('diff/options')
	lockvar s:diff_options
endif

" Diff options

fun! wheel#delta#save_options ()
	" Save options before activating diff
	let b:wheel_options = wheel#gear#save_options (s:diff_options)
endfun

fun! wheel#delta#restore_options ()
	" Restore options to their state before diff
	call wheel#gear#restore_options (b:wheel_options)
endfun

" Maps

fun! wheel#delta#maps (bufnum)
	" Maps for undo list mandala
	let map  =  'nnoremap <silent> <buffer> '
	" go to undo given by line
	let pre  = ' :call wheel#line#undolist('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(a:bufnum) . post
	" view diff between undo state and last one
	let pre  = ' :call wheel#delta#diff('
	exe map . 'd' . pre . string(a:bufnum) . post
	" close diff
	let pre  = ' :call wheel#delta#close_diff('
	exe map . 'u' . pre . string(a:bufnum) . post
endfun

" Diff

fun! wheel#delta#diff (bufnum)
	" Visualize diff between last state & undo
	let winiden = win_findbuf(a:bufnum)[0]
	" original buffer
	call wheel#gear#win_gotoid (winiden)
	let save_filetype = &filetype
	" copy of original buffer
	vnew
	read #
	1 delete _
	let diff_buf = bufnr('%')
	call wheel#delta#save_options ()
	diffthis
	let &filetype = save_filetype
	setlocal nomodifiable readonly
	" back to mandala
	call wheel#cylinder#recall ()
	call wheel#line#undolist (a:bufnum)
	" original buffer
	call wheel#gear#win_gotoid (winiden)
	call wheel#delta#save_options ()
	diffthis
	" back to mandala
	call wheel#cylinder#recall ()
	let b:wheel_settings.diff_buf = diff_buf
endfun

fun! wheel#delta#close_diff (bufnum)
	" Wipe copy or original buffer
	let diff_buf = b:wheel_settings.diff_buf
	exe 'bwipe!' diff_buf
	let winiden = win_findbuf(a:bufnum)[0]
	call wheel#gear#win_gotoid (winiden)
	call wheel#delta#restore_options ()
	call wheel#cylinder#recall ()
endfun

" Undo list mandala

fun! wheel#delta#undolist ()
	" Undo list mandala
	if wheel#cylinder#is_mandala ()
		call wheel#mandala#close ()
	endif
	let lines = wheel#perspective#undolist ()
	let bufnum = bufnr('%')
	call wheel#vortex#update ()
	call wheel#mandala#open('undo')
	call wheel#mandala#template ()
	call wheel#delta#maps (bufnum)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = "wheel#delta#reload('" . bufnum . "')"
endfun

" Reload mandala

fun! wheel#delta#reload (bufnum)
	" Reload undolist
	let winiden = win_findbuf(a:bufnum)[0]
	call wheel#gear#win_gotoid (winiden)
	call wheel#delta#undolist ()
endfun
