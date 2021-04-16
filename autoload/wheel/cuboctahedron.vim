" vim: ft=vim fdm=indent:

" Changes of internal structure

" Script vars

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

" Reorg tabwins helpers

fun! wheel#cuboctahedron#baskets (linelist)
	" Fill new tab indexes and windows for reorg_tabwins
	let linelist = a:linelist
	" fold marker
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' . s:fold_1 . '$'
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
			if index(tabindexes, oldindex) >= 0
				let oldindex = nextab
				let nextab += 1
			endif
			call add(tabindexes, oldindex)
			call add(tabwindows, [])
		else
			" window line
			call add(tabwindows[newindex - 1], line)
		endif
	endfor
	return [tabindexes, tabwindows]
endfun

fun! wheel#cuboctahedron#arrange_tabs (tabindexes)
	" Arrange tabs for reorg_tabwins : reorder, add, remove
	" Tie the tabindexes together
	let tabindexes = a:tabindexes
	let [tabindexes, removed] = wheel#chain#tie(tabindexes)
	" tabindexes : start from 0
	let minim = min(tabindexes)
	call map(tabindexes, {_,v -> v - minim})
	" Remove inner tabs
	for index in removed
		exe 'tabclose' index
	endfor
	" Add new tabs if necessary
	let lentabindexes = len(tabindexes)
	while tabpagenr('$') < lentabindexes
		$ tabnew
	endwhile
	" Reorder
	let count = 0
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
		let target = index(tabindexes, findme)
		if target <= 0
			echoerr 'wheel reorg tabs & windows : new tab index not found.'
			return v:false
		endif
		exe 'tabnext' from + 1
		exe 'tabmove' target + 1
		let status = wheel#chain#move(status, from, target)
		let count += 1
		if count > max_iter
			echomsg 'wheel reorg tabs & windows : reached max iter.'
			break
		endif
	endwhile
	" Remove trailing unused tabs
	let lastab = tabpagenr('$')
	while lastab > lentabindexes
		call add(removed, lastab)
		tabclose $
		let lastab = tabpagenr('$')
	endwhile
	return [tabindexes, removed]
endfun

fun! wheel#cuboctahedron#arrange_windows (tabwindows)
	" Arrange windows for reorg_tabwins : add, remove
	let tabwindows = a:tabwindows
	let lastab = tabpagenr('$')
	for index in range(lastab)
		let tabind = index + 1
		exe 'tabnext' tabind
		" Adding windows
		let lastwin = winnr('$')
		let basket = tabwindows[index]
		let lastbasket = len(basket)
		let minim = min([lastwin, lastbasket])
		for winum in range(1, minim)
			exe winum 'wincmd w'
			let filename = basket[winum - 1]
			exe 'silent edit' filename
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
			exe 'silent edit' filename
		endfor
		" Removing windows
		" buffers in window
		let winbufs = []
		windo call add(winbufs, expand('%:p'))
		" looping
		let winum = winnr('$')
		while winum > 0
			exe winum 'wincmd w'
			let filename = expand('%:p')
			let shadow_win = copy(winbufs)
			let shadow_bas = copy(basket)
			let occur_win = len(filter(shadow_win, {_,v -> v == filename}))
			let occur_bas = len(filter(shadow_bas, {_,v -> v == filename}))
			if occur_bas < occur_win && winnr('$') > 1
				call wheel#chain#remove_element(filename, winbufs)
				close
			endif
			let winum -= 1
		endwhile
	endfor
endfun

" Functions

fun! wheel#cuboctahedron#reorder (level)
	" Reorder current elements at level, after buffer content
	let level = a:level
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let key = wheel#referen#list_key (upper_level_name)
	let old_list = deepcopy(wheel#referen#elements (upper))
	let old_names = deepcopy(old_list)
	let old_names = map(old_names, {_,val -> val.name})
	let new_names = getline(1, '$')
	let new_list = []
	for name in new_names
		let index = index(old_names, name)
		if index >= 0
			let elem = old_list[index]
		else
			echomsg 'Wheel cuboctahedron reorder : ' name  'not found'
		endif
		call add(new_list, elem)
	endfor
	if len(new_list) < len(old_list)
		echomsg 'Some elements seem to be missing : changes not written'
	elseif len(new_list) > len(old_list)
		echomsg 'Elements in excess : changes not written'
	else
		let upper[key] = []
		let upper[key] = new_list
		let upper.glossary = new_names
		setlocal nomodified
		echomsg 'Changes written to wheel'
		return new_list
	endif
endfun

fun! wheel#cuboctahedron#reorganize ()
	" Rebuild wheel by adding elements contained in buffer
	" Follow folding tree
	" The add_* will record new timestamps ; let’s keep the old ones
	let prompt = 'Write old wheel to file before reorganizing ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_all ()
	endif
	" Start from empty wheel
	call wheel#gear#unlet ('g:wheel')
	call wheel#void#wheel ()
	" Loop over buffer lines
	let linelist = getline(1, '$')
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' . s:fold_1 . '$'
	let pat_fold_two = '\m' . s:fold_2 . '$'
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
			let runme = 'let location = ' . line
			exe runme
			call wheel#tree#add_location(location, 'norecord')
		endif
	endfor
	" Rebuild full location index
	call wheel#helix#album ()
	" Rebuild location index
	call wheel#helix#helix ()
	" Rebuild circle index
	call wheel#helix#grid ()
	" Rebuild file index
	call wheel#helix#files ()
	" Remove invalid entries from history
	call wheel#checknfix#history ()
	" Info
	setlocal nomodified
	echomsg 'Changes written to wheel'
	" Tune wheel coordinates to first entry in history
	call wheel#vortex#chord(g:wheel_history[0].coordin)
endfun

fun! wheel#cuboctahedron#reorg_tabwins ()
	" Reorganize tabs & windows
	" Mandala line list
	" Keep old layouts if possible
	let linelist = getline(1, '$')
	" Current tab
	let startpage = tabpagenr()
	" Close mandala to work
	call wheel#mandala#close ()
	" Fill the baskets
	let [tabindexes, tabwindows] = wheel#cuboctahedron#baskets (linelist)
	" Find the new tab index of mandala tab page
	let startpage = index(tabindexes, startpage) + 1
	" Arrange tabs : reorder, add and remove
	let [tabindexes, removed] = wheel#cuboctahedron#arrange_tabs (tabindexes)
	" Add or remove windows
	call wheel#cuboctahedron#arrange_windows (tabwindows)
	" Back to mandala
	let lastab = tabpagenr('$')
	if startpage >= 1 && startpage <= lastab
		exe 'tabnext' startpage
	else
		tabnext 1
	endif
	call wheel#cylinder#recall ()
	" Tell the world the job is done
	setlocal nomodified
	echomsg 'tabs & windows reorganized.'
	" Return value
	return [tabindexes, tabwindows, removed]
endfun
