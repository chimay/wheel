" vim: set ft=vim fdm=indent iskeyword&:

" Boomerang
"
" Context menu
" Act back on parent, previous leaf of mandala

" Script constants

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
	return b:wheel_nature.class == 'menu/context'
endfun

" mandalas

fun! wheel#boomerang#launch_map (type)
	" Define map to launch context menu
	" -- navigation by default
	let type = a:type
	exe "nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu('" .. type .. "')<cr>"
endfun

fun! wheel#boomerang#menu (dictname)
	" Build context menu
	let dictname = 'context/' .. a:dictname
	let settings = b:wheel_settings
	let settings.menu = #{class : 'menu/context', linefun : dictname, close : v:false, travel : v:false}
	" ---- add new leaf, replace mandala content by a {line->fun} leaf
	call wheel#tower#staircase (settings)
	" ---- properties ; must come after tower#staircase
	" -- selection property
	let b:wheel_nature.has_selection = v:false
	" -- class : context menu
	let b:wheel_nature.class = 'menu/context'
	" -- let loop#menu handle open / close, tell loop#selection to forget it
	let b:wheel_settings.close = v:false
	" -- reload function
	let b:wheel_reload = "wheel#boomerang#menu('" .. a:dictname .. "')"
endfun

" applications

fun! wheel#boomerang#navigation (target)
	" Navigation actions
	let target = a:target
	let settings = b:wheel_settings
	let settings.menu.action = 'navigation'
	if target->wheel#chain#is_inside(s:mandala_targets)
		let settings.target = target
		call wheel#loop#selection (settings)
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#buffer (action)
	" Buffers actions
	" Only called for non navigation actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'delete'
		call wheel#loop#boomerang (settings)
		" dont remove parent selection on buffer/all
		if wheel#mandala#type () == 'buffer'
			call wheel#upstream#remove_selection ()
		endif
	elseif action == 'unload'
		call wheel#loop#boomerang (settings)
	elseif action == 'wipe'
		call wheel#loop#boomerang (settings)
		call wheel#upstream#remove_selection ()
	elseif action =~ 'delete.*hidden' || action =~ 'wipe.*hidden'
		let lines = wheel#book#previous ('lines')
		let filter = wheel#book#previous ('filter')
		" hidden buffers
		if action == 'delete_hidden' || action == 'wipe_hidden'
			let hidden = wheel#rectangle#hidden_buffers ()[0]
		elseif action == 'wipe_all_hidden'
			let hidden = wheel#rectangle#hidden_buffers ('all')[0]
		else
			echomsg 'wheel boomerang buffer : bad action format'
		endif
		if empty(hidden)
			echomsg 'no hidden buffer'
			return v:false
		endif
		let hidden = reverse(hidden)
		let rangelines = reverse(range(len(lines)))
		" remove lines
		for index in rangelines
			let record = lines[index]
			let fields = split(record, s:field_separ)
			let bufnum = str2nr(fields[0])
			if bufnum->wheel#chain#is_inside(hidden)
				eval lines->remove(index)
				if ! empty(filter.indexes)
					let where = filter.indexes->index(index)
					eval filter.indexes->remove(where)
					eval filter.lines->remove(where)
				endif
			endif
		endfor
		" remove buffers
		if action == 'delete_hidden'
			for bufnum in hidden
				execute 'silent bdelete' bufnum
			endfor
			echomsg 'hidden buffers deleted'
		elseif  action =~ 'wipe.*hidden'
			for bufnum in hidden
				execute 'silent bwipe!' bufnum
			endfor
			echomsg 'hidden buffers wiped'
		endif
	endif
	return v:true
endfun

fun! wheel#boomerang#tabwin (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'open'
		" loop#selection will process the first selected line
		let settings.target = 'current'
		return wheel#loop#selection (settings)
	elseif action == 'tabnew'
		tabnew
		return v:true
	elseif action == 'tabclose'
		" closing last tab first
		let settings.menu.class = 'menu/context'
		let selection = wheel#upstream#selection()
		let indexes = selection.indexes
		let components = selection.components
		let original_indexes = copy(indexes)
		let original_components = copy(components)
		let [indexlist, indexes] = wheel#chain#sort(indexes)
		call reverse(indexes)
		call reverse(indexlist)
		let selection.indexes = indexes
		let selection.components = components->wheel#chain#sublist(indexlist)
		call wheel#loop#boomerang (settings)
		let selection.indexes = original_indexes
		let selection.components = original_components
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#tabwin_tree (action)
	" Buffers visible in tree of tabs & wins
	return wheel#boomerang#tabwin (a:action)
endfun

fun! wheel#boomerang#grep (action)
	" Grep actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action == 'quickfix'
		call wheel#cylinder#close ()
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
