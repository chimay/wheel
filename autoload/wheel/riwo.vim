" vim: set filetype=vim:

" RIWO : Read In Write Out

fun! wheel#riwo#write(pointer, file)
	let l:var =  {a:pointer}
	redir => l:content
		silent! echo 'let' a:pointer '=' l:var
	redir END
	let l:content = substitute(l:content, '[=,]', '\0\n\\', 'g')
	let l:content = substitute(l:content, '\n\{2,\}', '\n', 'g')
	exec 'redir! > ' . a:file
		silent! echo l:content
	redir END
endfun
