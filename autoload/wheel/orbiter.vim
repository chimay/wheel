" vim: set ft=vim fdm=indent iskeyword&:

" Preview for dedicated buffers

fun! wheel#orbiter#preview ()
	" Preview buffer matching current line
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous_buffer ()
	endif
	let settings = b:wheel_settings
	call wheel#sailing#default (settings)
	let settings.selected = wheel#line#address ()
	call wheel#rectangle#previous ()
	let Fun = settings.function
	let winiden = wheel#gear#call (Fun, settings)
	call wheel#cylinder#recall ()
	return winiden
endfun

fun! wheel#orbiter#original ()
	" Restore original buffer
	let original = b:wheel_preview.original
	call wheel#rectangle#previous ()
	execute 'buffer' original
	call wheel#cylinder#recall ()
endfun

fun! wheel#orbiter#follow ()
	" Preview current line each time the cursor move with j/k
	if ! b:wheel_preview.used
		let b:wheel_preview.used = v:true
		let b:wheel_preview.original = wheel#rectangle#previous_buffer ()
	endif
	let b:wheel_preview.follow = v:true
	call wheel#orbiter#preview ()
endfun

fun! wheel#orbiter#unfollow ()
	" Cancel preview following
	let b:wheel_preview.used = v:false
	let b:wheel_preview.follow = v:false
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
