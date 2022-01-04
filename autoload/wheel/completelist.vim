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

fun! wheel#completelist#empty (arglead, cmdline, cursorpos)
	return []
endfun

" wheel

fun! wheel#completelist#torus (arglead, cmdline, cursorpos)
	" Complete torus name
	if ! has_key(g:wheel, 'glossary')
		return []
	endif
	let toruses = copy(g:wheel.glossary)
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(toruses, Matches)
	return candidates
endfu

fun! wheel#completelist#circle (arglead, cmdline, cursorpos)
	" Complete circle name
	let cur_torus = wheel#referen#torus ()
	if ! has_key(cur_torus, 'glossary')
		return []
	endif
	let circles =  copy(cur_torus.glossary)
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(circles, Matches)
	return candidates
endfu

fun! wheel#completelist#location (arglead, cmdline, cursorpos)
	" Complete location name
	let cur_circle = wheel#referen#circle ()
	if ! has_key(cur_circle, 'glossary')
		return []
	endif
	let locations = copy(cur_circle.glossary)
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(locations, Matches)
	return candidates
endfu

fun! wheel#completelist#helix (arglead, cmdline, cursorpos)
	" Complete location coordinates in index
	let helix = wheel#helix#helix ()
	let choices = []
	for coordin in helix
		let entry = join(coordin, s:level_separ)
		let choices = add(choices, entry)
	endfor
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(choices, Matches)
	return candidates
endfu

" mandalas

fun! wheel#completelist#layer (arglead, cmdline, cursorpos)
	" Return layer types
	" layers types
	let filenames = wheel#layer#stack ('filename')
	if empty(filenames)
		return []
	endif
	let Fun = function('wheel#mandala#type')
	let types = map(copy(filenames), {_,v->Fun(v)})
	" current mandala type
	let title = wheel#mandala#type ()
	let top = b:wheel_stack.top
	call insert(types, title, top)
	" reverse to have previous on the left and next on the right
	call reverse(types)
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(types, Matches)
	return candidates
endfun

fun! wheel#completelist#mandala (arglead, cmdline, cursorpos)
	" Return mandala buffers names
	let bufnums = g:wheel_mandalas.stack
	if empty(bufnums)
		return []
	endif
	let types = []
	for index in range(len(bufnums))
		let num = bufnums[index]
		let title = bufname(num)
		call add(types, title)
	endfor
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(types, Matches)
	return candidates
endfun

" buffers

fun! wheel#completelist#visible_buffers (arglead, cmdline, cursorpos)
	" Return list of buffers visible in tabs & windows
	let lines = []
	let tabnum = 'undefined'
	let tabs = execute('tabs')
	let tabs = split(tabs, "\n")
	let length = len(tabs)
	let isbuffer = s:is_buffer_tabs
	let iswheel = s:is_mandala_tabs
	for index in range(length)
		let elem = tabs[index]
		let fields = split(elem)
		if elem !~ isbuffer
			" tab line
			let tabnum = fields[-1]
			let winum = 0
		elseif elem !~ iswheel
			" buffer line
			let winum += 1
			let filename = fnamemodify(fields[-1], ':p')
			let entry = [filename, tabnum, winum]
			let record = join(entry, s:field_separ)
			call add(lines, record)
		endif
	endfor
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(lines, Matches)
	return candidates
endfun

" files & dirs

fun! wheel#completelist#file (arglead, cmdline, cursorpos)
	" Complete with file name
	" -- get tree of files & directories
	" also works, but the doc says otherwise
	let tree = glob('**', v:false, v:true)
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(tree, Matches)
	return candidates
endfun

fun! wheel#completelist#directory (arglead, cmdline, cursorpos)
	" Complete with directory name
	let candidates = wheel#completelist#file (a:arglead, a:cmdline, a:cursorpos)
	call filter(candidates, {_,v -> isdirectory(v)})
	return candidates
endfun

fun! wheel#completelist#current_file (arglead, cmdline, cursorpos)
	" Complete different flavours or current filename
	let basis = expand('%')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" relative path
	let cwd = getcwd() . '/'
	let relative = substitute(basis, cwd, '', '')
	" abolute path
	let absolute = fnamemodify(basis, ':p')
	let simple = fnamemodify(basis, ':t')
	let root = fnamemodify(basis, ':t:r')
	let filenames = [root, simple, relative, absolute]
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(filenames, Matches)
	return candidates
endfun

fun! wheel#completelist#current_directory (arglead, cmdline, cursorpos)
	" Complete different flavours or current file directory
	let basis = expand('%:h')
	" replace spaces par non-breaking spaces
	let basis = substitute(basis, ' ', ' ', 'g')
	" relative path
	let cwd = getcwd() . '/'
	let relative = substitute(basis, cwd, '', '')
	" abolute path
	let absolute = fnamemodify(basis, ':p')
	let simple = fnamemodify(basis, ':t')
	let directories = [simple, relative, absolute]
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(directories, Matches)
	return candidates
endfun

fun! wheel#completelist#link_copy (arglead, cmdline, cursorpos)
	" Complete command to generate tree reflecting wheel in filesystem
	" Link or copy
	" See also wheel#disc#tree_script
	let commands = ['ln -s', 'cp -n']
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(commands, Matches)
	return candidates
endfun

" tags

fun! wheel#completelist#tags (arglead, cmdline, cursorpos)
	let table = wheel#symbol#table ()
	let choices = []
	for record in table
		let suit = join(record, s:field_separ)
		call add(choices, suit)
	endfor
	let wordlist = split(a:cmdline)
	let Matches = function('wheel#kyusu#word', [wordlist])
	let candidates = filter(choices, Matches)
	return candidates
endfun
