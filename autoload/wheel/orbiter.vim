" vim: set ft=vim fdm=indent iskeyword&:

" Orbiter
"
" Preview for dedicated buffers
"
" Note : b:wheel_preview.follow has nothing to do
" with settings.follow. The latter is used to decide
" whether to use projection#follow on target locations

" ---- booleans

fun! wheel#orbiter#has_preview ()
	" Whether current mandala has preview
	return b:wheel_nature.has_preview
endfun

" ---- functions

fun! wheel#orbiter#preview ()
	" Preview buffer matching current line
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous ()
	endif
	let settings = b:wheel_settings
	call wheel#river#default (settings)
	let cursor_info = wheel#pencil#cursor ()
	let settings.selection.index = cursor_info.index
	let settings.selection.component = cursor_info.component
	let settings.follow = v:false
	call wheel#rectangle#goto_previous ()
	call wheel#projection#follow ()
	" ---- user update autocmd
	silent doautocmd User WheelBeforeJump
	" ---- call mandala function
	let Fun = settings.function
	let winiden = wheel#metafun#call (Fun, settings)
	call wheel#cylinder#recall ()
	return winiden
endfun

fun! wheel#orbiter#switch_off ()
	" Switch off preview local variables
	let b:wheel_preview.used = v:false
	let b:wheel_preview.follow = v:false
	let b:wheel_preview.original = {}
endfun

fun! wheel#orbiter#original ()
	" Restore original buffer
	if ! b:wheel_preview.used
		return {}
	endif
	let original = copy(b:wheel_preview.original)
	call wheel#orbiter#switch_off ()
	call wheel#rectangle#goto (original)
	call wheel#projection#follow ()
	call wheel#cylinder#recall ()
	return original
endfun

fun! wheel#orbiter#follow ()
	" Preview current line each time the cursor move with j/k
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous ()
	endif
	call wheel#orbiter#preview ()
	let b:wheel_preview.follow = v:true
endfun

fun! wheel#orbiter#unfollow ()
	" Cancel preview following
	return wheel#orbiter#original ()
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
	" ---- properties
	let b:wheel_nature.has_preview = v:true
endfun
