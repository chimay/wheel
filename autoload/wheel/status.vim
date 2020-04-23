" vim: ft=vim fdm=indent:

fun! wheel#status#dashboard ()
	" Display dashboard, summary of current wheel status
	if has('nvim')
		let [torus, circle, location] = wheel#referen#location('all')
		if ! wheel#referen#empty('wheel')
			let string = torus.name . ' > '
			if ! wheel#referen#empty('torus')
				let string .= circle.name . ' > '
				if ! wheel#referen#empty('circle')
					let string .= location.name . ' : '
					let string .= location.file . ':' . location.line . ':' . location.col
				else
					let string .= '[Empty circle]'
				endif
			else
				let string .= '[Empty torus]'
			endif
		else
			let string = 'Empty wheel'
		endif
		echomsg string
		redraw!
	endif
endfun

" Tab line

fu! wheel#status#tablabel (index)
	" Label of a tab
	let index = a:index
	" Modified indicator
	let buflist = tabpagebuflist(index)
	let modified = ''
	for bufnum in buflist
		if getbufvar(bufnum, "&modified")
			let modified = '[+]'
			break
		endif
	endfor
	" Label
	let winnr = tabpagewinnr(index)
	let buffernr = buflist[winnr - 1]
	let buffername = bufname(buffernr)
	let label = fnamemodify(buffername, ':t')
	let label .= ' ' . modified
	if ! has_key(g:wheel_shelve.layout, 'tabnames')
		return label
	endif
	let tabnames = g:wheel_shelve.layout.tabnames
	if empty(tabnames)
		return label
	endif
	let label = tabnames[index - 1] . ' ' . modified
	return label
endfu

fun! wheel#status#tabline ()
	" Tab line
	let text = ''
	for index in range(1, tabpagenr('$'))
		" Highlighting
		if index == tabpagenr()
			let text .= '%#TabLineSel#'
		else
			let text .= '%#TabLine#'
		endif
		" Tab page number (for mouse clicks)
		let text .= '%' . index . 'T'
		" Label of a tab
		let text .= ' %{wheel#status#tablabel(' . index . ')} '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let text .= '%#TabLineFill#%T'
	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let text .= '%=%#TabLine#%999X[X]'
	endif
	return text
endfun

fu! wheel#status#guitablabel ()
	" Gui label of a tab
	if has('nvim')
		" find a doc of nvim-qt for how to do it
	else
		return wheel#status#tablabel (v:lnum)
	endif
endfu

