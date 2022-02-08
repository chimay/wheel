" vim: set ft=vim fdm=indent iskeyword&:

" Rectangle
"
" Tabs, Windows & buffers

" ---- script constants

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

" ---- helpers

fun! wheel#rectangle#goto_previous ()
	" Go to previous window in tab
	noautocmd wincmd p
endfun

fun! wheel#rectangle#ratio ()
	" Window width / height
	" Real usable window width
	" Credit : https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
	let width = winwidth(0)
	let width -= ( (&number || &relativenumber) ? &numberwidth : 0 ) + &foldcolumn
	let height = winheight(0)
	" use round as nr2float
	return round(width) / round(height)
endfun

" ---- tab, win, buffer number

fun! wheel#rectangle#current ()
	" Return dict with tab, window and buffer numbers of current window
	let rectangle = {}
	let rectangle.tabnum = tabpagenr()
	let rectangle.winum = winnr()
	let rectangle.winiden = win_getid()
	let rectangle.bufnum = bufnr('%')
	return rectangle
endfun

fun! wheel#rectangle#previous ()
	" Return tab, window & buffer number of previous window
	call wheel#rectangle#goto_previous ()
	let previous = wheel#rectangle#current ()
	call wheel#rectangle#goto_previous ()
	return previous
endfun

fun! wheel#rectangle#goto (where)
	" Go to window given by where
	let where = a:where
	let tabnum = where.tabnum
	let winum = where.winum
	let bufnum = where.bufnum
	if tabnum != tabpagenr()
		execute 'noautocmd tabnext' tabnum
	endif
	if winum != winnr()
		execute 'noautocmd' winum 'wincmd w'
	endif
	if bufnum != bufnr()
		execute 'hide buffer' bufnum
	endif
	return v:true
endfun

" ---- window containing a given buffer

fun! wheel#rectangle#find_buffer (bufnum, scope = 'all')
	" Go to window of buffer given by bufnum
	" The window is the first one displaying bufnum buffer
	" Optional argument :
	"   - all : search in all tabs & windows
	"   - tab : search only in current tab
	let bufnum = a:bufnum
	let scope = a:scope
	" -- search in current tab
	if scope == 'tab'
		let winum = bufwinnr(bufnum)
		if winum < 0
			return v:false
		endif
		execute 'noautocmd' winum  'wincmd w'
		return v:true
	endif
	" -- search everywhere
	let winds = win_findbuf(bufnum)
	if empty(winds)
		return v:false
	endif
	let winiden = winds[0]
	noautocmd call win_gotoid(winiden)
	return v:true
endfun

fun! wheel#rectangle#find_or_load (bufnum)
	" Go to window of buffer if visible, or load it in first window of tab
	let bufnum = a:bufnum
	if ! wheel#rectangle#find_buffer (bufnum)
		noautocmd 1 wincmd w
		execute 'hide buffer' bufnum
	endif
	return v:true
endfun

" ---- window(s) containing a given file

fun! wheel#rectangle#rosace (filename, scope = 'all')
	" Return list of window(s) id(s) displaying filename
	" Optional argument :
	"   - all : search in all tabs & windows
	"   - tab : search only in current tab
	let filename = a:filename
	let scope = a:scope
	let wins = win_findbuf(bufnr(filename))
	if scope == 'tab'
		let tabnum = tabpagenr()
		eval wins->filter({ _, val -> win_id2tabwin(val)[0] == tabnum })
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
	let rosace = wheel#rectangle#rosace (filename, 'tab')
	for window in rosace
		noautocmd call win_gotoid(window)
		let closest = wheel#projection#closest ()
		if ! empty(closest) && closest == coordin
			noautocmd call win_gotoid(original)
			return window
		endif
	endfor
	" -- anywhere
	let rosace = wheel#rectangle#rosace (filename, 'all')
	for window in rosace
		noautocmd call win_gotoid(window)
		let closest = wheel#projection#closest ()
		if ! empty(closest) && closest == coordin
			noautocmd call win_gotoid(original)
			return window
		endif
	endfor
	" ---- not found
	noautocmd call win_gotoid(original)
	return -1
endfun

" ---- lists of buffers

fun! wheel#rectangle#hidden_buffers (scope = 'listed')
	" Return list of hidden or unlisted buffers, with some exceptions
	" Optional argument :
	"   - listed (default) : don't return unlisted buffers
	"   - all : also return unlisted buffers
	" Exceptions :
	"   - alternate buffer
	"   - wheel dedicated buffers (mandalas)
	let scope = a:scope
	if scope == 'listed'
		let buflist = getbufinfo({'buflisted' : 1})
	elseif scope == 'all'
		let buflist = getbufinfo()
	else
		echomsg 'wheel rectangle hidden buffers : bad optional argument'
		return []
	endif
	let alternate = bufname('#')
	let mandalas = g:wheel_bufring.mandalas
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
			eval hidden_nums->add(bufnum)
			eval hidden_names->add(filename)
		endif
	endfor
	return [hidden_nums, hidden_names]
endfun

fun! wheel#rectangle#tab_buffers ()
	" List of buffers in current tab, starting with current one
	let bufnum = bufnr('%')
	let buffers = tabpagebuflist()
	let index = buffers->index(bufnum)
	let buffers = buffers->wheel#chain#roll_left(index)
	return buffers
endfun
