" vim: set ft=vim fdm=indent iskeyword&:

" Helpers

fun! wheel#status#type (...)
	" Type of a mandala buffer in short form
	let type = call('wheel#mandala#type', a:000)
	return substitute(type, '\s.*', '', '')
endfun

" Wheel status

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
		" echo
		redraw!
		echo string
	endif
endfun

" Layer ring status

fun! wheel#status#layer ()
	" Layer dashboard
	" layers types
	let filenames = wheel#layer#stack ('filename')
	if empty(filenames)
		return '[' . wheel#status#type () . ']'
	endif
	let Fun = function('wheel#status#type')
	let types = map(copy(filenames), {_,v->Fun(v)})
	" current mandala type
	let title = '[' . wheel#status#type () . ']'
	let top = b:wheel_stack.top
	call insert(types, title, top)
	" reverse to have previous on the left and next on the right
	call reverse(types)
	" echo
	redraw!
	echo 'layers : ' . join(types)
endfun

" Mandala ring status

fun! wheel#status#cylinder ()
	" Layer dashboard
	" layers types
	let bufnums = g:wheel_mandalas.ring
	if empty(bufnums)
		return '[' . wheel#status#type () . ']'
	endif
	let current = g:wheel_mandalas.current
	let types = []
	for index in range(len(bufnums))
		let num = bufnums[index]
		let title = wheel#status#type (bufname(num))
		if index == current
			let title = '[' . title . ']'
		endif
		call add(types, title)
	endfor
	" echo
	redraw!
	echo 'mandalas : ' . join(types)
endfun

" Tab line

fun! wheel#status#tablabel (index)
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
	if empty(label)
		let label = '[no-name]'
	endif
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
endfun

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
	" After the last tab fill with TabLineFill and reset tab page nr
	let text .= '%#TabLineFill#%T'
	" Right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let text .= '%=%#TabLine#%999X[X]'
	endif
	return text
endfun

fun! wheel#status#guitablabel ()
	" Gui label of a tab
	if has('nvim')
		" find a doc of nvim-qt for how to do it
	else
		return wheel#status#tablabel (v:lnum)
	endif
endfun
