" vim: set ft=vim fdm=indent iskeyword&:

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:is_mandala')
	let s:is_mandala = wheel#crystal#fetch('is_mandala')
	lockvar s:is_mandala
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
	" Search order :
	"   - windows in current tab page
	"   - windows anywhere
	" Return v:false if no window display filename
	let original = win_getid()
	let coordin = wheel#referen#names ()
	let filename = wheel#referen#location().file
	" ---- find window where closest = current wheel location
	" -- current tab
	let glasses = wheel#rectangle#glasses (filename, 'tab')
	for window in glasses
		noautocmd call win_gotoid(window)
		let closest = wheel#projection#closest ()
		if ! empty(closest) && closest == coordin
			noautocmd call win_gotoid(original)
			return window
		endif
	endfor
	" -- anywhere
	let glasses = wheel#rectangle#glasses (filename, 'all')
	for window in glasses
		noautocmd call win_gotoid(window)
		let closest = wheel#projection#closest ()
		if ! empty(closest) && closest == coordin
			noautocmd call win_gotoid(original)
			return window
		endif
	endfor
	" ---- back to original
	noautocmd call win_gotoid(original)
	return v:false
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
			execute winnr 'wincmd w'
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

fun! wheel#rectangle#hidden_buffers (...)
	" Return list of hidden or unlisted buffers, with some exceptions
	" Optional argument mode :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	" Exceptions :
	"   - alternate buffer
	"   - wheel dedicated buffers (mandalas)
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'listed'
	endif
	if mode == 'listed'
		let buflist = getbufinfo({'buflisted' : 1})
	elseif mode == 'all'
		let buflist = getbufinfo()
	else
		echomsg 'wheel rectangle hidden buffers : bad optional argument'
		return []
	endif
	let alternate = bufname('#')
	let hidden_nums = []
	let hidden_names = []
	for buffer in buflist
		let bufnum = buffer.bufnr
		let filename = buffer.name
		let hide = buffer.hidden || ! buffer.listed
		let hide = hide && filename !=# alternate
		let hide = hide && filename !~ s:is_mandala
		if hide
			call add(hidden_nums, bufnum)
			call add(hidden_names, filename)
		endif
	endfor
	return [hidden_nums, hidden_names]
endfun
