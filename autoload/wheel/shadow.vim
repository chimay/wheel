" vim: set ft=vim fdm=indent iskeyword&:

" Shadow
"
" Components generators for dedicated buffers (mandalas)
"
" Useful for folded mandalas, where a line does not contain
" all the information
"
" Examples :
"
" - treeish index : [torus, circle, coordin]
" - tabs & wins : [tab number, window number, file name]

" helpers

fun! wheel#shadow#is_treeish ()
	" Whether mandala has a folded treeish structure
	return b:wheel_nature.is_treeish
endfun

" information

fun! wheel#shadow#tree ()
	" Tree representation of the wheel index
	let returnlist = []
	for torus in g:wheel.toruses
		let entry = [torus.name]
		eval returnlist->add(entry)
		for circle in torus.circles
			let entry = [torus.name, circle.name]
			eval returnlist->add(entry)
			for location in circle.locations
				let entry = [torus.name, circle.name, location.name]
				eval returnlist->add(entry)
			endfor
		endfor
	endfor
	return returnlist
endfun

fun! wheel#shadow#tabwin ()
	" Buffers visible in tabs & wins
	let returnlist = []
	let last_tab = tabpagenr('$')
	let mandalas = g:wheel_mandalas.ring
	for tabnum in range(1, last_tab)
		let entry = [tabnum]
		eval returnlist->add(entry)
		let buflist = tabpagebuflist(tabnum)
		let winum = 0
		for bufnum in buflist
			if wheel#chain#is_inside (bufnum, mandalas)
				continue
			endif
			let winum += 1
			let filename = bufname(bufnum)
			let filename = fnamemodify(filename, ':p')
			let entry = [tabnum, winum, filename]
			eval returnlist->add(entry)
		endfor
	endfor
	return returnlist
endfun

