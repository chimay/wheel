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
		if ! wheel#referen#is_empty('wheel')
			let string = torus.name .. ' > '
			if ! wheel#referen#is_empty('torus')
				let string ..= circle.name .. ' > '
				if ! wheel#referen#is_empty('circle')
					let string ..= location.name .. ' : '
					let string ..= location.file .. ':' .. location.line .. ':' .. location.col
				else
					let string ..= '[Empty circle]'
				endif
			else
				let string ..= '[Empty torus]'
			endif
		else
			let string = 'Empty wheel'
		endif
		echo "\r"
		echo string
	endif
endfun

" Mandala & leaf status

fun! wheel#status#mandala_leaf ()
	" Mandala & leaf dashboard
	let bufnums = g:wheel_mandalas.ring
	let oneline = g:wheel_config.message == 'one-line'
	" -- mandala ring status
	let current = g:wheel_mandalas.current
	let mandalas = []
	for index in range(len(bufnums))
		let num = bufnums[index]
		let title = wheel#status#type (bufname(num))
		if index == current
			let title = '[' .. title .. ']'
		endif
		call add(mandalas, title)
	endfor
	" -- leaf ring status
	if exists('b:wheel_ring')
		let filenames = wheel#book#ring ('filename')
		let current = b:wheel_ring.current
	else
		let filenames = []
		let current = -1
	endif
	let Fun = function('wheel#status#type')
	let leaves = map(copy(filenames), {_,v->Fun(v)})
	" current leaf type
	let title = '[' .. wheel#status#type () .. ']'
	echo "\r"
	if current >= 0
		let leaves[current] = title
		if oneline
			echo 'wheel buf: ' .. join(mandalas) ' / lay: ' .. join(leaves)
		else
			echo 'wheel buffers : ' .. join(mandalas) .. "\n"
			echo '      layers  : ' .. join(leaves)
		endif
	else
		echo 'wheel buffers: ' .. join(mandalas) .. "\n"
	endif
endfun

" Tab line

fun! wheel#status#tablabel (tabnum)
	" Label of a tab
	let tabnum = a:tabnum
	let buflist = tabpagebuflist(tabnum)
	let win_num = len(buflist)
	let winnr = tabpagewinnr(tabnum)
	let bufnr = buflist[winnr - 1]
	let filename = bufname(bufnr)
	let filename = fnamemodify(filename, ':t')
	let modified = ''
	for bufnum in buflist
		if getbufvar(bufnum, "&modified")
			let modified = '[+]'
			break
		endif
	endfor
	if empty(filename)
		let filename = '[no-name]'
	endif
	let label = tabnum .. ':' .. filename .. modified
	if win_num > 1
		let label ..= '(' .. win_num .. ')'
	endif
	if ! has_key(g:wheel_shelve.layout, 'tabnames')
		return label
	endif
	let tabnames = g:wheel_shelve.layout.tabnames
	if empty(tabnames)
		return label
	endif
	let label = tabnames[tabnum - 1] .. ' ' .. modified
	return label
endfun

fun! wheel#status#tabline ()
	" Tab line
	let text = ''
	for tabnum in range(1, tabpagenr('$'))
		" Highlighting
		if tabnum == tabpagenr()
			let text ..= '%#TabLineSel#'
		else
			let text ..= '%#TabLine#'
		endif
		" Tab page number (for mouse clicks)
		let text ..= '%' .. tabnum .. 'T'
		" Label of a tab
		let text ..= ' %{wheel#status#tablabel(' .. tabnum .. ')} '
	endfor
	" After the last tab fill with TabLineFill and reset tab page nr
	let text ..= '%#TabLineFill#%T'
	" Right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let text ..= '%=%#TabLine#%999X[X]'
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
