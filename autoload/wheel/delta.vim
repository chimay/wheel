" vim: set ft=vim fdm=indent iskeyword&:

" Delta
"
" Undo list & diff

" ---- undo state

fun! wheel#delta#undo_iden (...)
	" Return undo iden at current or given line
	if a:0 > 0
		let linum = a:1
	else
		let linum = '.'
	endif
	if linum ==# '.'
		call wheel#teapot#filter_to_default_line ()
	elseif linum == 1
		let linum = wheel#teapot#first_data_line ()
	endif
	let line = getline(linum)
	let fields = split(line)
	let iden = str2nr(fields[0])
	return iden
endfun

fun! wheel#delta#earlier (bufnum)
	" Go to earlier state
	call wheel#rectangle#find_or_load (a:bufnum)
	earlier
	call wheel#cylinder#recall ()
endfun

fun! wheel#delta#later (bufnum)
	" Go to later state
	call wheel#rectangle#find_or_load (a:bufnum)
	later
	call wheel#cylinder#recall ()
endfun

fun! wheel#delta#last (bufnum)
	" Set buffer to last undo state
	if has_key(b:wheel_settings, 'undo_iden')
		let iden = b:wheel_settings.undo_iden
	else
		let iden = wheel#delta#undo_iden (1)
	endif
	call wheel#rectangle#find_or_load (a:bufnum)
	execute 'undo' iden
	call wheel#cylinder#recall ()
endfun

" ---- diff windows

fun! wheel#delta#close_diff (bufnum)
	" Wipe copy or original buffer
	let diff_buf = b:wheel_settings.diff_buf
	execute 'silent bwipe!' diff_buf
	call wheel#rectangle#find_or_load (a:bufnum)
	diffoff
	call wheel#cylinder#recall ()
endfun

" ---- maps

fun! wheel#delta#mappings ()
	" Maps for undo list mandala
	let bufnum = b:wheel_related.bufnum
	let map = 'nnoremap <buffer>'
	let coda = ')<cr>'
	" earlier or later
	let earlier = '<cmd>call wheel#delta#earlier('
	execute map '-' earlier .. bufnum .. coda
	execute map '<kminus>' earlier .. bufnum .. coda
	let later = '<cmd>call wheel#delta#later('
	execute map '+' later .. bufnum .. coda
	execute map '<kplus>' later .. bufnum .. coda
	" go to undo given by line
	let undolist = '<cmd>call wheel#line#undolist('
	execute map '<cr>' undolist .. bufnum .. coda
	" view diff between undo state and last one
	let undodiff = '<cmd>call wheel#line#undo_diff('
	" d does not work for it puts vim in operator pending mode
	execute map 'D' undodiff .. bufnum .. coda
	" close diff
	let closediff = '<cmd>call wheel#delta#close_diff('
	execute map 'x' closediff .. bufnum .. coda
	" undo, go to last state
	let last = '<cmd>call wheel#delta#last('
	execute map 'u' last .. bufnum .. coda
endfun
