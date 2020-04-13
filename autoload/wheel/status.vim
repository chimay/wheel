" vim: ft=vim fdm=indent:

fun! wheel#status#dashboard ()
	" Display dashboard, summary of current wheel status
	if has('nvim')
		let [cur_torus, cur_circle, cur_location] = wheel#referen#location('all')
		let string = cur_torus.name . ' > '
		let string .= cur_circle.name . ' > '
		let string .= cur_location.name . ' : '
		let string .= cur_location.file . ':' . cur_location.line . ':' . cur_location.col
		echomsg string
		redraw!
	endif
endfun

" Tab line

fu! wheel#status#tablabel (onglet)
	" Label of a tab
	" TODO
	let buflist = tabpagebuflist(a:onglet)
	let winnr = tabpagewinnr(a:onglet)
	let buffernr = buflist[winnr - 1]
	let buffername = bufname(buffernr)
	let filename = fnamemodify(buffername, ':t')
	let label = ''
	for bufnr in buflist
		if getbufvar(bufnr, "&modified")
			let label .= '+'
			break
		endif
	endfor
	"return a:onglet . ' ' . filename . ' ' . label
	"return filename . ' ' . label
	return filename
endfu

fun! wheel#status#tabline ()
	" Tab line
	let g:wheel_shelve.backup.tabline = &tabline
	" TODO
	let s = ''
	for i in range(tabpagenr('$'))
		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		" set the tab page number (for mouse clicks)
		let s .= '%' . (i + 1) . 'T'
		" the label is made by MyTabLabel()
		let s .= ' %{wheel#status#tablabel(' . (i + 1) . ')} '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'
	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
	let s .= '%=%#TabLine#%999X[X]'
	endif
	return s
endfun
