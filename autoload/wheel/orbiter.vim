" vim: set ft=vim fdm=indent iskeyword&:

" Preview for dedicated buffers

fun! wheel#orbiter#preview ()
	" Preview buffer matching current line
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous_buffer ()
	endif
	let settings = b:wheel_settings
	call wheel#whirl#default (settings)
	let cursor_selection = wheel#pencil#cursor_selection ()
	let settings.selection.index = cursor_selection.indexes[0]
	let settings.selection.component = cursor_selection.components[0]
	let settings.follow = v:false
	call wheel#rectangle#previous ()
	call wheel#projection#follow ()
	call wheel#vortex#update ()
	let Fun = settings.function
	let winiden = wheel#gear#call (Fun, settings)
	call wheel#cylinder#recall ()
	return winiden
endfun

fun! wheel#orbiter#switch_off ()
	" Switch off preview local variables
	let b:wheel_preview.used = v:false
	let b:wheel_preview.follow = v:false
	let b:wheel_preview.original = 'undefined'
endfun

fun! wheel#orbiter#original ()
	" Restore original buffer
	if ! b:wheel_preview.used
		return v:true
	endif
	let original = b:wheel_preview.original
	call wheel#orbiter#switch_off ()
	let type = wheel#mandala#type ()
	if type =~ 'tabwins'
		call wheel#rectangle#goto_or_load (original)
		call wheel#cylinder#recall ()
		return v:true
	endif
	call wheel#rectangle#previous ()
	execute 'buffer' original
	call wheel#projection#follow ()
	call wheel#vortex#jump ()
	call wheel#cylinder#recall ()
	return v:true
endfun

fun! wheel#orbiter#follow ()
	" Preview current line each time the cursor move with j/k
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous_buffer ()
	endif
	call wheel#orbiter#preview ()
	let b:wheel_preview.follow = v:true
endfun

fun! wheel#orbiter#unfollow ()
	" Cancel preview following
	call wheel#orbiter#original ()
endfun

fun! wheel#orbiter#toggle_follow ()
	" Toggle preview following
	if b:wheel_preview.follow
		call wheel#orbiter#unfollow ()
	else
		call wheel#orbiter#follow ()
	endif
endfun

fun! wheel#orbiter#mappings ()
	" Define preview maps
	nnoremap <buffer> p <cmd>call wheel#orbiter#preview()<cr>
	nnoremap <buffer> o <cmd>call wheel#orbiter#original()<cr>
	nnoremap <buffer> f <cmd>call wheel#orbiter#toggle_follow()<cr>
endfun
