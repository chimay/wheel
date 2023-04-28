" vim: set ft=vim fdm=indent iskeyword&:

" Harmony
"
" Writing functions for local BufWriteCmd autocommand
" in native elements dedicated buffers

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

" ---- grep edit

fun! wheel#counterpoint#grep_edit (ask = 'confirm')
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
	call wheel#rectangle#goto_previous ()
	silent cdo call wheel#vector#cdo(newlines)
	call wheel#cylinder#recall ()
	" -- info
	setlocal nomodified
	echomsg 'quickfix changes propagated'
endfun

" ---- narrow

fun! wheel#counterpoint#narrow_file (ask = 'confirm')
	" Write function for shape#narrow_file
	" -- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" -- buffer
	let bufnum = b:wheel_related.bufnum
	if bufnum ==# 'undefined'
		return v:false
	endif
	" -- update b:wheel_lines
	call wheel#polyphony#update_var_lines ()
	" -- reset filter
	" -- easier since some lines are potentially added
	call wheel#teapot#set_prompt ()
	call wheel#teapot#filter()
	" -- modify file & mandala lines
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
	" -- mandala lines have been modified again in this function
	call wheel#polyphony#update_var_lines ()
	" -- coda
	setlocal nomodified
	echomsg 'changes written to file'
	return v:true
endfun

fun! wheel#counterpoint#narrow_circle (ask = 'confirm')
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
	" -- coda
	setlocal nomodified
	echomsg 'changes written to circle files'
	return v:true
endfun

" ---- reorganize tabs & windows

fun! wheel#counterpoint#baskets (linelist)
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

fun! wheel#counterpoint#arrange_tabs (tabindexes)
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
	let counter = 0
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
		let counter += 1
		if counter > max_iter
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

fun! wheel#counterpoint#arrange_windows (tabwindows)
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

fun! wheel#counterpoint#reorg_tabwin (ask = 'confirm')
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
	let [tabindexes, tabwindows] = wheel#counterpoint#baskets (linelist)
	" -- find the new tab index of mandala tab page
	let startpage = tabindexes->index(startpage) + 1
	" -- arrange tabs : reorder, add and remove
	let [tabindexes, removed] = wheel#counterpoint#arrange_tabs (tabindexes)
	" -- add or remove windows
	call wheel#counterpoint#arrange_windows (tabwindows)
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
