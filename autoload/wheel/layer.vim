" vim: ft=vim fdm=indent:

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" Save modified local maps
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		let b:wheel_stack.contents = []
		let b:wheel_stack.mappings = []
	endif
	" Content stack
	let lines = getline(1, '$')
	let contents = b:wheel_stack.contents
	call insert(contents, lines)
	" Map stack
	let mappings = b:wheel_stack.mappings
	let enter = maparg('<enter>', 'n')
	let g_enter = maparg('g<enter>', 'n')
	let mapdict = {'enter': enter, 'g_enter': g_enter}
	call insert(mappings, mapdict)
	" Reset b:wheel_lines to filter the new content
	if exists('b:wheel_lines')
		unlet b:wheel_lines
	endif
endfun

fun! wheel#layer#pop ()
	" Pop buffer content from the stack
	" Restore modified local maps
	if ! exists('b:wheel_stack')
		return
	endif
	" Restore content
	let contents = b:wheel_stack.contents
	if ! empty(contents)
		let lines = wheel#chain#pop (contents)
	endif
	call wheel#mandala#replace (lines)
	" Restore mappings
	let mappings = b:wheel_stack.mappings
	if ! empty(mappings)
		let mapdict = wheel#chain#pop (mappings)
	endif
	exe 'nnoremap <cr> ' . mapdict.enter
	exe 'nnoremap g<cr> ' . mapdict.g_enter
endfun
