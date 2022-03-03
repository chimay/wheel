" vim: set ft=vim fdm=indent iskeyword&:

" Loop
"
" Loops on mandala selections

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- navigation

fun! wheel#loop#navigation (settings)
	" Call navigation function
	" settings keys :
	"   - function : navigation function name or funcref
	"   - target : current window, tab, horizontal or vertical split,
	"              even or with golden ratio
	"   - related buffer of current mandala
	"   - close : whether to close mandala
	let settings = deepcopy(a:settings)
	call wheel#river#default (settings)
	let Fun = settings.function
	let target = settings.target
	let close = settings.close
	" ---- selection
	let selection = wheel#pencil#selection ()
	let indexes = selection.indexes
	let components = selection.components
	if empty(indexes)
		return v:false
	endif
	" ---- switch off preview
	call wheel#orbiter#switch_off ()
	" ---- go to previous window before processing
	call wheel#rectangle#goto_previous ()
	" ---- target : current window or not ?
	if target ==# 'here'
		let settings.selection.index = selection.indexes[0]
		let settings.selection.component = selection.components[0]
		let winiden = Fun->wheel#metafun#call(settings)
		call wheel#spiral#cursor ()
	else
		let length = len(indexes)
		for ind in range(length)
			let settings.selection.index = selection.indexes[ind]
			let settings.selection.component = selection.components[ind]
			let winiden = Fun->wheel#metafun#call(settings)
			call wheel#spiral#cursor ()
		endfor
	endif
	" ---- coda
	if close
		call wheel#cylinder#close ()
		" go to last destination
		call win_gotoid (winiden)
	else
		" no need to trigger WheelBeforeJump : the operation is already done
		" vortex#update overrides native navigation signs
		" by location signs on some files
		call wheel#cylinder#recall ('dont-trigger')
	endif
	return winiden
endfun

" ---- context menus

fun! wheel#loop#buffer_delete ()
	" Delete buffers
	let selection = wheel#upstream#selection ()
	let components = selection.components
	for elem in components
		let fields = split(elem, s:field_separ)
		let bufnum = str2nr(fields[0])
		execute 'silent bdelete' bufnum
		echomsg 'buffer' bufnum 'deleted'
	endfor
	" dont remove parent selection on buffer/all
	if wheel#mandala#type () ==# 'buffer'
		call wheel#upstream#remove_selection ()
	endif
endfun

fun! wheel#loop#buffer_unload ()
	" Unload buffers
	let selection = wheel#upstream#selection ()
	let components = selection.components
	for elem in components
		let fields = split(elem, s:field_separ)
		let bufnum = str2nr(fields[0])
		execute 'silent bunload' bufnum
		echomsg 'buffer' bufnum 'unloaded'
	endfor
endfun

fun! wheel#loop#buffer_wipe ()
	" Wipe buffers
	let selection = wheel#upstream#selection ()
	let components = selection.components
	for elem in components
		let fields = split(elem, s:field_separ)
		let bufnum = str2nr(fields[0])
		execute 'silent bwipe' bufnum
		echomsg 'buffer' bufnum 'wiped'
	endfor
	call wheel#upstream#remove_selection ()
endfun

fun! wheel#loop#tabclose ()
	" Close tabs
	let selection = wheel#upstream#selection()
	let indexes = selection.indexes
	let components = selection.components
	let [shuffled, indexes] = wheel#chain#sort(indexes)
	call reverse(indexes)
	call reverse(shuffled)
	let selection.indexes = indexes
	let selection.components = components->wheel#chain#sublist(shuffled)
	let components = selection.components
	let cur_tab = tabpagenr()
	for elem in components
		if type(elem) == v:t_string
			" plain, unfolded, tabs & wins
			let fields = split(elem, s:field_separ)
			let tabnum = str2nr(fields[0])
		else
			" tree, folded tabs & wins
			let tabnum = elem[0]
		endif
		if tabnum == cur_tab
			echomsg 'wheel line tabwin : will not close current tab page'
			continue
		endif
		echomsg 'noautocmd tabclose' tabnum
		execute 'noautocmd tabclose' tabnum
	endfor
	call wheel#upstream#remove_selection ()
endfun
