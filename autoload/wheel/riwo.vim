" vim: set filetype=vim:

" RIWO : Read In Write Out

fun! wheel#riwo#write(pointer, file)
	let var =  {a:pointer}
	redir => content
		silent! echo 'let' a:pointer '=' var
	redir END
	let content = substitute(content, '[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\n\{2,\}', '\n', 'g')
	exec 'redir! > ' . a:file
		silent! echo content
	redir END
endfun
