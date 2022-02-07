" vim: set ft=vim fdm=indent iskeyword&:

" Status
"
" Echo status info

" Script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" ---- clear cmd line

fun! wheel#status#clear ()
	" Clear command line space
	" Does not clear the vim messages
	" credit :
	" https://neovim.discourse.group/t/how-to-clear-the-echo-message-in-the-command-line/268/2
	call feedkeys(':','nx')
endfun

fun! wheel#status#clear_messages ()
	" Clear vim messages
	messages clear
	echo 'messages cleared'
endfun

" ---- echo

fun! wheel#status#echo (...)
	" Echo message
	if a:0 == 0
		let message = ''
	endif
	if a:0 > 1
		let message = join(a:000)
		return call('wheel#status#echo', [ message ])
	endif
	let message = a:1
	if type(message) == v:t_list
		let message = join(message)
	endif
	call wheel#status#clear ()
	echo message
	return v:true
endfun

fun! wheel#status#message (...)
	" Echomsg message
	if a:0 == 0
		let message = ''
	endif
	if a:0 > 1
		let message = join(a:000)
		return call('wheel#status#message', [ message ])
	endif
	let message = a:1
	if type(message) == v:t_list
		let message = join(message)
	endif
	" does not clear messages, only echo area
	call wheel#status#clear ()
	echomsg message
	return v:true
endfun

" ---- wheel

fun! wheel#status#dashboard ()
	" Display dashboard, summary of current wheel status
	let [torus, circle, location] = wheel#referen#location('all')
	if ! wheel#referen#is_empty('wheel')
		let dashboard = torus.name .. s:level_separ
		if ! wheel#referen#is_empty('torus')
			let dashboard ..= circle.name .. s:level_separ
			if ! wheel#referen#is_empty('circle')
				let dashboard ..= location.name .. ' : '
				let dashboard ..= location.file .. ':' .. location.line .. ':' .. location.col
			else
				let dashboard ..= '[Empty circle]'
			endif
		else
			let dashboard ..= '[Empty torus]'
		endif
	else
		let dashboard = 'Empty wheel'
	endif
	call wheel#status#echo (dashboard)
	return v:true
endfun

" ---- mandala & leaf

fun! wheel#status#mandalas ()
	" Return bufring status
	let bufring = g:wheel_bufring
	let names = copy(bufring.names)
	let current = bufring.current
	let names[current] = '[' .. names[current] .. ']'
	return names
endfun

fun! wheel#status#leaves ()
	" Return leaves status
	if ! wheel#cylinder#is_mandala ()
		return []
	endif
	let nature = wheel#book#ring ('nature')
	let types = nature->map({ _, val -> val.type })
	let current = b:wheel_ring.current
	let types[current] =  '[' .. types[current] .. ']'
	return types
endfun

fun! wheel#status#statusline ()
	" Statusline for mandala
	if ! wheel#cylinder#is_mandala ()
		echomsg 'wheel statusline : should not be called outside of mandala'
		return &g:statusline
	endif
	let mandalas = wheel#status#mandalas ()
	let mandalas = join(mandalas)
	let leaves = wheel#status#leaves ()
	let leaves = join(leaves)
	let statusline = '%#WheelStatusLine# '
	let statusline ..= 'mandalas: '
	let statusline ..= mandalas
	let statusline ..= s:field_separ
	let statusline ..= 'leaves: '
	let statusline ..= leaves
	let statusline ..=' %='
	let statusline ..= '%F'
	let statusline ..= s:field_separ
	let statusline ..= 'buf %n'
	let statusline ..= s:field_separ
	let statusline ..= '%L lines %y%r%m'
	let statusline ..= '   %<'
	return statusline
endfun

fun! wheel#status#mandala_leaf ()
	" Mandala & leaf dashboard
	let in_status = g:wheel_config.display.statusline
	if in_status > 0 && wheel#cylinder#is_mandala ()
		call wheel#status#clear ()
		setlocal statusline=%!wheel#status#statusline()
		return v:true
	endif
	let oneline = g:wheel_config.display.message == 'one-line'
	let mandalas = wheel#status#mandalas()
	let leaves = wheel#status#leaves()
	call wheel#status#clear ()
	if empty(leaves)
		echo 'wheel buffers: ' join(mandalas) "\n"
		return v:true
	endif
	if oneline
		echo 'wheel buf:' join(mandalas) '/ lay:' join(leaves)
	else
		echo 'wheel buffers : ' join(mandalas) "\n"
		echo '      layers  : ' join(leaves)
	endif
	return v:true
endfun

" ---- tab line

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
		if getbufvar(bufnum, '&modified')
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
