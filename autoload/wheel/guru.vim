" vim: set ft=vim fdm=indent iskeyword&:

" Guru
"
" Help

" ---- script constants

if exists('s:subcommands_actions')
	unlockvar s:subcommands_actions
endif
let s:subcommands_actions = wheel#diadem#fetch('command/meta/actions')
lockvar s:subcommands_actions

if exists('s:prompt_actions')
	unlockvar s:prompt_actions
endif
let s:prompt_actions = wheel#diadem#fetch('command/meta/prompt/actions')
lockvar s:prompt_actions

if exists('s:dedibuf_actions')
	unlockvar s:dedibuf_actions
endif
let s:dedibuf_actions = wheel#diadem#fetch('command/meta/dedibuf/actions')
lockvar s:dedibuf_actions

if exists('s:file_subcommands')
	unlockvar s:file_subcommands
endif
let s:file_subcommands = wheel#diadem#fetch('command/meta/subcommands/file')
lockvar s:file_subcommands

" ---- help helpers

fun! wheel#guru#execute_current_line ()
	" Execute current line content
	let line = getline('.')
	if line =~ '<.*>'
		return v:false
	endif
	execute line
	return v:true
endfun

" ---- general help

fun! wheel#guru#help ()
	" Inline help
	tab help wheel.txt
endfun

fun! wheel#guru#mappings ()
	" List of mappings in a dedicated buffer
	let prefix = g:wheel_config.prefix
	let command = 'map ' .. prefix
	call wheel#mandala#command (command)
endfun

fun! wheel#guru#plugs ()
	" List of plugs mappings in a dedicated buffer
	call wheel#mandala#command ('map <plug>(wheel-')
endfun

fun! wheel#guru#autocommands ()
	" List of wheel autocommands in a dedicated buffer
	let group = input('Name of your wheel autocommand group ? ', 'wheel')
	let command = 'autocmd ' .. group
	call wheel#mandala#command (command)
endfun

fun! wheel#guru#meta_command ()
	" List of available subcommands for meta command
	let subcommands = wheel#matrix#items2keys(s:subcommands_actions)
	let lines = []
	for subcmd in subcommands
		if subcmd ==# 'prompt'
			let actions = wheel#matrix#items2keys(s:prompt_actions)
			for iter in actions
				let command = 'Wheel ' .. subcmd .. ' ' .. iter
				eval lines->add(command)
			endfor
			continue
		endif
		if subcmd ==# 'dedibuf'
			let actions = wheel#matrix#items2keys(s:dedibuf_actions)
			for iter in actions
				let command = 'Wheel ' .. subcmd .. ' ' .. iter
				eval lines->add(command)
			endfor
			continue
		endif
		if subcmd ==# 'mkdir'
			let command = 'Wheel ' .. subcmd .. ' <directory>'
		elseif subcmd ==# 'delete'
			let command = 'Wheel ' .. subcmd .. ' <file>'
		elseif subcmd->wheel#chain#is_inside(s:file_subcommands)
			let command = 'Wheel ' .. subcmd .. ' <source> <destination>'
		else
			let command = 'Wheel ' .. subcmd
		endif
		eval lines->add(command)
	endfor
	" ---- mandala
	call wheel#mandala#blank ('meta-command')
	call wheel#mandala#template ()
	call wheel#mandala#fill (lines)
	" --- map to execute current line
	nnoremap <buffer> <cr> <cmd>call wheel#guru#execute_current_line()<cr>
endfun

" ---- mandala local help

fun! wheel#guru#mandala ()
	" Basic help of a dedicated buffer
	echomsg 'q : quit                   | r : reload           | <M-n> : relabel buffer'
	echomsg '<M-k> : previous layer     | <M-l> : switch layer | <M-j> : next layer'
	echomsg '<Backspace> : delete layer | <F1> : this help     | <F2>  : local maps'
endfun

fun! wheel#guru#mandala_mappings ()
	" Local maps in a dedicated buffer
	call wheel#cylinder#recall ()
	let command = 'map <buffer>'
	call wheel#mandala#command (command)
endfun
