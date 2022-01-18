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

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

" Tabs, Windows & buffers

" helpers

fun! wheel#rectangle#previous ()
	" Go to previous window in tab
	wincmd p
endfun

fun! wheel#rectangle#glasses (filename, mode = 'all')
	" Return list of window(s) id(s) displaying filename
	" Optional argument : if tab, search only in current tab
	let filename = a:filename
	let mode = a:mode
	let wins = win_findbuf(bufnr(filename))
	if mode == 'tab'
		let tabnum = tabpagenr()
		call filter(wins, {_, val -> win_id2tabwin(val)[0] == tabnum})
	endif
	return wins
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

" main

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

fun! wheel#rectangle#goto (bufnum, mode = 'all')
	" Go to window of buffer given by bufnum
	" The window is the first one displaying bufnum buffer
	" Optional argument : if tab, search only in current tab
	let bufnum = a:bufnum
	let mode = a:mode
	" -- search in current tab
	if mode == 'tab'
		let winnr = bufwinnr(bufnum)
		if winnr > 0
			execute winnr 'wincmd w'
			return v:true
		else
			return v:false
		endif
	endif
	" -- search everywhere
	let winds = win_findbuf(bufnum)
	if ! empty(winds)
		let winiden = winds[0]
		call win_gotoid(winiden)
	else
		return v:false
	endif
	return v:true
endfun

fun! wheel#rectangle#goto_or_load (bufnum)
	" Go to window of buffer if visible, or load it in first window of tab
	let bufnum = a:bufnum
	if ! wheel#rectangle#goto (bufnum)
		1 wincmd w
		execute 'buffer' bufnum
	endif
	return v:true
endfun

fun! wheel#rectangle#hidden_buffers (mode = 'listed')
	" Return list of hidden or unlisted buffers, with some exceptions
	" Optional argument mode :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	" Exceptions :
	"   - alternate buffer
	"   - wheel dedicated buffers (mandalas)
	let mode = a:mode
	if mode == 'listed'
		let buflist = getbufinfo({'buflisted' : 1})
	elseif mode == 'all'
		let buflist = getbufinfo()
	else
		echomsg 'wheel rectangle hidden buffers : bad optional argument'
		return []
	endif
	let alternate = bufname('#')
	let mandalas = g:wheel_mandalas.ring
	let hidden_nums = []
	let hidden_names = []
	for buffer in buflist
		let bufnum = buffer.bufnr
		let filename = buffer.name
		let hide = buffer.hidden || ! buffer.listed
		let not_alternate = filename !=# alternate
		let not_mandala = ! wheel#chain#is_inside(bufnum, mandalas)
		let not_wheel_filename = filename !~ s:is_mandala_file
		if hide && not_alternate && not_mandala && not_wheel_filename
			call add(hidden_nums, bufnum)
			call add(hidden_names, filename)
		endif
	endfor
	return [hidden_nums, hidden_names]
endfun

fun! wheel#rectangle#tab_buffers ()
	" List of buffers in current tab, starting with current one
	let bufnum = bufnr('%')
	let buffers = tabpagebuflist()
	let index = index(buffers, bufnum)
	let buffers = wheel#chain#roll_left(index, buffers)
	return buffers
endfun
