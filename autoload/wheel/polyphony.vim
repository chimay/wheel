" vim: set ft=vim fdm=indent iskeyword&:

" Polyphony
"
" Write aspect of mandalas
"
" Narrow, filter, edit and apply

" ---- script constants

if ! exists('s:wheel_write_functions')
	let s:wheel_write_functions = wheel#crystal#fetch('function/write/wheel')
	lockvar s:wheel_write_functions
endif

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:field_separ_bar')
	let s:field_separ_bar = wheel#crystal#fetch('separator/field/bar')
	lockvar s:field_separ_bar
endif

" ---- booleans

fun! wheel#polyphony#is_writable ()
	" Whether mandala has BufWriteCmd autocommand
	return b:wheel_nature.is_writable
endfun

" ---- write autocommand & maps

fun! wheel#polyphony#choir (fun_name, arguments)
	" Return string to call fun_name with arguments
	" fun_name can be :
	"   - the full function name
	"   - the last part of :
	"     + wheel#harmony#fun_name
	"     + wheel#counterpoint#fun_name
	let fun_name = a:fun_name
	let arguments = string(a:arguments)
	if fun_name =~ '#'
		" -- fun_name is the complete function name
		let funcall = 'call call(' .. string(fun_name) .. ', ' .. arguments .. ')'
	else
		" -- fun_name is the last part of the function
		if fun_name->wheel#chain#is_inside(s:wheel_write_functions)
			let full_fun_name = 'wheel#harmony#' .. fun_name
		else
			let full_fun_name = 'wheel#counterpoint#' .. fun_name
		endif
		let funcall = 'call call(' .. string(full_fun_name)
		let funcall ..= ', ' .. arguments .. ')'
	endif
	return funcall
endfun

fun! wheel#polyphony#motion (fun_name, arguments)
	" Define autocommand to write the mandala
	let fun_name = a:fun_name
	let arguments = deepcopy(a:arguments)
	let group = s:mandala_autocmds_group
	let event = 'BufWriteCmd'
	call wheel#ouroboros#clear_autocmds(group, event)
	let funcall = wheel#polyphony#choir (fun_name, arguments)
	execute 'autocmd' group event '<buffer>' funcall
endfun

fun! wheel#polyphony#voicing (fun_name, arguments)
	" Define maps to trigger the writing function
	let fun_name = a:fun_name
	let arguments = deepcopy(a:arguments)
	let funcall = wheel#polyphony#choir (fun_name, arguments)
	let nmap = 'nnoremap <buffer>'
	execute nmap '<leader>w' '<cmd>' .. funcall .. '<cr>'
	eval arguments->add('force')
	let funcall = wheel#polyphony#choir (fun_name, arguments)
	execute nmap '<leader>W' '<cmd>' .. funcall .. '<cr>'
endfun

fun! wheel#polyphony#score (fun_name, ...)
	" Enable writable mandala : autocommand, maps, properties, options
	" Optional arguments : arguments to pass to fun_name
	" -- arguments
	let fun_name = a:fun_name
	let arguments = deepcopy(a:000)
	" ---- property
	let b:wheel_nature.is_writable = v:true
	" ---- options
	call wheel#mandala#unlock ()
	setlocal buftype=acwrite
	" ---- autocommand
	call wheel#polyphony#motion (fun_name, arguments)
	" --- maps to trigger the funcall
	call wheel#polyphony#voicing (fun_name, arguments)
endfun

" ---- confirmation prompt

fun! wheel#polyphony#confirm (ask)
	" Confirmation prompt before writing
	if a:ask ==# 'force'
		return v:true
	endif
	if exists('v:cmdbang') && v:cmdbang == 1
		return v:true
	endif
	let prompt = 'Reflect your changes to original elements ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm != 1
		return v:false
	endif
	return v:true
endfun

" ---- local mandala variables

fun! wheel#polyphony#update_var_lines ()
	" Update lines in local mandala variables, from visible lines
	" Affected :
	"   - b:wheel_lines
	"   - b:wheel_filter.lines
	if ! wheel#polyphony#is_writable ()
		" if mandala is not writable, lines are not supposed to be modified
		return v:false
	endif
	let start = wheel#teapot#first_data_line ()
	if wheel#teapot#is_filtered ()
		let lastline = line('$')
		for linum in range(start, lastline)
			let visible = getline(linum)
			let visible = wheel#pencil#unmarked (visible)
			let line_index = wheel#teapot#line_index (linum)
			let b:wheel_lines[line_index] = visible
			let local_index = linum - start
			let b:wheel_filter.lines[local_index] = visible
		endfor
	else
		let lines = getline(start, '$')
		let length = len(lines)
		for index in range(length)
			let visible = lines[index]
			let lines[index] = wheel#pencil#unmarked (visible)
		endfor
		let b:wheel_lines = lines
	endif
	return v:true
endfun

fun! wheel#polyphony#update_selection_indexes ()
	" Update selection indexes to b:wheel_lines / b:wheel_full
	if empty(b:wheel_full)
		let all_lines = b:wheel_lines
	else
		let all_lines = b:wheel_full
	endif
	let selection = b:wheel_selection
	let indexes = selection.indexes
	let components = selection.components
	let range = wheel#chain#rangelen(indexes)
	for iter in range
		let content = components[iter]
		let index = all_lines->index(content)
		if index >= 0
			let indexes[iter] = index
		else
			eval indexes->remove(iter)
			eval components->remove(iter)
		endif
	endfor
endfun

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
	eval filter_indexes->insert(line_index + 1, next)
	eval filter_lines->insert(content, next)
	let length = len(filter_indexes)
	for index in range(next + 1, length - 1)
		let filter_indexes[index] += 1
	endfor
	return v:true
endfun

fun! wheel#polyphony#delete_in_var_lines (line)
	" Delete line in local mandala variables
	let line = a:line
	" ---- delete in all lines
	let line_index = wheel#teapot#line_index (line)
	eval b:wheel_lines->remove(line_index)
	" ---- delete in filtered lines
	if ! wheel#teapot#is_filtered ()
		return v:true
	endif
	let start = wheel#teapot#first_data_line ()
	let index = line - start
	let filter_indexes = b:wheel_filter.indexes
	let filter_lines = b:wheel_filter.lines
	eval filter_indexes->remove(index)
	eval filter_lines->remove(index)
	let length = len(filter_indexes)
	for iter in range(index + 1, length - 1)
		let filter_indexes[iter] -= 1
	endfor
	return v:true
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
	let prompt = 'Substitute with ? '
	let after = input(prompt)
	" -- patterns bricks
	let prelude = '\m\%('
	let field = '[^' .. s:field_separ_bar .. ']\+' .. s:field_separ
	let coda = '.*\)\@<='
	" -- check replacing pattern is not present if buffer
	" -- unless back references chars are included
	if after !~ '[&\\]'
		if mandala ==# 'file'
			let columns = prelude .. field .. coda
		elseif mandala ==# 'circle'
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
	if mandala ==# 'file'
		let columns = prelude .. field .. coda
	elseif mandala ==# 'circle'
		let columns = prelude .. field .. field .. field .. coda
	endif
	" -- replace pattern is a full word ?
	if before !~ '\\<'
		let prompt = 'Replace full word matches only ?'
		let word = confirm(prompt, "&Yes\n&No", 1)
		if word == 1
			let before = '\<' .. before .. '\>'
		endif
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

fun! wheel#polyphony#context ()
	" Add lines of context around grep results
	let prompt = 'Number of context lines : '
	let context_lines = input(prompt)
	let context_lines = str2nr(context_lines)
	call wheel#polyphony#update_var_lines ()
	" ---- remove previous context
	let pattern = b:wheel_settings.pattern
	eval b:wheel_lines->filter({ _, val -> val =~ pattern })
	" ---- no context
	if context_lines <= 0
		call wheel#polyphony#update_selection_indexes ()
		call wheel#teapot#filter('dont-update')
		return b:wheel_lines
	endif
	" ---- add new context
	let contextualized = []
	let done = []
	for record in b:wheel_lines
		let fields = split(record, s:field_separ)
		let bufnum = str2nr(fields[0])
		let linum = str2nr(fields[1])
		let filename = fields[2]
		let content = fields[3]
		let low = max([linum - context_lines, 1])
		let high = linum + context_lines
		if ! bufloaded(bufnum)
			call bufload(bufnum)
		endif
		let linelist = getbufline(bufnum, low, high)
		if empty(linelist)
			" line < 1 or > last
			continue
		endif
		let new_line = low
		for new_content in linelist
			let new_fields = [
						\ printf('%3d', bufnum),
						\ printf('%5d', new_line),
						\ filename,
						\ new_content,
						\ ]
			let new_line += 1
			let new_record = join(new_fields, s:field_separ)
			let pair = [bufnum, new_line]
			if pair->wheel#chain#is_inside(done)
				continue
			endif
			eval done->add(pair)
			eval contextualized->add(new_record)
		endfor
	endfor
	" ---- replace old content
	let b:wheel_lines = contextualized
	call wheel#polyphony#update_selection_indexes ()
	call wheel#teapot#filter('dont-update')
	" ---- coda
	return contextualized
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
	if where ==# 'above'
		let linum -= 1
	endif
	if where ==# 'below'
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
	if where ==# 'above'
		let linum -= 1
	endif
	if where ==# 'below'
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

" ---- helpers for mandalas maps

fun! wheel#polyphony#crossroad (key, angle = 'no-angle', modes = ['n', 'n'])
	" Feed key, or run filter if on first line
	" Optional argument :
	"   - angle :
	"     + no-angle, or '' : plain key
	"     + with-angle, or '>' : special key -> "\<key>"
	"   - modes :
	"     + modes[0] : normal or insert mode at the end if on first line
	"     + modes[1] : normal or insert mode at the end if on any other line
	let key = a:key
	let angle = a:angle
	let modes = copy(a:modes)
	eval modes->map({ _, val -> wheel#ouroboros#long_mode (val) })
	let mode_first = modes[0]
	let mode_others = modes[1]
	let linum = line('.')
	if linum == 1
		call wheel#teapot#wrapper (key, angle, mode_first)
		return v:true
	endif
	if angle ==# 'with-angle' || angle ==# '>'
		execute 'let key =' '"\<' .. key .. '>"'
	endif
	if mode_others ==# 'insert'
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
	if key ==# '$'
		normal! $
		return v:true
	endif
	let last_field_pattern = '[^' .. s:field_separ_bar .. ']*$'
	if key ==# '^'
		call cursor(linum, 1)
		call search(last_field_pattern, 'c', linum)
		return v:true
	endif
	if linum != 1
		call search(last_field_pattern, 'c', linum)
	endif
	let insert = key->wheel#chain#is_inside(['i', 'a'])
	if insert
		if key ==# 'a'
			normal! l
		endif
		startinsert
	endif
	return v:true
endfun

fun! wheel#polyphony#insert_ctrl_u ()
	" Ctrl-U on mandala with filter & write command
	let linum = line('.')
	if linum == 1
		call wheel#teapot#reset ()
		return
	endif
	let last_field = '[^' .. s:field_separ_bar .. ']*$'
	let content = getline(linum)
	let content = substitute(content, last_field, '', '')
	call setline(linum, content)
endfun

fun! wheel#polyphony#insert_ctrl_k ()
	" Ctrl-k to delete until end of line in mandala with filter
	let linum = line('.')
	if linum != 1
		" does not work
		"execute 'normal! i' .. "\<c-k>"
		"normal! l
		return v:true
	endif
	let line = getline(1)
	let colnum = col('.')
	let before = strpart(line, 0, colnum - 1)
	call wheel#teapot#set_prompt (before, 'dont-lock')
	call wheel#teapot#filter('update', 'dont-lock')
	startinsert!
	return v:true
endfun

fun! wheel#polyphony#normal_cc ()
	" Normal command cc in hybrid mandala
	startinsert!
	call wheel#polyphony#insert_ctrl_u ()
endfun

" ---- mandalas

fun! wheel#polyphony#filter_maps ()
	" Local filter maps for hybrid filter/write mode
	" ---- property
	let b:wheel_nature.has_filter = v:true
	" ---- normal mode
	nnoremap <buffer> <ins> <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	nnoremap <buffer> <m-i> <cmd>call wheel#teapot#goto_filter_line('insert')<cr>
	nnoremap <buffer> <m-d> <cmd>call wheel#teapot#reset()<cr>
	" ---- insert mode
	inoremap <buffer> <m-f> <c-o>w
	inoremap <buffer> <m-b> <c-o>b
	inoremap <buffer> <m-a> <cmd>call wheel#teapot#insert_ctrl_a()<cr>
	inoremap <buffer> <m-e> <c-o>$
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
	let last_field = 'wheel#polyphony#last_field'
	let across = 'wheel#polyphony#crossroad'
	" ---- normal maps
	let nmap = 'nnoremap <buffer>'
	execute nmap 'i  <cmd>call' last_field "('i')<cr>"
	execute nmap 'a  <cmd>call' last_field "('a')<cr>"
	execute nmap '^  <cmd>call' last_field "('^')<cr>"
	execute nmap '$  <cmd>call' last_field "('$')<cr>"
	execute nmap 'cc <cmd>call wheel#polyphony#normal_cc()<cr>'
	" ---- insert maps
	let imap = 'inoremap <buffer>'
	execute imap '<space> <cmd>call'  across "('space', '>', ['i', 'i'])<cr>"
	execute imap '<c-w>   <cmd>call'  across "('c-w', '>', ['i', 'i'])<cr>"
	execute imap "<cr>    <cmd>call"  across "('cr', '>', ['n', 'i'])<cr>"
	execute imap '<esc>   <esc>:call' across "('esc', '>', ['n', 'n'])<cr>"
	execute imap '<c-u>   <cmd>call wheel#polyphony#insert_ctrl_u()<cr>'
	execute imap '<c-k>   <cmd>call wheel#polyphony#insert_ctrl_k()<cr>'
endfun

fun! wheel#polyphony#navigation_maps (settings)
	" Define whirl maps & set navigation property
	let settings = copy(a:settings)
	" ---- property
	let b:wheel_nature.has_navigation = v:true
	" ---- maps
	let nmap = 'nnoremap <buffer>'
	let loopnav = '<cmd>call wheel#loop#navigation('
	let coda = ')<cr>'
	" -- close after navigation
	let settings.close = v:true
	let settings.target = 'here'
	execute nmap '<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	execute nmap '<m-t>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	execute nmap '<m-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	execute nmap '<m-v>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	execute nmap '<m-s-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	execute nmap '<m-s-v>' loopnav .. string(settings) .. coda
	" -- leave open after navigation
	let settings.close = v:false
	let settings.target = 'here'
	execute nmap 'g<cr>' loopnav .. string(settings) .. coda
	let settings.target = 'tab'
	execute nmap 'g<m-t>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_split'
	execute nmap 'g<m-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_split'
	execute nmap 'g<m-v>' loopnav .. string(settings) .. coda
	let settings.target = 'horizontal_golden'
	execute nmap 'g<m-s-h>' loopnav .. string(settings) .. coda
	let settings.target = 'vertical_golden'
	execute nmap 'g<m-s-v>' loopnav .. string(settings) .. coda
	" -- selection
	call wheel#pencil#mappings ()
	" -- preview
	call wheel#orbiter#mappings ()
	" -- context menu
	call wheel#boomerang#launch_map ('navigation')
endfun

fun! wheel#polyphony#action_maps (mandala = 'file')
	" Define local action maps
	" Optional argument :
	"   - file : for narrow file mandala
	"   - circle : for narrow circle mandala
	let mandala = a:mandala
	execute "nnoremap <buffer> <m-s> <cmd>call wheel#polyphony#substitute('" .. mandala .. "')<cr>"
	if mandala ==# 'file'
		execute "nnoremap <buffer> o <cmd>call wheel#polyphony#append('below')<cr>"
		execute "nnoremap <buffer> O <cmd>call wheel#polyphony#append('above')<cr>"
		execute "nnoremap <buffer> <m-y> <cmd>call wheel#polyphony#duplicate('below')<cr>"
		execute "nnoremap <buffer> <m-z> <cmd>call wheel#polyphony#duplicate('above')<cr>"
	endif
	if mandala ==# 'circle'
		execute 'nnoremap <buffer> <m-c> <cmd>call wheel#polyphony#context()<cr>'
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
