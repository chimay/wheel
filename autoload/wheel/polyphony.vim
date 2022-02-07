" vim: set ft=vim fdm=indent iskeyword&:

" Polyphony
"
" Multi-line operations on buffer(s)
"
" Narrow, filter, edit and apply

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:field_separ_bar')
	let s:field_separ_bar = wheel#crystal#fetch('separator/field/bar')
	lockvar s:field_separ_bar
endif

" ---- helpers

fun! wheel#polyphony#append_in_var_lines (line, content)
	" Append content after line in local mandala variables
	let line = a:line
	let content = a:content
	" ---- all lines
	let line_index = wheel#teapot#line_index (line)
	eval b:wheel_lines->insert(content, line_index + 1)
	" ---- filtered lines
	if ! wheel#teapot#is_filtered ()
		return v:true
	endif
	let start = wheel#teapot#first_data_line ()
	let next = line - start + 1
	let filter_indexes = b:wheel_filter.indexes
	let filter_lines = b:wheel_filter.lines
	let length = len(filter_indexes)
	eval filter_indexes->insert(line_index + 1, next)
	eval filter_lines->insert(content, next)
	for index in range(next + 1, length)
		let filter_indexes[index] += 1
	endfor
	return v:true
endfun

" ---- operator

fun! wheel#polyphony#operator (argument = '')
	" Operator waiting for a movement or text object to select range
	" Use in a map like this :
	"   map <expr> <mykey> wheel#polyphony#operator()
	let argument = a:argument
	" -- when called to find the rhs of the map
	if argument == ''
		set operatorfunc=wheel#polyphony#operator
		return 'g@'
	endif
	" -- when called to execute wheel#polyphony#operator
	" -- then, argument is 'line', 'block' or 'char'
	let first = line("'[")
	let last = line("']")
	call wheel#mirror#narrow_file (first, last)
endfun

" ---- actions

fun! wheel#polyphony#substitute (mandala = 'file')
	" Substitute in narrow mandala
	" Optional argument :
	"   - file : for narrow file mandala
	"   - circle : for narrow circle mandala
	let mandala = a:mandala
	call wheel#pencil#hide ()
	" -- user input
	let prompt = 'Substitute pattern ? '
	let before = input(prompt)
	let prompt = 'Replace full word matches only ?'
	let word = confirm(prompt, "&Yes\n&No", 1)
	if word == 1
		let before = '\<' .. before .. '\>'
	endif
	let prompt = 'Substitute with ? '
	let after = input(prompt)
	" -- patterns bricks
	let prelude = '\m\%('
	let field = '[^' .. s:field_separ_bar .. ']\+' .. s:field_separ
	let coda = '.*\)\@<='
	" -- check replacing pattern is not present if buffer
	" -- unless back references chars are included
	if after !~ '[&\\]'
		if mandala == 'file'
			let columns = prelude .. field .. coda
		elseif mandala == 'circle'
			let columns = prelude .. field .. field .. field .. coda
		else
			echomsg 'wheel polyphony substitute : mandala argument must be file or circle'
		endif
		let check = columns .. '\<' .. after .. '\>'
		let found = search(check, 'nw')
		if found > 0
			let prompt = 'Replacing pattern ' .. after .. ' found in buffer. Continue ?'
			let continue = confirm(prompt, "&Yes\n&No", 2)
			if continue == 2
				return v:false
			endif
		endif
	endif
	" -- skip non-content columns
	if mandala == 'file'
		let columns = prelude .. field .. coda
	elseif mandala == 'circle'
		let columns = prelude .. field .. field .. field .. coda
	endif
	let before = columns .. before
	" -- escape separator of substitution
	let before = escape(before, '/')
	let after = escape(after, '/')
	" -- run substitution
	let runme = 'silent % substitute/' .. before .. '/' .. after .. '/g'
	execute runme
	call wheel#pencil#show ()
	return v:true
endfun

fun! wheel#polyphony#append (where = 'below')
	" Append a line in narrow file mandala
	" Optional argument :
	"   - below (default) : place new line below current one
	"   - above : place new line above current one
	let where = a:where
	if ! where->wheel#chain#is_inside(['below', 'above'])
		echomsg 'wheel polyphony append : bad argument where' where
	endif
	call wheel#pencil#hide ()
	let linum = line('.')
	let fields = split(getline('.'), s:field_separ)
	let object = fields[0]
	if object =~ '^[+-]'
		let object = object[1:]
	endif
	let linum_field = str2nr(object)
	if where == 'above'
		let linum -= 1
	endif
	if where == 'below'
		let linum_field = printf('+%4d', linum_field)
	else
		let linum_field = printf('-%4d', linum_field)
	endif
	let columns = linum_field  .. s:field_separ
	call append(linum, columns)
	call wheel#polyphony#append_in_var_lines (linum, columns)
	let linum += 1
	call cursor(linum, 1)
	call wheel#pencil#show ()
	startinsert!
endfun

fun! wheel#polyphony#duplicate (where = 'below')
	" Duplicate a line in narrow file mandala
	"   - below (default) : duplicate new line below current one
	"   - above : duplicate new line above current one
	let where = a:where
	if ! where->wheel#chain#is_inside(['below', 'above'])
		echomsg 'wheel polyphony duplicate : bad where' where
	endif
	call wheel#pencil#hide ()
	let linum = line('.')
	let fields = split(getline('.'), s:field_separ)
	let object = fields[0]
	if object =~ '^[+-]'
		let object = object[1:]
	endif
	let linum_field = str2nr(object)
	let length = len(fields)
	if length > 1
		let content = fields[1]
	else
		let content = ''
	endif
	if where == 'above'
		let linum -= 1
	endif
	if where == 'below'
		let linum_field = printf('+%4d', linum_field)
	else
		let linum_field = printf('-%4d', linum_field)
	endif
	let columns = linum_field .. s:field_separ .. content
	call append(linum, columns)
	call wheel#polyphony#append_in_var_lines (linum, columns)
	let linum += 1
	call cursor(linum, 1)
	call wheel#pencil#show ()
endfun

" ---- propagate mandala changes -> original buffer(s)

fun! wheel#polyphony#harmony ()
	" Write function for shape#narrow_file
	" -- confirm
	let prompt = 'Propagate changes to file ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm == 2
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#cuboctahedron#update_var_lines ()
	" -- buffer
	let bufnum = b:wheel_related_buffer
	if bufnum == 'undefined'
		return v:false
	endif
	" -- modify file lines
	let linelist = wheel#teapot#all_lines ()
	let mandala_linum = 2
	let shift = 0
	for line in linelist
		let fields = split(line, s:field_separ)
		let length = len(fields)
		let object = fields[0]
		if length > 1
			let content = fields[1]
		else
			let content = ''
		endif
		if object =~ '^+'
			" line added below
			let linum = str2nr(object[1:])
			let shift += 1
			let newnum = linum + shift
			call appendbufline(bufnum, newnum - 1, content)
			let newnum = printf('%5d', newnum)
			let newline =  newnum .. s:field_separ .. content
			call setline(mandala_linum, newline)
		elseif object =~ '^-'
			" line added above
			let linum = str2nr(object[1:])
			let shift += 1
			let newnum = linum + shift - 1
			call appendbufline(bufnum, newnum - 1, content)
			let newnum = printf('%5d', newnum)
			let newline =  newnum .. s:field_separ .. content
			call setline(mandala_linum, newline)
		else
			" existing line
			let linum = str2nr(object)
			let newnum = linum + shift
			call setbufline(bufnum, newnum, content)
			let newnum = printf('%5d', newnum)
			let newline = newnum .. s:field_separ .. content
			call setline(mandala_linum, newline)
		endif
		let mandala_linum += 1
	endfor
	setlocal nomodified
	echomsg 'changes propagated'
	return v:true
endfun

fun! wheel#polyphony#counterpoint ()
	" Write function for shape#narrow_circle
	" -- confirm
	let prompt = 'Propagate changes to circle files ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm == 2
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#cuboctahedron#update_var_lines ()
	" -- modify file lines
	let linelist = wheel#teapot#all_lines ()
	for line in linelist
		let fields = split(line, s:field_separ)
		let length = len(fields)
		let bufnum = str2nr(fields[0])
		if ! bufloaded(bufnum)
			call bufload(bufnum)
		endif
		let linum = str2nr(fields[1])
		if length > 3
			let content = fields[3]
		else
			let content = ''
		endif
		call setbufline(bufnum, linum, content)
	endfor
	setlocal nomodified
	echomsg 'changes propagated to circle'
	return v:true
endfun

" ---- helpers for mandalas maps

fun! wheel#polyphony#crossroad (key, angle = 'no-angle', modes = ['n', 'n'])
	" Feed key, or run filter if on first line
	" Optional argument :
	"   - angle :
	"     - no-angle : plain key
	"     - with-angle, or '>' : special key -> "\<key>"
	"   - modes :
	"     - modes[0] : normal or insert mode at the end if on first line
	"     - modes[1] : normal or insert mode at the end if on any other line
	let key = a:key
	let angle = a:angle
	let modes = copy(a:modes)
	eval modes->map({ _, val -> wheel#gear#long_mode (val) })
	if line('.') == 1
		return wheel#teapot#wrapper (key, angle, modes[0])
	endif
	if angle == 'with-angle' || angle == '>'
		execute 'let key =' '"\<' .. key .. '>"'
	endif
	if modes[1] == 'insert'
		execute 'normal! i' .. key
		let colnum = col('.')
		if colnum != 1
			normal! l
		endif
		startinsert
	else
		execute 'normal!' key
	endif
	return v:true
endfun

fun! wheel#polyphony#last_field (key)
	" Go to last field of the line and start insert mode
	let key = a:key
	let linum = line('.')
	if key == '$'
		normal! $
		return v:true
	endif
	let last_field_pattern = '[^' .. s:field_separ_bar .. ']*$'
	if key == '^'
		call cursor(linum, 1)
		call search(last_field_pattern, 'c', linum)
		return v:true
	endif
	if linum != 1
		call search(last_field_pattern, 'c', linum)
	endif
	let insert = key->wheel#chain#is_inside(['i', 'a'])
	if insert
		if key == 'a'
			normal! l
		endif
		startinsert
	endif
	return v:true
endfun

fun! wheel#polyphony#ctrl_u ()
	" Ctrl-U on mandala with filter & write command
	let linum = line('.')
	if linum == 1
		call wheel#teapot#set_prompt ()
		call wheel#teapot#filter()
		return
	endif
	let last_field = '[^' .. s:field_separ_bar .. ']*$'
	let content = getline(linum)
	let content = substitute(content, last_field, '', '')
	call setline(linum, content)
endfun

fun! wheel#polyphony#normal_cc ()
	" Normal command cc in hybrid mandala
	startinsert!
	call wheel#polyphony#ctrl_u ()
endfun

" ---- mandalas

fun! wheel#polyphony#filter_maps ()
	" Local filter maps for hybrid filter/write mode
	" -- normal mode
	nnoremap <silent> <buffer> <ins> <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	nnoremap <silent> <buffer> <m-i> <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
endfun

fun! wheel#polyphony#input_history_maps ()
	" Local input history maps for hybrid filter/write mode
	" Use M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <M-p> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <cmd>call wheel#scroll#newer()<cr>
	" M-r / M-s : next / prev matching line
	inoremap <buffer> <M-r> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <cmd>call wheel#scroll#filtered_newer()<cr>
endfun

fun! wheel#polyphony#hybrid_maps ()
	" Local filter maps for hybrid filter/write mode
	" ---- normal maps
	let nmap = 'nnoremap <buffer>'
	let last_field = 'wheel#polyphony#last_field'
	exe nmap 'i  <cmd>call' last_field "('i')<cr>"
	exe nmap 'a  <cmd>call' last_field "('a')<cr>"
	exe nmap '^  <cmd>call' last_field "('^')<cr>"
	exe nmap '$  <cmd>call' last_field "('$')<cr>"
	exe nmap 'cc <cmd>call wheel#polyphony#normal_cc()<cr>'
	" ---- insert maps
	let imap = 'inoremap <buffer>'
	let across = 'wheel#polyphony#crossroad'
	exe imap '<space> <cmd>call'  across "('space', '>', ['i', 'i'])<cr>"
	exe imap '<c-w>   <cmd>call'  across "('c-w', '>', ['i', 'i'])<cr>"
	exe imap "<cr>    <cmd>call"  across "('cr', '>', ['n', 'i'])<cr>"
	exe imap '<esc>   <esc>:call' across "('esc', '>', ['n', 'n'])<cr>"
	exe imap '<c-u>   <cmd>call wheel#polyphony#ctrl_u()<cr>'
endfun

fun! wheel#polyphony#navigation_maps (settings)
	" Define whirl maps
	let settings = copy(a:settings)
	let nmap = 'nnoremap <buffer>'
	let loopnav = '<cmd>call wheel#loop#navigation('
	let coda = ')<cr>'
	" -- close after navigation
	let settings.close = v:true
	let settings.target = 'current'
	exe nmap '<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	exe nmap '<m-t>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	exe nmap '<m-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	exe nmap '<m-v>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	exe nmap '<m-s-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	exe nmap '<m-s-v>' loopnav .. string(settings) .. coda
	" -- leave open after navigation
	let settings.close = v:false
	let settings.target = 'current'
	exe nmap 'g<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	exe nmap 'g<m-t>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	exe nmap 'g<m-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	exe nmap 'g<m-v>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	exe nmap 'g<m-s-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	exe nmap 'g<m-s-v>' loopnav .. string(settings) .. coda
	" -- selection
	call wheel#pencil#mappings ()
	" -- preview
	call wheel#orbiter#mappings ()
	" -- context menu
	call wheel#boomerang#launch_map ('navigation')
	" -- property
	let b:wheel_nature.has_navigation = v:true
endfun

fun! wheel#polyphony#action_maps (mandala = 'file')
	" Define local action maps
	" Optional argument :
	"   - file : for narrow file mandala
	"   - circle : for narrow circle mandala
	let mandala = a:mandala
	exe "nnoremap <buffer> <m-s> <cmd>call wheel#polyphony#substitute('" .. mandala .. "')<cr>"
	if mandala == 'file'
		exe "nnoremap <buffer> o <cmd>call wheel#polyphony#append('below')<cr>"
		exe "nnoremap <buffer> O <cmd>call wheel#polyphony#append('above')<cr>"
		exe "nnoremap <buffer> <m-y> <cmd>call wheel#polyphony#duplicate('below')<cr>"
		exe "nnoremap <buffer> <m-z> <cmd>call wheel#polyphony#duplicate('above')<cr>"
	endif
endfun

fun! wheel#polyphony#temple ()
	" Filter hybrid & input history for writable mandalas
	call wheel#polyphony#filter_maps ()
	call wheel#polyphony#input_history_maps ()
	call wheel#polyphony#hybrid_maps ()
	setlocal nocursorline
endfun

fun! wheel#polyphony#template (settings)
	" Filter, hybrid, input history & navigation maps for writable mandalas
	call wheel#polyphony#temple ()
	call wheel#polyphony#navigation_maps (a:settings)
endfun
