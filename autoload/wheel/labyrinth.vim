" vim: set ft=vim fdm=indent iskeyword&:

" Ouput to reproduce tabs & windows layouts

fun! wheel#labyrinth#windows (layout, command = 'undefined')
	" Ouput to reproduce layout of a tab
	let layout = a:layout
	let command = a:command
	" ---- first element = leaf, row, col
	let first = layout[0]
	let second = layout[1]
	let kind = type(first)
	if kind == v:t_string
		if first == 'leaf'
			let bufname = second->winbufnr()->bufname()
			if empty(bufname)
				return []
			else
				let filename = bufname->fnamemodify(':p')
				return [ 'silent edit ' .. filename ]
			endif
		elseif first == 'row'
			let command = 'silent vsplit'
			return wheel#labyrinth#windows (second, command)
		elseif first == 'col'
			let command = 'silent split'
			return wheel#labyrinth#windows (second, command)
		endif
	endif
	" ---- layout = nested list
	let returnlist = []
	let length = len(layout)
	for index in range(length)
		let dive = layout[index]
		let sublist = wheel#labyrinth#windows (dive, command)
		eval returnlist->extend(sublist)
		if index < length - 1
			eval returnlist->add(command)
		endif
	endfor
	return returnlist
endfun

fun! wheel#labyrinth#layout ()
	" Ouput commands list to reproduce layout
	let last = tabpagenr('$')
	let returnlist = []
	eval returnlist->add('silent tabonly')
	eval returnlist->add('silent only')
	for tabnum in range(1, last)
		let winlayout = winlayout(tabnum)
		let tab_layout = wheel#labyrinth#windows(winlayout)
		eval returnlist->extend(tab_layout)
		if tabnum < last
			eval returnlist->add('noautocmd silent tabnew')
		endif
	endfor
	"eval returnlist->add('silent tabdo wincmd =')
	eval returnlist->add('silent tabnext 1')
	return returnlist
endfun
