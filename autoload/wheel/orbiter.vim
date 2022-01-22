" vim: set ft=vim fdm=indent iskeyword&:

" Preview for dedicated buffers

fun! wheel#orbiter#preview ()
	" Preview current line in mandala
	let b:wheel_preview.used = v:true
endfun

fun! wheel#orbiter#preview ()
	" Preview current line in mandala
	let b:wheel_preview.used = v:true
endfun

fun! wheel#orbiter#follow ()
	" Preview current line each time the cursor move with j/k
	let b:wheel_preview.used = v:true
	let b:wheel_preview.follow = v:true
endfun

fun! wheel#orbiter#unfollow ()
	" Cancel preview following
	let b:wheel_preview.follow = v:false
endfun

fun! wheel#orbiter#toggle ()
	" Toggle preview following
endfun
