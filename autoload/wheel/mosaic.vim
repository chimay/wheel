" vim: ft=vim fdm=indent:

" Tabs & Windows

" Buffers & Windows

fun! wheel#mosaic#glasses (filename)
	" Return list of window(s) id(s) displaying filename
	return win_findbuf(bufnr(a:filename))
endfun

fun! wheel#mosaic#tour ()
	" Return closest candidate amongst windows displaying current location
	" by exploring each one
	" Return 0 if no window display filename
	let original = win_getid()
	let location = wheel#referen#location()
	let filename = location.file
	let line = location.line
	let glasses = wheel#mosaic#glasses (filename)
	if empty(glasses)
		return 0
	else
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
	endif
endfun

fun! wheel#mosaic#ratio ()
	" Window width / height
	" Real usable window width
	" Credit : https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
	let width=winwidth(0) - ((&number||&relativenumber) ? &numberwidth : 0) - &foldcolumn
	let height = winheight(0)
	" Use round as nr2float
	" Where is nr2float btw ?
	return round(width) / round(height)
endfun

" Helpers

fun! wheel#mosaic#one_tab ()
	" One tab
	if tabpagenr('$') > 1
		let prompt = 'Remove all tabs except current one ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			tabonly
		else
			return 0
		endif
	endif
	let g:wheel_shelve.layout.tab = 'none'
	call wheel#projection#follow ()
	return 1
endfun

fun! wheel#mosaic#one_window ()
	" One window
	if winnr('$') > 1
		let prompt = 'Remove all windows except current one ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			only
		else
			return 0
		endif
	endif
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
	let w:coordin = [0, 0]
	call wheel#projection#follow ()
	return 1
endfun

fun! wheel#mosaic#rowcol (level)
	" Number of rows and cols for grid layout
	let ratio = wheel#mosaic#ratio ()
	let rows = g:wheel_config.maxim.horizontal
	let cols = g:wheel_config.maxim.vertical
	let upper = wheel#referen#upper (a:level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	while v:true
		let course = round(cols) / round(rows)
		if course > ratio && (cols - 1) * rows >= length
			let cols -= 1
		elseif course < ratio && cols * (rows - 1) >= length
			let rows -= 1
		elseif (cols - 1) * rows >= length
			let cols -= 1
		elseif cols * (rows - 1) >= length
			let rows -= 1
		else
			break
		endif
	endwhile
	return [rows, cols]
endfun

" Layouts

fun! wheel#mosaic#zoom (...)
	" One tab, one window
	let tab = wheel#mosaic#one_tab ()
	let window = wheel#mosaic#one_window ()
	return tab && window
endfun

fun! wheel#mosaic#tabs (level)
	" One level element per tab
	let level = a:level
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	if ! wheel#mosaic#one_tab ()
		return
	endif
	call wheel#vortex#jump ()
	let maxtabs = g:wheel_config.maxim.tabs
	for index in range(min([maxtabs, length - 1]))
		tabnew
		call wheel#vortex#next (level)
	endfor
	tabrewind
	call wheel#projection#follow ()
	let g:wheel_shelve.layout.tab = level
endfun

fun! wheel#mosaic#split (level, ...)
	" One level element per horizontal split
	if a:0 > 0
		let action = a:1
	else
		let action = 'horizontal'
	endif
	if a:0 > 1
		let dict = a:2
	else
		let dict = {}
	endif
	let level = a:level
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	if ! wheel#mosaic#one_window ()
		return
	endif
	call wheel#vortex#jump ()
	for index in range(length - 1)
		let alright = wheel#mosaic#{action} (dict)
		if ! alright
			break
		endif
		call wheel#vortex#next (level)
	endfor
	wincmd t
	call wheel#projection#follow ()
	let g:wheel_shelve.layout.window = level
	let g:wheel_shelve.layout.split = action
endfun

fun! wheel#mosaic#split_grid (level)
	" Grid layout
	let dict = {}
	let dict.maxim = wheel#mosaic#rowcol (a:level)
	call wheel#mosaic#split(a:level, 'grid', dict)
endfun

fun! wheel#mosaic#split_transposed_grid (level)
	" Transposed grid layout
	call wheel#mosaic#split(a:level, 'transposed_grid', dict)
endfun

" Split flavors

fun! wheel#mosaic#horizontal (...)
	" Horizontal split
	" w:coordin = [row number, col number]
	" Optional argument if for compatibility only
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	let next = w:coordin[0] + 1
	if next < g:wheel_config.maxim.horizontal
		split
		let w:coordin = [next, 0]
		return 1
	else
		return 0
	endif
endfun

fun! wheel#mosaic#vertical (...)
	" Vertical split
	" w:coordin = [row number, col number]
	" Optional argument if for compatibility only
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	let next = w:coordin[1] + 1
	if next < g:wheel_config.maxim.vertical
		vsplit
		let w:coordin = [0, next]
		return 1
	else
		return 0
	endif
endfun

fun! wheel#mosaic#main_left (...)
	" Main window on top
	" w:coordin = [row number, col number]
	" Optional argument if for compatibility only
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	if w:coordin == [0, 0]
		vsplit
		let w:coordin = [0, 1]
		return 1
	endif
	let next = w:coordin[0] + 1
	if next < g:wheel_config.maxim.horizontal
		split
		let w:coordin = [next, 1]
		return 1
	else
		return 0
	endif
endfun

fun! wheel#mosaic#main_top (...)
	" Main window on top
	" w:coordin = [row number, col number]
	" Optional argument if for compatibility only
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	if w:coordin == [0, 0]
		split
		let w:coordin = [1, 0]
		return 1
	endif
	let next = w:coordin[1] + 1
	if next < g:wheel_config.maxim.vertical
		vsplit
		let w:coordin = [1, next]
		return 1
	else
		return 0
	endif
endfun

fun! wheel#mosaic#grid (dict)
	" Grid as row_1, row_2, ...
	" dict.done = [last_done_row, last_done_col]
	" dict.maxim = [max_row, max_col]
	let dict = a:dict
	if ! has_key(dict, 'done')
		let dict.done = [0, 0]
	endif
	echomsg string(dict)
	let row = dict.done[0]
	let col = dict.done[1]
	let max_row = dict.maxim[0]
	let max_col = dict.maxim[1]
	wincmd t
	if row == 0
		if col > 0
			exe col . 'wincmd l'
		endif
		if col < max_col - 1
			vsplit
			let dict.done = [row, col + 1]
			return 1
		else
			exe col . 'wincmd h'
			split
			let dict.done = [1, 0]
			return 1
		endif
	else
		if col < max_col - 1
			exe (col + 1) . 'wincmd l'
			if row > 1
				exe (row - 1) . 'wincmd j'
			endif
			split
			let dict.done = [row, col + 1]
			return 1
		elseif row < max_row - 1
			exe row . 'wincmd j'
			split
			let dict.done = [row + 1, 0]
			return 1
		else
			return 0
		endif
	endif
endfun

fun! wheel#mosaic#transposed_grid (dict)
	" Grid as col_1, col_2, ...
endfun
