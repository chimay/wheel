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
	unlet g:wheel
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
	silent global /^$/ delete
	let linelist = getline(1, '$')
	" Current tab
	let startpage = tabpagenr()
	" Close mandala to work
	call wheel#mandala#close ()
	" Fold marker
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' . s:fold_1 . '$'
	" Fill the baskets
	let tabnums = []
	let tabwins = []
	let lastab = tabpagenr('$')
	let nextab = lastab + 1
	let oldindex = -1
	let newindex = 0
	for line in linelist
		if line =~ pat_fold_one
			" tab line
			let oldindex = str2nr(split(line)[1])
			let newindex += 1
			if index(tabnums, oldindex) >= 0
				let oldindex = nextab
				let nextab += 1
			endif
			call add(tabnums, oldindex)
			call add(tabwins, [])
		else
			" window line
			call add(tabwins[newindex - 1], line)
		endif
	endfor
	" Find the new tab index of mandala tab page
	let startpage = index(tabnums, startpage) + 1
	" Tie the tabnums together
	let [tabnums, removed] = wheel#chain#tie(tabnums)
	" tabnums : start from 0
	let minim = min(tabnums)
	call map(tabnums, {_,v -> v - minim})
	" Remove tabs
	for index in removed
		exe 'tabclose' index
	endfor
	" Add new tabs if necessary
	let lentabnums = len(tabnums)
	while tabpagenr('$') < lentabnums
		tabnext $
		tabnew
	endwhile
	" Reorder tabs
	" status : start from 0
	let status = range(lentabnums)
	let from = 0
	let count = 0
	let max_iter = 2 * g:wheel_config.maxim.tabs
	while v:true
		while from < lentabnums && status[from] == tabnums[from]
			let from += 1
		endwhile
		if from >= lentabnums
			break
		endif
		let findme = status[from]
		let target = index(tabnums, findme)
		if target <= 0
			echoerr 'wheel reorg tabs & windows : new tab index not found.'
			return v:false
		endif
		exe 'tabnext' from + 1
		exe 'tabmove' target + 1
		let status = wheel#chain#move(status, from, target)
		let count += 1
		if count > max_iter
			break
		endif
	endwhile
	" Remove trailing unused tabs
	while tabpagenr('$') > lentabnums
		tabclose $
	endwhile
	" Add or remove windows
	for index in range(tabpagenr('$'))
		let tabindex = index + 1
		exe 'tabnext' tabindex
		" adding windows
		let lastwin = winnr('$')
		let basket = tabwins[index]
		let lastbasket = len(basket)
		let minim = min([lastwin, lastbasket])
		for winum in range(1, minim)
			exe winum 'wincmd w'
			let bufname = basket[winum - 1]
			exe 'buffer' bufname
		endfor
		" if more buffers in basket than windows
		for winum in range(minim + 1, lastbasket)
			$ wincmd w
			if winwidth(0) >= winheight(0)
				vsplit
			else
				split
			endif
			let bufname = basket[winum - 1]
			exe 'buffer' bufname
		endfor
		" removing windows
		let winum = 1
		while winum <= winnr('$')
			exe winum 'wincmd w'
			if index(basket, bufname()) < 0 && winnr('$') > 1
				close
			else
				let winum += 1
			endif
		endwhile
	endfor
	" Back to mandala
	if startpage >= 1 && startpage <= tabpagenr('$')
		exe 'tabnext' startpage
	else
		tabnext 1
	endif
	call wheel#cylinder#recall ()
	" Tell the world the job is done
	setlocal nomodified
	echomsg 'tabs & windows reorganized.'
	" Return value
	return [tabnums, tabwins]
endfun
