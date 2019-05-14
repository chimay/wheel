" vim: set filetype=vim:

" RIWO : Read In Write Out

fun! wheel#riwo#write(var, file)
	redir => content
		silent! echo a:var
	redir END
	let lines = substitute(content, '\([:,]\)', '\1\n\\', 'g')
	exe 'edit ' a:file
	%delete
	put =lines
	write
	bdelete
endfun
