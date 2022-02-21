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

" ---- helpers

fun! wheel#boomerang#is_context_menu ()
	" Whether mandala leaf is a context menu
	if ! wheel#cylinder#is_mandala ()
		return v:false
	endif
	return b:wheel_nature.class ==# 'menu/context'
endfun

fun! wheel#boomerang#hidden_buffers (action)
	" Execute action on hidden buffers
	let action = a:action
	let lines = wheel#book#previous ('lines')
	let filter = wheel#book#previous ('filter')
	" ---- hidden buffers
	if action ==# 'delete_hidden' || action ==# 'wipe_hidden'
		let hidden = wheel#rectangle#hidden_buffers ()[0]
	elseif action ==# 'wipe_all_hidden'
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
	" ---- remove lines
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
	" ---- remove buffers
	if action ==# 'delete_hidden'
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
endfun

" ---- mandalas

fun! wheel#boomerang#launch_map (type)
	" Define map to launch context menu
	" -- navigation by default
	let type = a:type
	exe 'nnoremap <buffer> <tab> <cmd>call wheel#boomerang#menu(' .. string(type) .. ')<cr>'
endfun

fun! wheel#boomerang#menu (dictname)
	" Build context menu
	let dictname = 'context/' .. a:dictname
	let settings = deepcopy(b:wheel_settings)
	" close is false for space & tab
	" within tower#staircase -> tower#mappings
	let menuset = #{
				\ class : 'menu/context',
				\ linefun : dictname,
				\ close : v:true,
				\ }
	call wheel#tower#staircase (menuset, settings)
	" ---- properties ; must come after tower#staircase
	" -- let loop#menu handle open / close, tell loop#navigation to forget it
	let settings.close = v:false
	" -- reload function
	call wheel#mandala#set_reload('wheel#boomerang#menu', a:dictname)
endfun

" ---- applications

fun! wheel#boomerang#navigation (target)
	" Navigation actions
	let target = a:target
	let settings = b:wheel_settings
	let settings.menu.action = 'navigation'
	if ! target->wheel#chain#is_inside(s:mandala_targets)
		return v:false
	endif
	let settings.target = target
	call wheel#loop#navigation (settings)
	return v:true
endfun

fun! wheel#boomerang#buffer (action)
	" Buffers actions
	" Only called for non navigation actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action ==# 'delete'
		call wheel#loop#buffer_delete ()
	elseif action ==# 'unload'
		call wheel#loop#buffer_unload ()
	elseif action ==# 'wipe'
		call wheel#loop#buffer_wipe ()
	elseif action =~ 'delete.*hidden' || action =~ 'wipe.*hidden'
		call wheel#boomerang#hidden_buffers (action)
	endif
	return v:true
endfun

fun! wheel#boomerang#tabwin (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.menu.action = action
	if action ==# 'open'
		" tell loop#navigation to not care about opening a new
		" target tab or window
		let settings.target = 'current'
		return wheel#loop#navigation (settings)
	elseif action ==# 'tabnew'
		tabnew
		return v:true
	elseif action ==# 'tabclose'
		call wheel#loop#tabclose ()
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
	if action ==# 'quickfix'
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
