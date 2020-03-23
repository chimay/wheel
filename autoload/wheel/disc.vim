" vim: set filetype=vim:

" Storage

fun! wheel#disc#write(pointer, file)
	" Write variable referenced by string pointer to file
	" in a format that can be :sourced
	let var =  {a:pointer}
	redir => content
		silent! echo 'let' a:pointer '=' var
	redir END
	let content = substitute(content, '[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\n\{2,\}', '\n', 'g')
	exec 'redir! > ' . a:file
		silent! echo content
	redir END
	echomsg 'Variable' a:pointer 'wrote to ' a:file
endfun

fun! wheel#disc#read(file)
	" Read file
	exe 'source ' . a:file
	echomsg 'File' a:file 'sourced'
endfun

fun! wheel#disc#write_all()
	call wheel#disc#write('g:wheel', g:wheel_config.file)
endfun

fun! wheel#disc#read_all()
	call wheel#disc#read(g:wheel_config.file)
endfun
