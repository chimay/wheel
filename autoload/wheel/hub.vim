" vim: ft=vim fdm=indent:

" Menus

fun! wheel#hub#alternate ()
	" Choose an alternate action
	let index = inputlist(['Alternate :',
				\ '1. Anywhere',
				\ '2. In same circle',
				\ '3. In same torus',
				\ '4. In other circle',
				\ '5. In other torus',
				\ '6. In same circle but other torus'
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
