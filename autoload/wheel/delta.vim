" vim: ft=vim fdm=indent:

" Undo list & diff

" Script constants

if ! exists('s:diff_options')
	let s:diff_options = wheel#crystal#fetch('diff/options')
	lockvar s:diff_options
endif

" Helpers

fun! wheel#delta#undo_iden (...)
	" Return undo iden at current or given line
	if a:0 > 0
		let line = a:1
	else
		let line = '.'
	endif
	if line == '.'
		call wheel#line#default ()
	elseif line == 1
		let line = wheel#mandala#first_data_line ()
	endif
	let line = getline(line)
	let fields = split(line)
	let iden = str2nr(fields[0])
	return iden
endfun

fun! wheel#delta#bufwin (bufnum)
	" Go to window of bufnum if visible, or put it in first window of tab
endfun

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
	let pre  = ' :call wheel#line#undo_diff('
	" d does not work for it puts vim in operator pending mode
	exe map . 'D' . pre . string(a:bufnum) . post
	" close diff
	let pre  = ' :call wheel#delta#close_diff('
	exe map . 'x' . pre . string(a:bufnum) . post
endfun

" Diff

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
