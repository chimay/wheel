" vim: set ft=vim fdm=indent iskeyword&:

" Group
"
" Auto grouping

fun! wheel#group#extension(location)
	" Filename extension
	return fnamemodify(a:location.file, ':e')
endfun

fun! wheel#group#directory(location)
	" Depth levels of directory
	let dir = fnamemodify(a:location.file, ':p:h')
	let dir = dir[1:]
	let dirname = substitute(dir, '/', '-', 'g')
	return dirname
endfun

fun! wheel#group#dispatch(dispatcher)
	" Auto grouping
	let Dispatcher = a:dispatcher
	if type(Dispatcher) == v:t_func
		let Fun = Dispatcher
	elseif type(Dispatcher) == v:t_string
		let Fun = function(Dispatcher)
	else
		echoerr 'wheel#group#auto : bad argument format'
	endif
	let groups = {}
	let torus = wheel#referen#current('torus')
	for circle in torus.circles
		for location in deepcopy(circle.locations)
			let extension = Fun(location)
			if ! has_key(groups, extension)
				let groups[extension] = [location]
			else
				eval groups[extension]->add(location)
			endif
		endfor
	endfor
	return groups
endfun

fun! wheel#group#torus(method)
	" New torus with autogrouped locations
	let prompt = 'Write old wheel to file before autogrouping ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_wheel ()
	endif
	let method = a:method
	let name = wheel#referen#current('torus').name
	let name ..= '-by-' .. method
	let fun = 'wheel#group#' .. method
	let groups = wheel#group#dispatch(fun)
	if wheel#tree#add_torus (name)
		for [key, localist] in items(groups)
			call wheel#tree#add_circle (key)
			for location in localist
				call wheel#tree#add_location (location, 'norecord')
			endfor
		endfor
	endif
endfun

fun! wheel#group#menu()
	" Autogroup menu
	let prompt = 'Autogroup method ?'
	let method = confirm(prompt, "&Extension\n&Directory", 1)
	if method == 1
		call wheel#group#torus('extension')
	elseif method == 2
		call wheel#group#torus('directory')
	endif
endfun
