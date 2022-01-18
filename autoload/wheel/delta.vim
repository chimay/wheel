" vim: set ft=vim fdm=indent iskeyword&:

" Undo list & diff

" other names ideas for this file :
"
" triangle

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
		let line = wheel#teapot#first_data_line ()
	endif
	let line = getline(line)
	let fields = split(line)
	let iden = str2nr(fields[0])
	return iden
endfun

fun! wheel#delta#earlier (bufnum)
	" Go to earlier state
	call wheel#rectangle#goto_or_load (a:bufnum)
	earlier
	call wheel#cylinder#recall ()
endfun

fun! wheel#delta#later (bufnum)
	" Go to later state
	call wheel#rectangle#goto_or_load (a:bufnum)
	later
	call wheel#cylinder#recall ()
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

" Diff windows

fun! wheel#delta#close_diff (bufnum)
	" Wipe copy or original buffer
	let diff_buf = b:wheel_settings.diff_buf
	execute 'bwipe!' diff_buf
	call wheel#rectangle#goto_or_load (a:bufnum)
	call wheel#delta#restore_options ()
	call wheel#cylinder#recall ()
endfun

fun! wheel#delta#last (bufnum)
	" Set buffer to last undo state
	if has_key(b:wheel_settings, 'undo_iden')
		let iden = b:wheel_settings.undo_iden
	else
		let iden = wheel#delta#undo_iden (1)
	endif
	call wheel#rectangle#goto_or_load (a:bufnum)
	execute 'undo' iden
	call wheel#cylinder#recall ()
endfun

" Maps

fun! wheel#delta#maps ()
	" Maps for undo list mandala
	let bufnum = b:wheel_related_buffer
	let map = 'nnoremap <silent> <buffer>'
	let post = ')<cr>'
	" earlier or later
	let pre = '<cmd>call wheel#delta#earlier('
	execute map '-' pre .. bufnum .. post
	execute map '<kminus>' pre .. bufnum .. post
	let pre = '<cmd>call wheel#delta#later('
	execute map '+' pre .. bufnum .. post
	execute map '<kplus>' pre .. bufnum .. post
	" go to undo given by line
	let pre = '<cmd>call wheel#line#undolist('
	execute map '<cr>' pre .. bufnum .. post
	" view diff between undo state and last one
	let pre = '<cmd>call wheel#line#undo_diff('
	" d does not work for it puts vim in operator pending mode
	execute map 'D' pre .. bufnum .. post
	" close diff
	let pre = '<cmd>call wheel#delta#close_diff('
	execute map 'x' pre .. bufnum .. post
	" undo, go to last state
	let pre = '<cmd>call wheel#delta#last('
	execute map 'u' pre .. bufnum .. post
endfun

" Undo list mandala

fun! wheel#delta#undolist ()
	" Undo list mandala
	call wheel#mandala#related ()
	let bufname = bufname(bufnr('%'))
	let filename = fnamemodify(bufname, ':t')
	let lines = wheel#perspective#undolist ()
	call wheel#mandala#open('undo/' .. filename)
	call wheel#mandala#template ()
	call wheel#delta#maps ()
	call wheel#mandala#fill (lines)
	let b:wheel_settings.undo_iden = wheel#delta#undo_iden(1)
	" reload
	let b:wheel_reload = 'wheel#delta#undolist'
endfun
