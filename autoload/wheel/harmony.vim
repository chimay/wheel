" vim: set ft=vim fdm=indent iskeyword&:

" Harmony
"
" Writing functions for local BufWriteCmd autocommand in dedicatated buffers

" ---- script constants

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" ---- wheel elements

fun! wheel#harmony#reorder (level, ask = 'confirm')
	" Reorder elements at level, after buffer content
	let level = a:level
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- reorder
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let key = wheel#referen#list_key (upper_level_name)
	let old_list = deepcopy(wheel#referen#elements (upper))
	let old_names = deepcopy(old_list)
	let old_names = map(old_names, {_,val -> val.name})
	let new_names = wheel#teapot#all_lines ()
	let new_list = []
	for name in new_names
		let index = old_names->index(name)
		if index < 0
			echomsg 'wheel harmony reorder : ' name  'not found'
			continue
		endif
		let elem = old_list[index]
		eval new_list->add(elem)
	endfor
	if len(new_list) < len(old_list)
		echomsg 'Some elements seem to be missing : changes not written'
		return []
	elseif len(new_list) > len(old_list)
		echomsg 'Elements in excess : changes not written'
		return []
	endif
	let upper[key] = new_list
	let upper.glossary = new_names
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return new_list
endfun

fun! wheel#harmony#rename (level, ask = 'confirm')
	" Rename elements at level, after buffer content
	let level = a:level
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- rename
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let names = wheel#teapot#all_lines ()
	let len_names = len(names)
	let len_elements = len(elements)
	if len_names < len_elements
		echomsg 'Some names seem to be missing : changes not written'
		return []
	endif
	if len_names > len_elements
		echomsg 'Names in excess : changes not written'
		return []
	endif
	let upper.glossary = names
	for index in range(len_names)
		let old_name = elements[index].name
		let new_name = names[index]
		" nothing to do if old == new
		if old_name == new_name
			continue
		endif
		let elements[index].name = new_name
		call wheel#pendulum#rename(level, old_name, new_name)
	endfor
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#rectangle#previous ()
	call wheel#vortex#jump()
	call wheel#cylinder#recall()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return elements
endfun

fun! wheel#harmony#rename_file (ask = 'confirm')
	" Rename locations & files of current circle, after buffer content
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- init
	let circle = wheel#referen#circle ()
	let glossary = circle.glossary
	let locations = circle.locations
	let lines = wheel#teapot#all_lines ()
	let len_lines = len(lines)
	let len_locations = len(locations)
	" -- pre-checks
	if len_lines < len_locations
		echomsg 'Some names seem to be missing : changes not written'
		return []
	endif
	if len_lines > len_locations
		echomsg 'Names in excess : changes not written'
		return []
	endif
	" -- rename location
	for index in range(len_lines)
		let fields = split(lines[index], s:field_separ)
		let old_name = glossary[index]
		let new_name = wheel#tree#format_name(fields[0])
		" check not empty
		if empty(old_name) || empty(new_name)
			echomsg 'wheel harmony rename : location name cannot be empty'
			continue
		endif
		" nothing to do if old == new
		if old_name == new_name
			continue
		endif
		" search for location
		let found = glossary->index(new_name)
		if found >= 0 && found != index
			echomsg 'Location' new_name 'already present in circle'
			continue
		endif
		" rename location
		let glossary[index] = new_name
		let locations[index].name = new_name
		call wheel#pendulum#rename('location', old_name, new_name)
	endfor
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	" -- rename file
	for index in range(len_lines)
		let fields = split(lines[index], s:field_separ)
		let old_filename = locations[index].file
		let new_filename = wheel#tree#format_filename (fields[1])
		" old -> new
		let returnstring = wheel#disc#rename(old_filename, new_filename)
		if returnstring != 'success'
			continue
		endif
		echomsg 'wheel : renaming' old_filename '->' new_filename
		let locations[index].file = new_filename
		" wipe old filename buffer if existent
		if bufexists(old_filename)
			execute 'bwipe' old_filename
		endif
		" rename file in all involved locations of the wheel
		call wheel#tree#adapt_to_filename (old_filename, new_filename)
	endfor
	call wheel#rectangle#previous ()
	call wheel#vortex#jump()
	call wheel#cylinder#recall()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return lines
endfun

fun! wheel#harmony#delete (level, ask = 'confirm')
	" Delete selected elements at level, after buffer content
	let level = a:level
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- delete
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let glossary = upper.glossary
	let elements = wheel#referen#elements (upper)
	let selection = wheel#pencil#selection ()
	let components = selection.components
	if empty(components)
		echomsg 'wheel delete : first select element(s)'
	endif
	for name in components
		let index = glossary->index(name)
		if index < 0
			echomsg upper_level_name 'does not contain' name
			continue
		endif
		" remove from elements list
		eval glossary->remove(index)
		eval elements->remove(index)
		if empty(elements)
			let upper.current = -1
		elseif index <= upper.current
			" if removed element index is before current one,
			" the need to decrease current
			let length = len(elements)
			let upper.current = wheel#gear#circular_minus(index, length)
		endif
	endfor
	" clean history
	call wheel#pendulum#broom ()
	" for index auto update at demand
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return elements
endfun

fun! wheel#harmony#copy_move (level, ask = 'confirm')
	" Copy or move selected elements at level
	let level = a:level
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- mode : copy or move
	let prompt = 'Mode ? '
	let answer = confirm(prompt, "&Copy\n&Move", 1)
	if answer == 1
		let mode = 'copy'
	elseif answer == 2
		let mode = 'move'
	endif
	" -- prompt for destination
	let upper_name = wheel#referen#upper_level_name (level)
	let prompt = mode .. ' ' .. level .. ' to ' .. upper_name .. ' ? '
	if level ==# 'torus'
		let destination = 'wheel'
	elseif level ==# 'circle'
		let complete = 'customlist,wheel#complete#torus'
		let destination = input(prompt, '', complete)
	elseif level ==# 'location'
		let complete = 'customlist,wheel#complete#grid'
		let destination = input(prompt, '', complete)
	else
		echomsg 'wheel' mode ': bad level name'
		return v:false
	endif
	let coordin = split(destination, s:level_separ)
	" -- pre checks
	let selection = wheel#pencil#selection ()
	let components = selection.components
	if empty(components)
		echomsg 'wheel copy / move : first select element(s)'
	endif
	if mode == 'move'
		if level ==# 'torus'
			echomsg 'wheel : move torus in wheel = noop'
			return v:false
		elseif level ==# 'circle' && destination ==# wheel#referen#torus().name
			echomsg 'wheel : move circle to current torus = noop'
			return v:false
		elseif level ==# 'location' && coordin ==# wheel#referen#names()[:1]
			echomsg 'wheel : move location to current circle = noop'
			return v:false
		endif
	endif
	" -- departure
	if level ==# 'wheel'
		echomsg 'Cannot copy or move the wheel'
		return v:false
	elseif level ==# 'torus'
		for name in components
			" mode must be copy at this stage
			let index = g:wheel.glossary->index(name)
			let torus = deepcopy(g:wheel.toruses[index])
			call wheel#tree#insert_torus (torus)
		endfor
	else
		let upper = wheel#referen#upper (level)
		let glossary = upper.glossary
		let elements = wheel#referen#elements (upper)
		let travellers = []
		for name in components
			let index = glossary->index(name)
			let elem = deepcopy(elements[index])
			eval travellers->add(elem)
			if mode == 'move'
				call wheel#tree#remove (level, elem.name)
			endif
		endfor
	endif
	" -- destination
	if level ==# 'circle'
		call wheel#vortex#voice ('torus', destination)
		for circle in travellers
			call wheel#tree#insert_circle (circle)
		endfor
	elseif level ==# 'location'
		call wheel#vortex#interval (coordin)
		for location in travellers
			call wheel#tree#insert_location (location)
		endfor
	endif
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	call wheel#rectangle#previous ()
	call wheel#vortex#jump ()
	call wheel#cylinder#recall()
endfun

fun! wheel#harmony#reorganize (ask = 'confirm')
	" Reorganize wheel after elements contained in buffer
	" Rebuild all from scratch
	" Follow folding tree
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- save old wheel before reorganizing
	let prompt = 'Write old wheel to file before reorganizing ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_wheel ()
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- start from empty wheel
	call wheel#gear#unlet ('g:wheel')
	call wheel#void#wheel ()
	" -- loop over buffer lines
	let linelist = wheel#teapot#all_lines ()
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' .. s:fold_1 .. '$'
	let pat_fold_two = '\m' .. s:fold_2 .. '$'
	let pat_dict = '\m^{.*}'
	for line in linelist
		if line =~ pat_fold_one
			" torus line
			let torus = split(line)[0]
			call wheel#tree#add_torus(torus)
		elseif line =~ pat_fold_two
			" circle line
			let circle = split(line)[0]
			call wheel#tree#add_circle(circle)
		elseif line =~ pat_dict
			" location line
			let location = eval(line)
			" no pendulum#record in tree#insert_location
			call wheel#tree#insert_location(location)
		endif
	endfor
	" -- rebuild location index
	call wheel#helix#helix ()
	" -- rebuild circle index
	call wheel#helix#grid ()
	" -- rebuild file index
	call wheel#helix#files ()
	" -- remove invalid entries from history
	call wheel#pendulum#broom ()
	" -- info
	setlocal nomodified
	echomsg 'Changes written to wheel'
	" -- tune wheel coordinates to first entry in history
	call wheel#vortex#chord(g:wheel_history.line[0].coordin)
endfun

" ---- native

" -- grep edit

fun! wheel#harmony#grep_edit (ask = 'confirm')
	" Apply changes done in grep mandala
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#polyphony#update_var_lines ()
	" -- list of (modified) lines
	let linelist = wheel#teapot#all_lines ()
	" -- number of original lines must be equal to number of modified lines
	let elder_len = len(wheel#teapot#all_lines ())
	let new_len = len(linelist)
	if new_len > elder_len
		echomsg 'wheel quickfix write : there are too much line(s)'
		return v:false
	elseif new_len < elder_len
		echomsg 'wheel quickfix write : some line(s) are missing'
		return v:false
	endif
	" -- fill modified lines list
	let newlines = []
	for line in linelist
		if ! empty(line)
			let fields = split(line, s:field_separ)
			eval newlines->add(fields[-1])
		else
			echomsg 'wheel write quickfix : line should not be empty'
			return v:false
		endif
	endfor
	" -- propagate
	call wheel#rectangle#previous ()
	silent cdo call wheel#vector#cdo(newlines)
	call wheel#cylinder#recall ()
	" -- info
	setlocal nomodified
	echomsg 'quickfix changes propagated'
endfun

" -- narrow

fun! wheel#harmony#narrow_file (ask = 'confirm')
	" Write function for shape#narrow_file
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- buffer
	let bufnum = b:wheel_related_buffer
	if bufnum == 'undefined'
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#polyphony#update_var_lines ()
	" -- reset filter
	call wheel#teapot#set_prompt ()
	call wheel#teapot#filter()
	" -- modify file lines
	let linelist = wheel#teapot#all_lines ()
	let linum = wheel#teapot#first_data_line ()
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
			let linum_field = str2nr(object[1:])
			let shift += 1
			let newnum = linum_field + shift
			call appendbufline(bufnum, newnum - 1, content)
			let newnum = printf('%5d', newnum)
			let newline =  newnum .. s:field_separ .. content
			call setline(linum, newline)
		elseif object =~ '^-'
			" line added above
			let linum_field = str2nr(object[1:])
			let shift += 1
			let newnum = linum_field + shift - 1
			call appendbufline(bufnum, newnum - 1, content)
			let newnum = printf('%5d', newnum)
			let newline =  newnum .. s:field_separ .. content
			call setline(linum, newline)
		else
			" existing line
			let linum_field = str2nr(object)
			let newnum = linum_field + shift
			call setbufline(bufnum, newnum, content)
			let newnum = printf('%5d', newnum)
			let newline = newnum .. s:field_separ .. content
			call setline(linum, newline)
		endif
		let linum += 1
	endfor
	" -- lines have been modified again
	call wheel#polyphony#update_var_lines ()
	" -- coda
	setlocal nomodified
	echomsg 'changes written to file'
	return v:true
endfun

fun! wheel#harmony#narrow_circle (ask = 'confirm')
	" Write function for shape#narrow_circle
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#polyphony#update_var_lines ()
	" -- modify circle files lines
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
	echomsg 'changes written to circle files'
	return v:true
endfun

" -- reorganize tabs & windows

fun! wheel#harmony#baskets (linelist)
	" Fill new tab indexes and windows for reorg_tabwin
	let linelist = a:linelist
	" fold marker
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' .. s:fold_1 .. '$'
	" tabs & windows
	let tabindexes = []
	let tabwindows = []
	let lastab = tabpagenr('$')
	let nextab = lastab + 1
	let oldindex = -1
	let newindex = 0
	for line in linelist
		if line =~ pat_fold_one
			" tab line
			let oldindex = str2nr(split(line)[1])
			let newindex += 1
			if wheel#chain#is_inside(oldindex, tabindexes)
				let oldindex = nextab
				let nextab += 1
			endif
			eval tabindexes->add(oldindex)
			eval tabwindows->add([])
		else
			" window line
			eval tabwindows[newindex - 1]->add(line)
		endif
	endfor
	return [tabindexes, tabwindows]
endfun

fun! wheel#harmony#arrange_tabs (tabindexes)
	" Arrange tabs for reorg_tabwin : reorder, add, remove
	" Tie the tabindexes together
	let tabindexes = a:tabindexes
	let [tabindexes, removed] = wheel#chain#tie(tabindexes)
	" tabindexes : start from 0
	let minim = min(tabindexes)
	eval tabindexes->map({ _, val -> val - minim })
	" Remove inner tabs
	for index in removed
		execute 'tabclose' index
	endfor
	" Add new tabs if necessary
	let lentabindexes = len(tabindexes)
	while tabpagenr('$') < lentabindexes
		$ tabnew
	endwhile
	" Reorder
	let l:count = 0
	let max_iter = 2 * g:wheel_config.maxim.tabs
	let from = 0
	" status : start from 0
	" its elements will follow the reordering
	let status = range(lentabindexes)
	while v:true
		while from < lentabindexes && status[from] == tabindexes[from]
			let from += 1
		endwhile
		if from >= lentabindexes
			break
		endif
		let findme = status[from]
		let target = tabindexes->index(findme)
		if target <= 0
			echoerr 'wheel reorg tabs & windows : new tab index not found'
			return v:false
		endif
		execute 'tabnext' from + 1
		execute 'tabmove' target + 1
		let status = wheel#chain#move(status, from, target)
		let l:count += 1
		if l:count > max_iter
			echomsg 'wheel reorg tabs & windows : reached max iter'
			break
		endif
	endwhile
	" Remove trailing unused tabs
	let lastab = tabpagenr('$')
	while lastab > lentabindexes
		eval removed->add(lastab)
		tabclose $
		let lastab = tabpagenr('$')
	endwhile
	return [tabindexes, removed]
endfun

fun! wheel#harmony#arrange_windows (tabwindows)
	" Arrange windows for reorg_tabwin : add, remove
	let tabwindows = a:tabwindows
	let lastab = tabpagenr('$')
	for index in range(lastab)
		let tabind = index + 1
		execute 'tabnext' tabind
		" Adding windows
		let lastwin = winnr('$')
		let basket = tabwindows[index]
		let lastbasket = len(basket)
		let minim = min([lastwin, lastbasket])
		for winum in range(1, minim)
			execute winum 'wincmd w'
			let filename = basket[winum - 1]
			execute 'silent hide edit' filename
		endfor
		" if more buffers in basket than windows
		for winum in range(minim + 1, lastbasket)
			$ wincmd w
			if winwidth(0) >= winheight(0)
				vsplit
			else
				split
			endif
			let filename = basket[winum - 1]
			execute 'silent hide edit' filename
		endfor
		" Removing windows
		" buffers in window
		let winbufs = []
		windo eval winbufs->add(expand('%:p'))
		" looping
		let winum = winnr('$')
		while winum > 0
			execute winum 'wincmd w'
			let filename = expand('%:p')
			let shadow_win = copy(winbufs)
			let shadow_bas = copy(basket)
			let occur_win = len(filter(shadow_win, { _, val -> val == filename }))
			let occur_bas = len(filter(shadow_bas, { _, val -> val == filename }))
			if occur_bas < occur_win && winnr('$') > 1
				eval winbufs->wheel#chain#remove_element(filename)
				close
			endif
			let winum -= 1
		endwhile
	endfor
endfun

fun! wheel#harmony#reorg_tabwin (ask = 'confirm')
	" Reorganize tabs & windows
	" Mandala line list
	" Keep old layouts if possible
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" -- list of lines
	let linelist = wheel#teapot#all_lines ()
	" -- current tab
	let startpage = tabpagenr()
	" -- close mandala to work : otherwise it would be added to the list of windows
	call wheel#cylinder#close ()
	" -- fill the baskets
	let [tabindexes, tabwindows] = wheel#harmony#baskets (linelist)
	" -- find the new tab index of mandala tab page
	let startpage = tabindexes->index(startpage) + 1
	" -- arrange tabs : reorder, add and remove
	let [tabindexes, removed] = wheel#harmony#arrange_tabs (tabindexes)
	" -- add or remove windows
	call wheel#harmony#arrange_windows (tabwindows)
	" -- back to mandala
	let lastab = tabpagenr('$')
	if startpage >= 1 && startpage <= lastab
		execute 'tabnext' startpage
	else
		tabnext 1
	endif
	call wheel#cylinder#recall ()
	" -- clean wheel shelve
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
	let g:wheel_shelve.layout.tab = 'none'
	let g:wheel_shelve.layout.tabnames = []
	" -- tell the world the job is done
	setlocal nomodified
	echomsg 'tabs & windows reorganized'
	" -- return value
	return [tabindexes, tabwindows, removed]
endfun
