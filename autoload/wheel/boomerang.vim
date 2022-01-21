" vim: set ft=vim fdm=indent iskeyword&:

" Context menu
" Act back on parent, previous leaf of mandala

" Script constants

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:mandala_targets')
	let s:mandala_targets = wheel#crystal#fetch('mandala/targets')
	lockvar s:mandala_targets
endif

" helpers

fun! wheel#boomerang#is_context_menu ()
	" Whether mandala leaf is a context menu
	return b:wheel_nature.context_menu
endfun

" sync parent leaf -> current one

fun! wheel#boomerang#sync_from_parent ()
	" Sync selection & settings in previous layer to mandala state
	" -- selection
	let b:wheel_selection = wheel#boomerang#selection ()
	" -- settings
	let b:wheel_settings = deepcopy(wheel#book#previous('settings'))
endfun

" selection

fun! wheel#boomerang#remove_selected ()
	" Parent leaf : remove selection & related lines, reset filter
	" removed = selected lines or cursor address
	" e.g. : deleted buffers, closed tabs
	" -- clear lines
	let lines = wheel#book#previous ('lines')
	let selection = b:wheel_selection
	for index in selection.indexes
		eval lines->remove(index)
	endfor
	" -- clear selection
	let selection.indexes = []
	let selection.addresses = []
	" parent leaf
	let selection = wheel#book#previous('selection')
	let selection.indexes = []
	let selection.addresses = []
	" -- clear filter
	let filter = wheel#book#previous ('filter')
	let filter.words = []
	let filter.indexes = []
	let filter.lines = []
endfun

" mandalas

fun! wheel#boomerang#launch_map (type)
	" Define map to launch context menu
	" -- sailing by default
	let type = a:type
	exe "nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('" .. type .. "')<cr>"
endfun

fun! wheel#boomerang#menu (dictname)
	" Build context menu
	let dictname = 'context/' .. a:dictname
	let settings = b:wheel_settings
	let settings.menu = #{kind : 'context', linefun : dictname, close : v:false, travel : v:false}
	" ---- add new leaf, replace mandala content by a {line->fun} leaf
	call wheel#tower#staircase (settings)
	" ---- seek selection & settings from parent leaf
	call wheel#boomerang#sync_from_parent ()
	" ---- properties ; must come after tower#staircase
	" -- selection property
	let b:wheel_nature.has_selection = v:false
	" -- context menu property
	let b:wheel_nature.context_menu = v:true
	" -- let loop#menu handle open / close, tell loop#sailing to forget it
	let b:wheel_settings.close = v:false
	" -- reload function
	let b:wheel_reload = "wheel#boomerang#menu('" .. a:dictname .. "')"
endfun

" applications

fun! wheel#boomerang#sailing (target)
	" Sailing actions
	let target = a:target
	let settings = b:wheel_settings
	let settings.menu.action = 'sailing'
	if target->wheel#chain#is_inside(s:mandala_targets)
		let settings.target = target
		call wheel#loop#sailing (settings)
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#buffers (action)
	" Buffers actions
	" Only called for non-sailing actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'delete'
		" dont remove parent selection on buffers/all
		if wheel#mandala#type () == 'buffers'
			call wheel#boomerang#remove_selected ()
		endif
		call wheel#loop#boomerang (settings)
	elseif action == 'wipe'
		call wheel#boomerang#remove_selected ()
		call wheel#loop#boomerang (settings)
	elseif action =~ 'delete.*hidden' || action =~ 'wipe.*hidden'
		let lines = wheel#book#previous ('lines')
		let filtered = wheel#book#previous ('filter')
		if action == 'delete_hidden' || action == 'wipe_hidden'
			let hidden = wheel#rectangle#hidden_buffers ()[0]
		elseif action == 'wipe_all_hidden'
			let hidden = wheel#rectangle#hidden_buffers ('all')[0]
		else
			echomsg 'wheel boomerang buffer : bad action format'
		endif
		if empty(hidden)
			echomsg 'no hidden buffer.'
			return v:false
		endif
		for elem in lines
			let fields = split(elem, s:field_separ)
			let bufnum = str2nr(fields[0])
			if wheel#chain#is_inside (bufnum, hidden)
				eval lines->wheel#chain#remove_element(elem)
				eval filtered->wheel#chain#remove_element(elem)
			endif
		endfor
		if action == 'delete_hidden'
			for bufnum in hidden
				execute 'silent bdelete' bufnum
			endfor
			echomsg 'hidden buffers deleted.'
		elseif  action =~ 'wipe.*hidden'
			for bufnum in hidden
				execute 'silent bwipe!' bufnum
			endfor
			echomsg 'hidden buffers wiped.'
		endif
	endif
	return v:true
endfun

fun! wheel#boomerang#tabwins (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'open'
		" loop#sailing will process the first selected line
		let settings.target = 'current'
		return wheel#loop#sailing (settings)
	elseif action == 'tabnew'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'tabclose'
		" closing last tab first
		let settings.menu.kind = 'context'
		let original_indexes = b:wheel_selection.indexes
		let original_addresses = b:wheel_selection.addresses
		let indexes = original_indexes
		let addresses = original_addresses
		let [indexlist, indexes] = wheel#chain#sort(indexes)
		call reverse(indexes)
		call reverse(indexlist)
		let b:wheel_selection.indexes = indexes
		let b:wheel_selection.addresses = addresses->wheel#chain#sublist(indexlist)
		call wheel#loop#boomerang (settings)
		let b:wheel_selection.indexes = original_indexes
		let b:wheel_selection.addresses = original_addresses
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#tabwins_tree (action)
	" Buffers visible in tree of tabs & wins
	return wheel#boomerang#tabwins (a:action)
endfun

fun! wheel#boomerang#grep (action)
	" Grep actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'quickfix'
		call wheel#mandala#close ()
		call wheel#vector#copen ()
	endif
endfun

fun! wheel#boomerang#yank (action)
	" Yank actions
	" action = before / after
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	let mode = b:wheel_settings.mode
	call wheel#line#paste_{mode} (action, 'open')
endfun
