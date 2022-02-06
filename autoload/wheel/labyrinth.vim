" vim: set ft=vim fdm=indent iskeyword&:

" Ouput to reproduce tabs & windows layouts

fun! wheel#labyrinth#tab_windows (layout = [], command = 'edit')
	" Ouput to reproduce layout of a tab
	let layout = a:layout
	let command = a:command
	if empty(layout)
		let layout = winlayout()
	endif
	let first = layout[0]
	let kind = type(first)
	if kind == v:t_string
		if first == 'leaf'
			let bufname = layout[1]->winbufnr()->bufname()
			let filename = bufname->fnamemodify(':p')
			return [ command .. ' ' .. filename ]
		elseif first == 'row'
			let command = 'vsplit'
		elseif first == 'col'
			let command = 'split'
		endif
		return wheel#labyrinth#tab_windows (layout[1], command)
	endif
	" ---- layout = nested list
	let returnlist = []
	let length = len(layout)
	for index in range(1, length - 1)
		let dive = layout[index]
		let sublist = wheel#labyrinth#tab_windows (dive, command)
		eval returnlist->extend(sublist)
	endfor
	return returnlist
endfun
