" vim: ft=vim fdm=indent:

" Tabs & Windows

" Buffers & Windows

fun! wheel#mosaic#glasses (filename, ...)
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

fun! wheel#mosaic#tour ()
	" Return closest candidate amongst windows displaying current location
	" by exploring each one
	" Prefer windows in current tab page
	" return v:false if no window display filename
	let original = win_getid()
	let location = wheel#referen#location()
	let filename = location.file
	let line = location.line
	let glasses = wheel#mosaic#glasses (filename, 'tab')
	if empty(glasses)
		let glasses = wheel#mosaic#glasses (filename, 'all')
	endif
	if empty(glasses)
		return v:false
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

fun! wheel#mosaic#tab_buffers ()
	" List of buffers in current tab, starting with current one
	let bufnum = bufnr('%')
	let buffers = tabpagebuflist()
	let index = index(buffers, bufnum)
	let buffers = wheel#chain#roll_left(index, buffers)
	return buffers
endfun

" Rotate window buffers, like in bspwm

fun! wheel#mosaic#rotate_clockwise ()
	" Rotate buffers of current tab page clockwise
	" Useful for main left & main top layouts
	wincmd t
	let buffers = wheel#mosaic#tab_buffers ()
	let buffers = wheel#chain#rotate_right (buffers)
	for bufnum in buffers
		exe 'buffer ' . bufnum
		wincmd w
	endfor
endfun

fun! wheel#mosaic#rotate_counter_clockwise ()
	" Rotate buffers of current tab page counter-clockwise
	" Useful for main left & main top layouts
	wincmd t
	let buffers = wheel#mosaic#tab_buffers ()
	let buffers = wheel#chain#rotate_left (buffers)
	for bufnum in buffers
		exe 'buffer ' . bufnum
		wincmd w
	endfor
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
			return v:false
		endif
	endif
	let g:wheel_shelve.layout.tab = 'none'
	let g:wheel_shelve.layout.tabnames = []
	call wheel#projection#follow ()
	return v:true
endfun

fun! wheel#mosaic#one_window ()
	" One window
	if winnr('$') > 1
		let prompt = 'Remove all windows except current one ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			only
		else
			return v:false
		endif
	endif
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
	let w:coordin = [0, 0]
	call wheel#projection#follow ()
	return v:true
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
	if ! wheel#mosaic#one_tab ()
		return
	endif
	let level = a:level
	let maxtabs = g:wheel_config.maxim.tabs
	let upper = wheel#referen#upper (level)
	let upper_level = wheel#referen#upper_level_name (level)
	let name = wheel#referen#current (level).name
	let glossary = copy(upper.glossary)
	let pos = index(glossary, name)
	let glossary = wheel#chain#roll_left (pos, glossary)
	let g:wheel_shelve.layout.tabnames = glossary[:maxtabs - 1]
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	call wheel#vortex#jump ('new')
	for index in range(min([maxtabs - 1, length - 1]))
		tabnew
		call wheel#vortex#next (level, 'new')
	endfor
	tabrewind
	call wheel#projection#follow (upper_level)
	let g:wheel_shelve.layout.tab = level
endfun

fun! wheel#mosaic#split (level, ...)
	" One level element per split
	" Optional arguments :
	" 1. action to obtain split layout
	" 2. settings to pass as argument -> action(settings)
	if a:0 > 0
		let action = a:1
	else
		let action = 'horizontal'
	endif
	if a:0 > 1
		let settings = a:2
	else
		let settings = {'golden' : v:false}
	endif
	if ! wheel#mosaic#one_window ()
		return
	endif
	let level = a:level
	let upper = wheel#referen#upper (level)
	let upper_level = wheel#referen#upper_level_name (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	call wheel#vortex#jump ('new')
	for index in range(length - 1)
		let alright = wheel#mosaic#{action} (settings)
		if ! alright
			break
		endif
		call wheel#vortex#next (level, 'new')
	endfor
	wincmd t
	call wheel#projection#follow (upper_level)
	let g:wheel_shelve.layout.window = level
	let g:wheel_shelve.layout.split = action
endfun

fun! wheel#mosaic#golden (level, ...)
	" Grid layout
	" Optional argument : action to obtain split layout
	if a:0 > 0
		let action = a:1
	else
		let action = 'main_left'
	endif
	let settings = {}
	let settings.golden = v:true
	call wheel#mosaic#split(a:level, action, settings)
endfun

fun! wheel#mosaic#split_grid (level)
	" Grid layout
	let settings = {}
	let settings.maxim = wheel#mosaic#rowcol (a:level)
	call wheel#mosaic#split(a:level, 'grid', settings)
endfun

fun! wheel#mosaic#split_transposed_grid (level)
	" Transposed grid layout
	let settings = {}
	let settings.maxim = wheel#mosaic#rowcol (a:level)
	call wheel#mosaic#split(a:level, 'transposed_grid', settings)
endfun

" Split flavors

fun! wheel#mosaic#horizontal (...)
	" Horizontal split
	" Optional argument : settings containing golden value
	" golden : whether split is equal or golden ratio
	" w:coordin = [row number, col number]
	if a:0 > 0
		let settings = a:1
	else
		let settings = {'golden': v:false}
	endif
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	let next = w:coordin[0] + 1
	if next < g:wheel_config.maxim.horizontal
		if settings.golden
			call wheel#spiral#horizontal ()
		else
			split
		endif
		let w:coordin = [next, 0]
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#mosaic#vertical (...)
	" Vertical split
	" Optional argument : settings containing golden value
	" golden : whether split is equal or golden ratio
	" w:coordin = [row number, col number]
	if a:0 > 0
		let settings = a:1
	else
		let settings = {'golden': v:false}
	endif
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	let next = w:coordin[1] + 1
	if next < g:wheel_config.maxim.vertical
		if settings.golden
			call wheel#spiral#vertical ()
		else
			vsplit
		endif
		let w:coordin = [0, next]
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#mosaic#main_left (...)
	" Main window on left
	" Optional argument : settings containing golden value
	" golden : whether split is equal or golden ratio
	" w:coordin = [row number, col number]
	if a:0 > 0
		let settings = a:1
	else
		let settings = {'golden': v:false}
	endif
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	if w:coordin == [0, 0]
		if settings.golden
			call wheel#spiral#vertical ()
		else
			vsplit
		endif
		let w:coordin = [0, 1]
		return v:true
	endif
	let next = w:coordin[0] + 1
	if next < g:wheel_config.maxim.horizontal
		if settings.golden
			call wheel#spiral#horizontal ()
		else
			split
		endif
		let w:coordin = [next, 1]
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#mosaic#main_top (...)
	" Main window on top
	" Optional argument : settings containing golden value
	" golden : whether split is equal or golden ratio
	" w:coordin = [row number, col number]
	if a:0 > 0
		let settings = a:1
	else
		let settings = {'golden': v:false}
	endif
	if ! exists('w:coordin')
		let w:coordin = [0, 0]
	endif
	if w:coordin == [0, 0]
		if settings.golden
			call wheel#spiral#horizontal ()
		else
			split
		endif
		let w:coordin = [1, 0]
		return v:true
	endif
	let next = w:coordin[1] + 1
	if next < g:wheel_config.maxim.vertical
		if settings.golden
			call wheel#spiral#vertical ()
		else
			vsplit
		endif
		let w:coordin = [1, next]
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#mosaic#grid (settings)
	" Grid as row_1, row_2, ...
	" settings.done = [last_done_row, last_done_col]
	" settings.maxim = [max_row, max_col]
	let settings = a:settings
	if ! has_key(settings, 'done')
		let settings.done = [0, 0]
	endif
	let row = settings.done[0]
	let col = settings.done[1]
	let max_row = settings.maxim[0]
	let max_col = settings.maxim[1]
	wincmd t
	if row == 0
		if col > 0
			exe col . 'wincmd l'
		endif
		if col < max_col - 1
			vsplit
			let settings.done = [row, col + 1]
			return v:true
		else
			exe col . 'wincmd h'
			split
			let settings.done = [1, 0]
			return v:true
		endif
	else
		if col < max_col - 1
			exe (col + 1) . 'wincmd l'
			if row > 1
				exe (row - 1) . 'wincmd j'
			endif
			split
			let settings.done = [row, col + 1]
			return v:true
		elseif row < max_row - 1
			exe row . 'wincmd j'
			split
			let settings.done = [row + 1, 0]
			return v:true
		else
			return v:false
		endif
	endif
endfun

fun! wheel#mosaic#transposed_grid (settings)
	" Grid as col_1, col_2, ...
	" settings.done = [last_done_row, last_done_col]
	" settings.maxim = [max_row, max_col]
	let settings = a:settings
	if ! has_key(settings, 'done')
		let settings.done = [0, 0]
	endif
	let row = settings.done[0]
	let col = settings.done[1]
	let max_row = settings.maxim[0]
	let max_col = settings.maxim[1]
	wincmd t
	if col == 0
		if row > 0
			exe row . 'wincmd j'
		endif
		if row < max_row - 1
			split
			let settings.done = [row + 1, col]
			return v:true
		else
			exe row . 'wincmd k'
			vsplit
			let settings.done = [0, 1]
			return v:true
		endif
	else
		if row < max_row - 1
			exe (row + 1) . 'wincmd j'
			if col > 1
				exe (col - 1) . 'wincmd l'
			endif
			vsplit
			let settings.done = [row + 1, col]
			return v:true
		elseif col < max_col - 1
			exe col . 'wincmd l'
			vsplit
			let settings.done = [0, col + 1]
			return v:true
		else
			return v:false
		endif
	endif
endfun
