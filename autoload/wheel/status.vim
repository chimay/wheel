" vim: set ft=vim fdm=indent iskeyword&:

" Script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" Clear cmd line

fun! wheel#status#clear ()
	" Clear command line space
	" Does not clear the vim messages, for that use :
	"   :messages clear
	" credit :
	" https://neovim.discourse.group/t/how-to-clear-the-echo-message-in-the-command-line/268/2
	call feedkeys(':','nx')
endfun

" Message

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

" Wheel status

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

" Mandala & leaf status

fun! wheel#status#mandala_leaf ()
	" Mandala & leaf dashboard
	let oneline = g:wheel_config.display.message == 'one-line'
	" ---- mandalas
	let mandalas = g:wheel_mandalas
	let bufnames = copy(mandalas.names)
	let cur_mandala = mandalas.current
	let bufnames[cur_mandala] = '[' .. bufnames[cur_mandala] .. ']'
	" ---- leaves
	if wheel#cylinder#is_mandala ()
		let cur_leaf = b:wheel_ring.current
		let nature = wheel#book#ring ('nature')
		let leaves = nature->map({ _, val -> val.type })
		let leaves[cur_leaf] =  '[' .. leaves[cur_leaf] .. ']'
	else
		let cur_leaf = -1
	endif
	" echo
	call wheel#status#clear ()
	if cur_leaf >= 0
		if oneline
			echo 'wheel buf:' join(bufnames) '/ lay:' join(leaves)
		else
			echo 'wheel buffers : ' join(bufnames) "\n"
			echo '      layers  : ' join(leaves)
		endif
	else
		echo 'wheel buffers: ' join(mandalas) "\n"
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
