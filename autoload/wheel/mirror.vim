" vim: set ft=vim fdm=indent iskeyword&:

" Mirror
"
" Refactoring, dedicated buffers

" script constants

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

" ---- grep edit

fun! wheel#mirror#grep_edit (...)
	" Grep in edit mode
	" ---- arguments
	if a:0 > 0
		let pattern = a:1
	else
		if wheel#boomerang#is_context_menu ()
			let settings = wheel#book#previous ('settings')
			let pattern = settings.pattern
		else
			let pattern = input('Grep circle files for pattern [edit mode] : ')
		endif
	endif
	if a:0 > 1
		let sieve = a:2
	else
		if wheel#boomerang#is_context_menu ()
			let settings = wheel#book#previous ('settings')
			let sieve = settings.sieve
		else
			let sieve = '\m.'
		endif
	endif
	" ---- lines
	let lines = wheel#perspective#grep (pattern, sieve)
	" ---- pre-checks
	if empty(lines)
		echomsg 'wheel shape grep edit : no match found'
		return v:false
	endif
	" ---- mandala
	call wheel#mandala#blank ('grep/edit')
	call wheel#mandala#common_maps ()
	call wheel#polyphony#temple ()
	call wheel#harmony#write ('wheel#harmony#grep_edit')
	call wheel#mandala#fill (lines)
	" ---- reload
	let b:wheel_reload = "wheel#mirror#grep_edit('" .. pattern .. "', '" .. sieve .. "')"
	" ---- coda
	echomsg 'adding or removing lines is not supported'
	return lines
endfun

" ---- narrow

" -- operator

fun! wheel#mirror#operator (argument = '')
	" Operator waiting for a movement or text object to select range
	" Use in a map like this :
	"   map <expr> <mykey> wheel#mirror#operator()
	let argument = a:argument
	" -- when called to find the rhs of the map
	if argument == ''
		set operatorfunc=wheel#mirror#operator
		return 'g@'
	endif
	" -- when called to execute wheel#mirror#operator
	" -- then, argument is 'line', 'block' or 'char'
	let first = line("'[")
	let last = line("']")
	call wheel#mirror#narrow_file (first, last)
endfun

" -- mandalas

fun! wheel#mirror#narrow_file (...) range
	" Lines matching pattern in current file
	call wheel#mandala#goto_related ()
	" 0 or 2 optional arguments
	if a:0 > 1
		let first = a:1
		let last = a:2
	else
		let first = a:firstline
		let last = a:lastline
	endif
	if first == last
		" assume the user does not launch it just for one line
		let range = input('Range of line to narrow ? ')
		if empty(range)
			let rangelist = [1, line('$')]
		endif
		for separ in [',', ';', ':', '-', ' ']
			if range =~ separ
				let rangelist = split(range, separ)
				break
			endif
		endfor
		let first = str2nr(rangelist[0])
		let last = str2nr(rangelist[1])
	endif
	" -- lines
	let lines = wheel#perspective#narrow_file (first, last)
	" -- pre op buffer
	let bufnum = bufnr('%')
	let filename = bufname(bufnum)
	let filename = fnamemodify(filename, ':t')
	let filetype = getbufvar(bufnum, '&filetype')
	" -- mandala
	call wheel#mandala#blank ('narrow/file/' .. filename)
	let &l:filetype = filetype
	call wheel#mandala#common_maps ()
	let settings = #{
				\ function : 'wheel#line#narrow_file',
				\ bufnum : b:wheel_related_buffer
				\ }
	call wheel#polyphony#template (settings)
	call wheel#polyphony#action_maps ('file')
	call wheel#harmony#write ('wheel#harmony#narrow_file')
	call wheel#mandala#fill (lines)
	" -- settings
	let b:wheel_settings = settings
	" -- reload
	let b:wheel_reload = "wheel#mirror#narrow_file('" .. first .. "', '" .. last .. "')"
endfun

fun! wheel#mirror#narrow_circle (...)
	" Lines matching pattern in all circle files
	" Like grep but with filter & edit
	if a:0 > 0
		let pattern = a:1
	else
		let pattern = input('Narrow circle files with pattern : ')
	endif
	if a:0 > 1
		let sieve = a:2
	else
		let sieve = '\m.'
	endif
	" -- lines
	let lines = wheel#perspective#narrow_circle (pattern, sieve)
	" -- pre-checks
	if empty(lines)
		echomsg 'wheel narrow circle : no match found'
		return v:false
	endif
	" -- mandala
	let word = substitute(pattern, '\W.*', '', '')
	call wheel#mandala#blank ('narrow/circle/' .. word)
	call wheel#mandala#common_maps ()
	let settings = #{ function : 'wheel#line#narrow_circle' }
	call wheel#polyphony#template (settings)
	call wheel#polyphony#action_maps ('circle')
	call wheel#harmony#write ('wheel#harmony#narrow_circle')
	call wheel#mandala#fill (lines)
	" -- settings
	let b:wheel_settings = settings
	" -- reload
	let b:wheel_reload = "wheel#mirror#narrow_circle('" .. pattern .. "', '" .. sieve .. "')"
	echomsg 'adding or removing lines is not supported'
endfun
