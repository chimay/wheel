" vim: ft=vim fdm=indent:

" Menus

" Inputlist

fun! wheel#hub#add ()
	" Choose an object to add
	let index = inputlist(
				\ [
				\ 'Add :',
				\ '1. Location at cursor',
				\ '2. File',
				\ '3. Buffer'
				\ ])
	if index == 1
		call wheel#tree#add_here ()
	elseif index == 2
		call wheel#tree#add_file ()
	elseif index == 3
		call wheel#tree#add_buffer ()
	else
		echomsg 'Choice must be between 1 and 3'
	endif
	return index
endfun

fun! wheel#hub#alternate ()
	" Choose a way to alternate
	let index = inputlist(
				\ [
				\ 'Alternate :',
				\ '1. Anywhere',
				\ '2. In same circle',
				\ '3. In same torus',
				\ '4. In other circle',
				\ '5. In other torus',
				\ '6. In same torus but other circle'
				\ ])
	if index == 1
		call wheel#pendulum#alternate ()
	elseif index == 2
		call wheel#pendulum#alternate_same_circle ()
	elseif index == 3
		call wheel#pendulum#alternate_same_torus ()
	elseif index == 4
		call wheel#pendulum#alternate_other_circle ()
	elseif index == 5
		call wheel#pendulum#alternate_other_torus ()
	elseif index == 6
		call wheel#pendulum#alternate_same_torus_other_circle ()
	else
		echomsg 'Choice must be between 1 and 6'
	endif
	return index
endfun

" Mandala

fun! wheel#hub#meta ()
endfun

fun! wheel#hub#choose ()
endfun

fun! wheel#hub#reorder ()
endfun
