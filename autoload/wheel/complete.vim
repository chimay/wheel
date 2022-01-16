" vim: set ft=vim fdm=indent iskeyword&:

" Completion list functions
"
" Return entries as list
" vim does not filter the entries,
" if needed, it has to be done
" in the function body

" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:is_buffer_tabs')
	let s:is_buffer_tabs = wheel#crystal#fetch('is_buffer/tabs')
	lockvar s:is_buffer_tabs
endif

if ! exists('s:is_mandala_tabs')
	let s:is_mandala_tabs = wheel#crystal#fetch('is_mandala/tabs')
	lockvar s:is_mandala_tabs
endif

" empty

fun! wheel#complete#empty (arglead, cmdline, cursorpos)
	return []
endfun

" wheel

fun! wheel#complete#torus (arglead, cmdline, cursorpos)
	" Complete torus name
	if ! has_key(g:wheel, 'glossary')
		return []
	endif
	let toruses = copy(g:wheel.glossary)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, toruses)
endfu

fun! wheel#complete#circle (arglead, cmdline, cursorpos)
	" Complete circle name
	let cur_torus = wheel#referen#torus ()
	if ! has_key(cur_torus, 'glossary')
		return []
	endif
	let circles = copy(cur_torus.glossary)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, circles)
endfu

fun! wheel#complete#location (arglead, cmdline, cursorpos)
	" Complete location name
	let cur_circle = wheel#referen#circle ()
	if ! has_key(cur_circle, 'glossary')
		return []
	endif
	let locations = copy(cur_circle.glossary)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, locations)
endfu

fun! wheel#complete#helix (arglead, cmdline, cursorpos)
	" Complete coordinates in index
	let choices = wheel#perspective#helix ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfu

fun! wheel#complete#grid  (arglead, cmdline, cursorpos)
	" Complete location coordinates in index
	let choices = wheel#perspective#grid ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

fun! wheel#complete#history (arglead, cmdline, cursorpos)
	" Complete coordinates in history
	let choices = wheel#perspective#history ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfu

" mandalas = dedicated buffers

fun! wheel#complete#mandala (arglead, cmdline, cursorpos)
	" Complete mandala buffer name
	let bufnums = g:wheel_mandalas.ring
	if empty(bufnums)
		return []
	endif
	let choices = []
	for index in range(len(bufnums))
		let num = bufnums[index]
		let title = bufname(num)
		call add(choices, title)
	endfor
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

" leaves = mandala layers, implemented as a ring

fun! wheel#complete#leaf (arglead, cmdline, cursorpos)
	" Complete leaf type
	let filenames = wheel#book#ring ('filename')
	if empty(filenames)
		return []
	endif
	let Fun = function('wheel#status#type')
	let choices = map(copy(filenames), { _, val -> Fun(val) })
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

" files & dirs

fun! wheel#complete#file (arglead, cmdline, cursorpos)
	" Complete with file name
	" -- get tree of files & directories
	let tree = glob('**', v:false, v:true)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, tree)
endfun

fun! wheel#complete#directory (arglead, cmdline, cursorpos)
	" Complete with directory name
	let tree = wheel#complete#file (a:arglead, a:cmdline, a:cursorpos)
	call filter(tree, {_,v -> isdirectory(v)})
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, tree)
endfun

fun! wheel#complete#current_file (arglead, cmdline, cursorpos)
	" Complete different flavours or current filename
	let basis = expand('%:p')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" flavours
	let root = fnamemodify(basis, ':t:r')
	let simple = fnamemodify(basis, ':t')
	let relative = wheel#gear#relative_path(basis)
	let absolute = basis
	let filenames = [root, simple, relative, absolute]
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, filenames)
endfun

fun! wheel#complete#current_directory (arglead, cmdline, cursorpos)
	" Complete different flavours or current file directory
	let basis = expand('%:p:h')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" flavours
	let simple = fnamemodify(basis, ':t')
	let relative = wheel#gear#relative_path(basis)
	let absolute = basis
	let directories = [simple, relative, absolute]
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, directories)
endfun

fun! wheel#complete#link_copy (arglead, cmdline, cursorpos)
	" Complete command to generate tree reflecting wheel in filesystem
	" Link or copy
	" See also wheel#disc#tree_script
	let commands = ['ln -s', 'cp -n']
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, commands)
endfun

" mru non wheel files

fun! wheel#complete#mru (arglead, cmdline, cursorpos)
	" Complete mru file
	let files = wheel#perspective#mru ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, files)
endfun

" buffers

fun! wheel#complete#buffer (arglead, cmdline, cursorpos)
	" Complete with buffer name
	let choices = wheel#perspective#buffers ('all')
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

fun! wheel#complete#visible_buffer (arglead, cmdline, cursorpos)
	" Complete buffer visible in tabs & windows
	let choices = wheel#perspective#tabwins ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

" buffer lines

fun! wheel#complete#line (arglead, cmdline, cursorpos)
	" Complete buffer line
	let linelist = getline(1,'$')
	eval linelist->map({ ind, val -> string(ind + 1) .. s:field_separ .. val })
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, linelist)
endfun

" vim lists

fun! wheel#complete#marker (arglead, cmdline, cursorpos)
	" Complete marker
	let choices = wheel#perspective#markers ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

fun! wheel#complete#jump (arglead, cmdline, cursorpos)
	" Complete jump
	let choices = wheel#perspective#jumps ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

fun! wheel#complete#change (arglead, cmdline, cursorpos)
	" Complete change
	let choices = wheel#perspective#changes ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun

fun! wheel#complete#tag (arglead, cmdline, cursorpos)
	" Complete tag
	let table = wheel#symbol#table ()
	let choices = []
	for fields in table
		let iden = fields[0]
		let filename = fields[1]
		let search = fields[2]
		let type = fields[3]
		let iden = printf('%5s', iden)
		let type = printf('%2s', type)
		let entry = [iden, filename, search, type]
		let record = join(entry, s:field_separ)
		call add(choices, record)
	endfor
	let wordlist = split(a:cmdline)
	return wheel#kyusu#candidates(wordlist, choices)
endfun
