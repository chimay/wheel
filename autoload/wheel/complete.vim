" vim: set ft=vim fdm=indent iskeyword&:

" Complete
"
" Completion list functions

" Return entries as list
"
" vim does not filter the entries,
" if needed, it has to be done
" in the function body
"
" Note : kyusu#pour makes a deepcopy of the list before
" processing, no need to do it here

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:registers_symbols')
	let s:registers_symbols = wheel#crystal#fetch('registers-symbols')
	lockvar s:registers_symbols
endif

" ---- empty

fun! wheel#complete#empty (arglead, cmdline, cursorpos)
	return []
endfun

" ---- wheel

fun! wheel#complete#torus (arglead, cmdline, cursorpos)
	" Complete torus name
	if ! has_key(g:wheel, 'glossary')
		return []
	endif
	let toruses = g:wheel.glossary
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, toruses)
endfun

fun! wheel#complete#circle (arglead, cmdline, cursorpos)
	" Complete circle name
	let cur_torus = wheel#referen#torus ()
	if ! has_key(cur_torus, 'glossary')
		return []
	endif
	let circles = cur_torus.glossary
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, circles)
endfun

fun! wheel#complete#location (arglead, cmdline, cursorpos)
	" Complete location name
	let cur_circle = wheel#referen#circle ()
	if ! has_key(cur_circle, 'glossary')
		return []
	endif
	let locations = cur_circle.glossary
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, locations)
endfun

fun! wheel#complete#helix (arglead, cmdline, cursorpos)
	" Complete coordinates in index
	let choices = wheel#perspective#helix ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#grid  (arglead, cmdline, cursorpos)
	" Complete location coordinates in index
	let choices = wheel#perspective#grid ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#history (arglead, cmdline, cursorpos)
	" Complete coordinates in history timeline
	let choices = wheel#perspective#history ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#history_circuit (arglead, cmdline, cursorpos)
	" Complete coordinates in history circuit
	let choices = wheel#perspective#history_circuit ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#frecency (arglead, cmdline, cursorpos)
	" Complete coordinates in history timeline
	let choices = wheel#perspective#frecency ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

" ---- mandalas = dedicated buffers

fun! wheel#complete#mandala (arglead, cmdline, cursorpos)
	" Complete mandala buffer name
	let bufring = g:wheel_bufring
	let names = bufring.names
	let types = bufring.types
	if empty(names)
		return []
	endif
	let choices = []
	for index in wheel#chain#rangelen(names)
		let title = names[index] .. s:field_separ .. types[index]
		eval choices->add(title)
	endfor
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

" ---- leaves = mandala layers, implemented as a ring

fun! wheel#complete#leaf (arglead, cmdline, cursorpos)
	" Complete leaf type
	let forest = copy( wheel#book#ring ('nature') )
	if empty(forest)
		return []
	endif
	let choices = map(forest, { ind, val -> ind .. s:field_separ .. val.type })
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

" ---- files & dirs

fun! wheel#complete#file (arglead, cmdline, cursorpos)
	" Complete with file name
	" -- get tree of files & directories
	let tree = glob('**', v:false, v:true)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, tree)
endfun

fun! wheel#complete#directory (arglead, cmdline, cursorpos)
	" Complete with directory name
	let tree = wheel#complete#file (a:arglead, a:cmdline, a:cursorpos)
	eval tree->filter({ _, val -> isdirectory(val) })
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, tree)
endfun

fun! wheel#complete#current_file (arglead, cmdline, cursorpos)
	" Complete different flavours or current filename
	let basis = expand('%:p')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" flavours
	let root = fnamemodify(basis, ':t:r')
	let simple = fnamemodify(basis, ':t')
	let relative = wheel#disc#relative_path(basis)
	let absolute = basis
	let filenames = [root, simple, relative, absolute]
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, filenames)
endfun

fun! wheel#complete#current_directory (arglead, cmdline, cursorpos)
	" Complete different flavours or current file directory
	let basis = expand('%:p:h')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" flavours
	let simple = fnamemodify(basis, ':t')
	let relative = wheel#disc#relative_path(basis)
	let absolute = basis
	let directories = [simple, relative, absolute]
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, directories)
endfun

fun! wheel#complete#link_copy (arglead, cmdline, cursorpos)
	" Complete command to generate tree reflecting wheel in filesystem
	" Link or copy
	" See also wheel#disc#tree_script
	let commands = ['ln -s', 'cp -n']
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, commands)
endfun

" ---- mru non wheel files

fun! wheel#complete#mru (arglead, cmdline, cursorpos)
	" Complete mru file
	let files = wheel#perspective#mru ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, files)
endfun

" ---- buffers

fun! wheel#complete#buffer (arglead, cmdline, cursorpos)
	" Complete with buffer name
	let choices = wheel#perspective#buffer ('all')
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#visible_buffer (arglead, cmdline, cursorpos)
	" Complete buffer visible in tabs & windows
	let choices = wheel#perspective#tabwin ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

" ---- buffer lines

fun! wheel#complete#line (arglead, cmdline, cursorpos)
	" Complete buffer line
	let linelist = getline(1,'$')
	eval linelist->map({ ind, val -> string(ind + 1) .. s:field_separ .. val })
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, linelist)
endfun

" ---- vim lists

fun! wheel#complete#marker (arglead, cmdline, cursorpos)
	" Complete marker
	let choices = wheel#perspective#marker ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#jump (arglead, cmdline, cursorpos)
	" Complete jump
	let choices = wheel#perspective#jump ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#change (arglead, cmdline, cursorpos)
	" Complete change
	let choices = wheel#perspective#change ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
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
		eval choices->add(record)
	endfor
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

" ---- yank ring

fun! wheel#complete#register (arglead, cmdline, cursorpos)
	" Complete register name
	let choices = wheel#matrix#items2keys(s:registers_symbols)
	eval choices->add('overview')
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#yank_list (arglead, cmdline, cursorpos)
	" Complete yank from yank ring in list mode
	let register = g:wheel_shelve.yank.default_register
	let choices = wheel#perspective#yank ('list', register)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

fun! wheel#complete#yank_plain (arglead, cmdline, cursorpos)
	" Complete yank from yank ring in plain mode
	let register = g:wheel_shelve.yank.default_register
	let choices = wheel#perspective#yank ('plain', register)
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun
