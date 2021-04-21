" vim: ft=vim fdm=indent:

" Generic helpers

" Script vars

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" Rotating

fun! wheel#gear#circular_plus (index, length)
	" Rotate/increase index with modulo
	return (a:index + 1) % a:length
endfun

fun! wheel#gear#circular_minus (index, length)
	" Rotate/decrease index with modulo
	let index = (a:index - 1) % a:length
	if index < 0
		let index += a:length
	endif
	return index
endfun

" Functions

fun! wheel#gear#call (fun, ...)
	" Call Function depicted as a Funcref or a string
	" Optional arguments are passed to Fun
	if empty(a:fun)
		return v:false
	endif
	let arg = a:000
	let Fun = a:fun
	let kind = type(Fun)
	if kind == v:t_func
		if empty(arg)
			" form : Fun = function('name') without argument
			return Fun()
		else
			" form : Fun = function('name') with arguments
			return call(Fun, arg)
		endif
	elseif kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of wheel#gear#call is ignored
			return eval(Fun)
			" works, but less elegant
			"exe 'let value =' Fun
		elseif empty(arg)
			" form : Fun = 'function' without argument
			return {Fun}()
		else
			" form : Fun = 'function' with arguments
			return call(Fun, arg)
		endif
	else
		" likely not a representation of a function
		" simply forward concatened arguments
		return [Fun] + arg
	endif
endfun

" Directory

fun! wheel#gear#project_root (markers)
	" Change local directory to root of project
	" where current buffer belongs
	if type(a:markers) == v:t_string
		let markers = [a:markers]
	elseif type(a:markers) == v:t_list
		let markers = a:markers
	else
		echomsg 'Wheel Project root : argument must be either a string or a list.'
	endif
	let dir = expand('%:p:h')
	exe 'lcd' dir
	let found = 0
	while v:true
		for mark in markers
			if filereadable(mark) || isdirectory(mark)
				let found = 1
				break
			endif
		endfor
		if found || dir ==# '/'
			break
		endif
		lcd ..
		let dir = getcwd()
	endwhile
endfun

" Cursor

fun! wheel#gear#restore_cursor (position, ...)
	" Restore cursor position
	if a:0 > 0
		let default = a:1
	else
		let default = '$'
	endif
	let position = a:position
	if line('$') > position[1]
		call setpos('.', position)
	else
		call cursor(default, 1)
	endif
endfun

fun! wheel#gear#win_gotoid (iden)
	" Go to win given by iden if iden is a number
	if type(a:iden) == v:t_number
		call win_gotoid (a:iden)
	endif
endfun

" Fold for torus, circle and location

fun! wheel#gear#fold_level ()
	" Wheel level of fold line : torus, circle or location
	if ! &foldenable
		echomsg 'Wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'torus'
	elseif line =~ s:fold_2
		return 'circle'
	else
		return 'location'
	endif
endfun

fun! wheel#gear#parent_fold ()
	" Go to line of parent fold in wheel tree
	let level = wheel#gear#fold_level ()
	if level == 'circle'
		let pattern = '\m' . s:fold_1 . '$'
	elseif level == 'location'
		let pattern = '\m' . s:fold_2 . '$'
	else
		" torus line : we stay there
		return
	endif
	call search(pattern, 'b')
endfun

" Fold for tabs & windows

fun! wheel#gear#tabwin_level ()
	" Level of fold line : tab or filename
	if ! &foldenable
		echomsg 'Wheel gear fold level : fold is disabled in buffer'
		return
	endif
	let line = getline('.')
	if line =~ s:fold_1
		return 'tab'
	else
		return 'filename'
	endif
endfun

fun! wheel#gear#parent_tabwin ()
	" Go to line of parent fold in tabwin tree
	let level = wheel#gear#tabwin_level ()
	if level == 'filename'
		let pattern = '\m' . s:fold_1 . '$'
		call search(pattern, 'b')
	else
		" tab line : we stay there
		return
	endif
endfun

" Mandala layers

fun! wheel#gear#unlet (variable)
	" Unlet variable named variable
	" If var is a list, unlet every variable in it
	let variable = a:variable
	let kind = type(variable)
	if kind == v:t_string
		if exists(variable)
			unlet {variable}
		endif
	elseif kind == v:t_list
		for elem in variable
			call wheel#gear#unlet (elem)
		endfor
	endif
endfun

fun! wheel#gear#unmap (key, ...)
	" Unmap buffer mapping key in mode
	" If key is a list, unmap every key in it
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'n'
	endif
	let key = a:key
	let typekey = type(key)
	if typekey == v:t_string
		" dictionary with map caracteristics
		let dict = maparg(key, mode, 0, 1)
		if ! empty(dict) && dict.buffer
			let pre = mode . 'unmap <silent> <buffer> '
			let runme = pre . key
			exe runme
		endif
	elseif typekey == v:t_list
		for elem in key
			call wheel#gear#unmap(elem, mode)
		endfor
	else
		echomsg 'Wheel gear unmap : bad key format'
	endif
endfun

fun! wheel#gear#autocmds (event)
	" Return a list of buffer local autocmds at event
	let runme = 'autocmd wheel ' . a:event . ' <buffer>'
	let output = execute(runme)
	let lines = split(output, '\n')
	if len(lines) < 3
		return []
	endif
	let lines = lines[2:]
	let autocom = []
	let here = v:false
	for elem in lines
		if elem =~ '<buffer=[^>]\+>'
			if elem =~ '\m<buffer=' . bufnr('%') . '>'
				let here = v:true
			else
				let here = v:false
			endif
		else
			if here
				let elem = substitute(elem, '\m^\s*', '', '')
				call add(autocom, elem)
			endif
		endif
	endfor
	return autocom
endfun

" Misc

" Used by chain#tie

fun! wheel#gear#decrease_greater(number, treshold)
	" Return number - 1 if > treshold, else return number
	if a:number > a:treshold
		return a:number - 1
	else
		return a:number
	endif
endfun
