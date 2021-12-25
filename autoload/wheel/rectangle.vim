" vim: set ft=vim fdm=indent iskeyword&:

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" Tabs, Windows & buffers

fun! wheel#rectangle#glasses (filename, ...)
	" Return list of window(s) id(s) displaying filename
	" Optional argument : if tab, search only in current tab
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'all'
	endif
	let wins = win_findbuf(bufnr(a:filename))
	if mode == 'tab'
		let tabnum = tabpagenr()
		call filter(wins, {_, val -> win_id2tabwin(val)[0] == tabnum})
	endif
	return wins
endfun

fun! wheel#rectangle#tour ()
	" Return closest candidate amongst windows displaying current location
	" by exploring each one
	" Prefer windows in current tab page
	" return v:false if no window display filename
	let original = win_getid()
	let location = wheel#referen#location()
	let filename = location.file
	let line = location.line
	let glasses = wheel#rectangle#glasses (filename, 'tab')
	if empty(glasses)
		let glasses = wheel#rectangle#glasses (filename, 'all')
	endif
	if empty(glasses)
		return v:false
	endif
	let best = glasses[0]
	call win_gotoid(best)
	let best_delta = abs(line - line('.'))
	for index in range(1, len(glasses) - 1)
		let new = glasses[index]
		call win_gotoid(new)
		let new_delta = abs(line - line('.'))
		if new_delta < best_delta
			let best_delta = new_delta
			let best = new
		endif
	endfor
	call win_gotoid(original)
	return best
endfun

fun! wheel#rectangle#tab_buffers ()
	" List of buffers in current tab, starting with current one
	let bufnum = bufnr('%')
	let buffers = tabpagebuflist()
	let index = index(buffers, bufnum)
	let buffers = wheel#chain#roll_left(index, buffers)
	return buffers
endfun

fun! wheel#rectangle#goto (bufnum, ...)
	" Go to window of buffer given by bufnum
	" The window is the first one displaying bufnum buffer
	" Optional argument : if tab, search only in current tab
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'all'
	endif
	let bufnum = a:bufnum
	" search in current tab
	if mode == 'tab'
		let winnr = bufwinnr(bufnum)
		if winnr > 0
			exe winnr 'wincmd w'
			return v:true
		else
			return v:false
		endif
	endif
	" search everywhere
	let winds = win_findbuf(bufnum)
	if ! empty(winds)
		let winiden = winds[0]
		call win_gotoid(winiden)
	else
		return v:false
	endif
	return v:true
endfun

fun! wheel#rectangle#switch (...)
	" Switch to tab & window of visible buffer
	let prompt = 'Switch to visible buffer : '
	let complete =  'customlist,wheel#completelist#visible_buffers'
	if a:0 > 0
		let file_tab_win = a:1
	else
		let file_tab_win = input(prompt, '', complete)
	endif
	let record = split(file_tab_win, s:field_separ)
	let tabnum = record[1]
	let winum = record[2]
	execute 'tabnext' tabnum
	execute winum 'wincmd w'
endfun

fun! wheel#rectangle#ratio ()
	" Window width / height
	" Real usable window width
	" Credit : https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
	let width=winwidth(0) - ((&number||&relativenumber) ? &numberwidth : 0) - &foldcolumn
	let height = winheight(0)
	" Use round as nr2float
	" Where is nr2float btw ?
	return round(width) / round(height)
endfun

fun! wheel#rectangle#delete_hidden_buffers (...)
	" Delete hidden buffers, except unlisted and alternate one
	if a:0 > 0
		let delete = a:1
	else
		let delete = 'delete'
	endif
	if delete == 'delete'
		let command = 'bdelete'
	elseif delete == 'wipe'
		let command = 'bwipe'
	endif
	let buffers = execute('buffers')
	let buffers = split(buffers, "\n")
	let length = len(buffers)
	let hidden_buffers = []
	for index in range(length)
		let elem = buffers[index]
		let fields = split(elem)
		let bufnum = str2nr(fields[0])
		let indicator = fields[1]
		let filename = expand(join(fields[2:-3]))[1:-2]
		if indicator =~ '^h' && indicator !~ '^h.*[RF?+x]'
			call add(hidden_buffers, [bufnum, indicator, filename])
			exe 'silent' command bufnum
		endif
	endfor
	echomsg 'hidden buffers deleted.'
	return hidden_buffers
endfun
