" vim: set ft=vim fdm=indent iskeyword&:

" Commands to reproduce tabs & windows layouts

fun! wheel#labyrinth#windows (layout, direction = 'undefined')
	" Commands to reproduce layout of a tab
	let layout = a:layout
	let direction = a:direction
	" ---- split command
	if direction ==# 'row'
		let command = 'noautocmd silent vsplit'
	elseif direction ==# 'col'
		let command = 'noautocmd silent split'
	endif
	" ---- first element = leaf, row, col
	let first = layout[0]
	let second = layout[1]
	let kind = type(first)
	if kind == v:t_string
		if first ==# 'leaf'
			let bufname = second->winbufnr()->bufname()
			let linum = line('.', second)
			let colnum = col('.', second)
			if empty(bufname)
				return []
			endif
			if bufname =~ '^term://'
				let shell = bufname->matchstr(':\zs[^:]*$')
				let folder = bufname->matchstr('term://\zs.*/\ze/[0-9]*:' .. shell)
				let terminal = ['lcd ' .. folder]
				eval terminal->add('terminal ' .. shell)
				return terminal
			endif
			let filename = bufname->fnamemodify(':p')
			let edit = [ 'silent edit ' .. filename ]
			" -- go to last position in file
			let last_position = 'call cursor(' .. linum .. ', ' .. colnum .. ')'
			eval edit->add(last_position)
			" -- unfold to view cursor
			eval edit->add('normal! zv')
			" -- center view
			eval edit->add('normal! zz')
			return edit
		else
			return wheel#labyrinth#windows (second, first)
		endif
	endif
	" ---- layout = nested list
	let returnlist = []
	let length = len(layout)
	let splitnum = length - 1
	" -- add splits
	for index in range(splitnum)
		eval returnlist->add(command)
	endfor
	" -- rewind to pre operation window
	if direction ==# 'row'
		let rewind = 'noautocmd ' .. splitnum .. ' wincmd h'
	elseif direction ==# 'col'
		let rewind = 'noautocmd ' .. splitnum .. ' wincmd k'
	endif
	eval returnlist->add(rewind)
	" -- treat sublists
	if direction ==# 'row'
		let next_window = 'noautocmd wincmd l'
	elseif direction ==# 'col'
		let next_window = 'noautocmd wincmd j'
	endif
	for index in range(length)
		let dive = layout[index]
		let sublist = wheel#labyrinth#windows (dive, command)
		eval returnlist->extend(sublist)
		if index < splitnum
			eval returnlist->add(next_window)
		endif
	endfor
	" ---- coda
	return returnlist
endfun

fun! wheel#labyrinth#session ()
	" Commands to reproduce layout of all tabs
	let current_tab = tabpagenr()
	let last_tab = tabpagenr('$')
	let returnlist = []
	" ---- loop on tabs
	for tabnum in range(1, last_tab)
		let winlayout = winlayout(tabnum)
		let tab_layout = wheel#labyrinth#windows(winlayout)
		eval returnlist->extend(tab_layout)
		eval returnlist->add('noautocmd silent wincmd t')
		if tabnum < last_tab
			eval returnlist->add('noautocmd silent tabnew')
		endif
	endfor
	" ---- set all windows equal
	eval returnlist->add('noautocmd silent tabdo wincmd =')
	" ---- return to tab 1
	"eval returnlist->add('noautocmd silent tabrewind')
	" ---- return to current tab
	eval returnlist->add(current_tab .. 'tabnext')
	" ---- filetype
	eval returnlist->add('filetype on')
	" ---- autocommands
	eval returnlist->add('doautoall BufRead')
	eval returnlist->add('doautoall BufReadPost')
	eval returnlist->add('doautoall FileType')
	" ---- coda
	return returnlist
endfun
