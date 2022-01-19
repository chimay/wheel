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

" helpers

fun! wheel#boomerang#is_context_menu ()
	" Whether mandala leaf is a context menu
	return b:wheel_nature.context_menu
endfun

fun! wheel#boomerang#has_filter ()
	" Whether parent leaf has filter
	let nature = wheel#book#previous('nature')
	return nature.has_filter
endfun

fun! wheel#boomerang#is_filtered ()
	" Whether parent leaf is filtered
	let filter = wheel#book#previous('filter')
	return ! empty(filter.words)
endfun

fun! wheel#boomerang#first_data_line ()
	" First data line of parent leaf
	" Return 1 if parent leaf has no filter, 2 otherwise
	if wheel#boomerang#has_filter ()
		return 2
	else
		return 1
	endif
endfun

fun! wheel#boomerang#is_selection_empty ()
	" Whether parent leaf has non empty selection
	let selection = wheel#book#previous('selection')
	return empty(selection.indexes)
endfun

fun! wheel#boomerang#line_index (linum)
	" Return index of parent line number in parent b:wheel_lines
	let linum = a:linum
	let shift = wheel#boomerang#first_data_line ()
	let index = linum - shift
	let filter = wheel#book#previous('filter')
	if wheel#boomerang#is_filtered ()
		let indexlist = filter.indexes
		return indexlist[index]
	else
		return index
	endif
endfun

fun! wheel#boomerang#addresses ()
	" Return selected addresses of parent leaf
	if wheel#boomerang#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		return [ cursor.address ]
	else
		let selection = copy(wheel#book#previous ('selection'))
		return selection.addresses
	endif
endfun

" sync previous mandala layer -> current mandala state

fun! wheel#boomerang#sync_previous ()
	" Sync selection & settings in previous layer to mandala state
	" -- selection
	if wheel#boomerang#is_selection_empty ()
		let cursor = deepcopy(wheel#book#previous('cursor'))
		let linum = cursor.position[1]
		let line_index = wheel#boomerang#line_index (linum)
		let selection = {}
		let selection.indexes = [ line_index ]
		let selection.addresses = [ cursor.address ]
	else
		let selection = deepcopy(wheel#book#previous ('selection'))
	endif
	let b:wheel_selection = selection
	" -- settings
	let b:wheel_settings = deepcopy(wheel#book#previous('settings'))
endfun

" selection

fun! wheel#boomerang#remove_selected ()
	" Remove selected elements from mandala lines of the previous related layer
	" removed = selected lines or cursor address
	" e.g. : deleted buffers, closed tabs
	" -- previous leaf
	let lines = wheel#book#previous ('lines')
	let selection = wheel#book#previous ('selection')
	for element in selection.addresses
		eval lines->wheel#chain#remove_element(element)
	endfor
	let selection.indexes = []
	let selection.addresses = []
	" -- current leaf
	let cur_selection = {}
	let cur_selection.indexes = []
	let cur_selection.addresses = []
	let b:wheel_selection = cur_selection
endfun

" generic

fun! wheel#boomerang#menu (dictname, optional = {})
	" Context menu
	" -- context menu property
	let b:wheel_nature.context_menu = v:true
	let optional = a:optional
	if ! has_key(optional, 'ctx_close')
		" ctx_close = v:false by default, to be able to perform other
		" operations after this one
		let optional.ctx_close = v:false
	endif
	if ! has_key(optional, 'ctx_travel')
		" ctx_travel = v:false by default, to be able to catch mandala buffer variables
		let optional.ctx_travel = v:false
	endif
	let dictname = 'context/' .. a:dictname
	let settings = {'linefun' : dictname, 'ctx_close' : optional.ctx_close, 'ctx_travel' : optional.ctx_travel}
	call wheel#tower#staircase (settings)
	call wheel#boomerang#sync_previous ()
	" let loop#context_menu handle open / close,
	" tell loop#sailing to forget it
	let b:wheel_settings.close = v:false
	" Reload function
	let b:wheel_reload = "wheel#boomerang#menu('" .. a:dictname .. "')"
endfun

" applications

fun! wheel#boomerang#sailing (action)
	" Sailing actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_action = 'sailing'
	if action == 'current'
		let settings.target = 'current'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'tab'
		let settings.target = 'tab'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'horizontal_split'
		let settings.target = 'horizontal_split'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'vertical_split'
		let settings.target = 'vertical_split'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'horizontal_golden'
		let settings.target = 'horizontal_golden'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'vertical_golden'
		let settings.target = 'vertical_golden'
		call wheel#loop#sailing (settings)
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#buffers (action)
	" Buffers actions
	let action = a:action
	let settings = b:wheel_settings
	if action == 'delete' || action == 'wipe'
		let settings.ctx_action = action
		" remove selected elements from the parent buffer mandala
		call wheel#boomerang#remove_selected ()
		" inform loop#sailing that a loop on selected elements is necessary
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#loop#sailing (settings)
	elseif action =~ 'delete.*hidden' || action =~ 'wipe.*hidden'
		let lines = wheel#book#previous ('lines')
		let filtered = wheel#book#previous ('filtered')
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
	let settings.ctx_action = action
	if action == 'open'
		" wheel#loop#sailing will process the first selected line
		let settings.target = 'current'
		return wheel#loop#sailing (settings)
	elseif action == 'tabnew'
		call wheel#loop#sailing (settings)
		return v:true
	elseif action == 'tabclose'
		" inform wheel#loop#sailing that a loop on selected elements is necessary
		let settings.target = 'none'
		" closing last tab first
		call reverse(b:wheel_selection.addresses)
		call wheel#loop#sailing (settings)
		call reverse(b:wheel_selection.addresses)
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
	let settings.ctx_action = action
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
	let settings.ctx_action = action
	let mode = b:wheel_settings.mode
	call wheel#line#paste_{mode} (action, 'open')
endfun

" mappings

fun! wheel#boomerang#mappings ()
	" Define context menu maps & set property
	nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('sailing')<cr>
endfun
