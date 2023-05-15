" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Meta command, mappings

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

if exists('s:normal_plugs')
	unlockvar s:normal_plugs
endif
let s:normal_plugs = wheel#geode#fetch('plugs/normal')
lockvar s:normal_plugs

if exists('s:visual_plugs')
	unlockvar s:visual_plugs
endif
let s:visual_plugs = wheel#geode#fetch('plugs/visual')
lockvar s:visual_plugs

if exists('s:expr_plugs')
	unlockvar s:expr_plugs
endif
let s:expr_plugs = wheel#geode#fetch('plugs/expr')
lockvar s:expr_plugs

if exists('s:level_0_normal_maps')
	unlockvar s:level_0_normal_maps
endif
let s:level_0_normal_maps = wheel#geode#fetch('maps/level_0/normal')
lockvar s:level_0_normal_maps

if exists('s:level_1_normal_maps')
	unlockvar s:level_1_normal_maps
endif
let s:level_1_normal_maps = wheel#geode#fetch('maps/level_1/normal')
lockvar s:level_1_normal_maps

if exists('s:level_2_normal_maps')
	unlockvar s:level_2_normal_maps
endif
let s:level_2_normal_maps = wheel#geode#fetch('maps/level_2/normal')
lockvar s:level_2_normal_maps

if exists('s:level_2_visual_maps')
	unlockvar s:level_2_visual_maps
endif
let s:level_2_visual_maps = wheel#geode#fetch('maps/level_2/visual')
lockvar s:level_2_visual_maps

if exists('s:level_20_normal_maps')
	unlockvar s:level_20_normal_maps
endif
let s:level_20_normal_maps = wheel#geode#fetch('maps/level_20/normal')
lockvar s:level_20_normal_maps

" ---- commands

fun! wheel#centre#meta (subcommand, ...)
	" Function for meta command
	let subcommand = a:subcommand
	let arguments = a:000
	" ---- subcommands without argument
	if empty(arguments)
		let action_dict = wheel#matrix#items2dict(s:subcommands_actions)
		let action = action_dict[subcommand]
		if action ==# 'wheel#void#nope'
			echomsg 'Wheel centre meta-command : this action need a third argument'
			return v:false
		endif
		return wheel#metafun#call(action)
	endif
	" ---- prompt
	if subcommand ==# 'prompt'
		let action_dict = wheel#matrix#items2dict(s:prompt_actions)
		let subcom = arguments[0]
		let action = action_dict[subcom]
		return wheel#metafun#call(action)
	endif
	" ---- dedibuf
	if subcommand ==# 'dedibuf'
		let action_dict = wheel#matrix#items2dict(s:dedibuf_actions)
		let subcom = arguments[0]
		let action = action_dict[subcom]
		return wheel#metafun#call(action)
	endif
	" ---- other subcommand with argument(s)
	let action_dict = wheel#matrix#items2dict(s:subcommands_actions)
	let action = action_dict[subcommand]
	if subcommand ==# 'batch'
		let arguments = join(arguments)
		return call(action, [ arguments ])
	endif
	return call(action, arguments)
endfun

fun! wheel#centre#commands ()
	" Define commands
	" ---- meta command
	command! -nargs=* -complete=customlist,wheel#complete#meta_command
				\ Wheel call wheel#centre#meta(<f-args>)
endfun

" ---- plugs

fun! wheel#centre#plugs ()
	" Link <plug> mappings to wheel functions
	" ---- normal maps
	let begin = 'nnoremap <plug>('
	let middle = ') <cmd>call'
	let end = '<cr>'
	for item in s:normal_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right .. end
	endfor
	" ---- visual maps
	let begin = 'vnoremap <plug>('
	" use colon instead of <cmd> to catch the range
	let middle = ') :call'
	for item in s:visual_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right .. end
	endfor
	" ---- expr maps
	let begin = 'nnoremap <expr> <plug>('
	let middle = ')'
	for item in s:expr_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right
	endfor
endfun

" ---- maps

fun! wheel#centre#mappings (level, mode = 'normal')
	" Normal maps of level
	let level = a:level
	let mode = a:mode
	" ---- mode dependent variables
	if mode ==# 'normal'
		let mapcmd = 'nmap'
	elseif mode ==# 'visual'
		let mapcmd = 'vmap'
	endif
	let level_maps = s:level_{level}_{mode}_maps
	" ---- variables
	let prefix = g:wheel_config.prefix
	let begin = mapcmd .. ' <silent> ' .. prefix
	let middle = '<plug>('
	let end = ')'
	" ---- loop
	for item in level_maps
		let left = item[0]
		let right = item[1]
		execute begin .. left middle .. right .. end
	endfor
endfun

fun! wheel#centre#prefixless ()
	" Prefix-less maps
	let nmap = 'nmap <silent>'
	let vmap = 'vmap <silent>'
	" Menus
	execute nmap '<m-m>         <plug>(wheel-menu-main)'
	execute nmap '<m-=>         <plug>(wheel-menu-meta)'
	" Sync
	execute nmap '<m-i>         <plug>(wheel-info)'
	execute nmap '<m-$>         <plug>(wheel-sync-up)'
	execute nmap '<c-$>         <plug>(wheel-sync-down)'
	" ---- navigate in the wheel
	" --  next / previous
	execute nmap '<m-pageup>    <plug>(wheel-previous-location)'
	execute nmap '<m-pagedown>  <plug>(wheel-next-location)'
	execute nmap '<c-pageup>    <plug>(wheel-previous-circle)'
	execute nmap '<c-pagedown>  <plug>(wheel-next-circle)'
	execute nmap '<s-pageup>    <plug>(wheel-previous-torus)'
	execute nmap '<s-pagedown>  <plug>(wheel-next-torus)'
	" -- switch
	execute nmap '<m-cr>        <plug>(wheel-prompt-location)'
	execute nmap '<c-cr>        <plug>(wheel-prompt-circle)'
	execute nmap '<s-cr>        <plug>(wheel-prompt-torus)'
	execute nmap '<m-space>     <plug>(wheel-dedibuf-location)'
	execute nmap '<c-space>     <plug>(wheel-dedibuf-circle)'
	execute nmap '<s-space>     <plug>(wheel-dedibuf-torus)'
	" -- index
	execute nmap '<m-x>         <plug>(wheel-prompt-index)'
	execute nmap '<m-s-x>       <plug>(wheel-dedibuf-index)'
	execute nmap '<m-c-x>       <plug>(wheel-dedibuf-index-tree)'
	" -- history
	execute nmap '<m-home>      <plug>(wheel-history-newer)'
	execute nmap '<m-end>       <plug>(wheel-history-older)'
	execute nmap '<c-home>      <plug>(wheel-history-newer-in-circle)'
	execute nmap '<c-end>       <plug>(wheel-history-older-in-circle)'
	execute nmap '<s-home>      <plug>(wheel-history-newer-in-torus)'
	execute nmap '<s-end>       <plug>(wheel-history-older-in-torus)'
	execute nmap '<m-h>         <plug>(wheel-prompt-history)'
	execute nmap '<m-c-h>       <plug>(wheel-dedibuf-history)'
	" -- alternate
	execute nmap '<c-^>         <plug>(wheel-alternate-anywhere)'
	execute nmap '<m-^>         <plug>(wheel-alternate-same-circle)'
	execute nmap '<m-c-^>       <plug>(wheel-alternate-same-torus-other-circle)'
	" -- frecency
	execute nmap '<m-e>         <plug>(wheel-prompt-frecency)'
	execute nmap '<m-c-e>       <plug>(wheel-dedibuf-frecency)'
	" ---- navigate with vim native tools
	" -- buffers
	execute nmap '<m-b>          <plug>(wheel-prompt-buffer)'
	execute nmap '<m-c-b>        <plug>(wheel-dedibuf-buffer)'
	execute nmap '<m-s-b>        <plug>(wheel-dedibuf-buffer-all)'
	" -- tabs & windows : visible buffers
	execute nmap '<m-v>          <plug>(wheel-prompt-tabwin)'
	execute nmap '<m-c-v>        <plug>(wheel-dedibuf-tabwin-tree)'
	execute nmap '<m-s-v>        <plug>(wheel-dedibuf-tabwin)'
	" -- (neo)vim lists
	execute nmap "<m-'>          <plug>(wheel-prompt-marker)"
	execute nmap "<m-k>          <plug>(wheel-prompt-marker)"
	execute nmap '<m-j>          <plug>(wheel-prompt-jump)'
	execute nmap '<m-,>          <plug>(wheel-prompt-change)'
	execute nmap '<m-c>          <plug>(wheel-prompt-change)'
	execute nmap '<m-t>          <plug>(wheel-prompt-tag)'
	execute nmap "<m-c-k>        <plug>(wheel-dedibuf-marker)"
	execute nmap '<m-c-j>        <plug>(wheel-dedibuf-jump)'
	execute nmap '<m-;>          <plug>(wheel-dedibuf-change)'
	execute nmap '<m-c-t>        <plug>(wheel-dedibuf-tag)'
	" ---- organize the wheel
	execute nmap '<m-insert>     <plug>(wheel-prompt-add-here)'
	execute nmap '<m-del>        <plug>(wheel-prompt-delete-location)'
	execute nmap '<m-r>          <plug>(wheel-dedibuf-reorganize)'
	" ---- organize other things
	execute nmap '<m-c-r>        <plug>(wheel-dedibuf-reorg-tabwin)'
	" ---- refactoring
	execute nmap '<m-c-g>        <plug>(wheel-dedibuf-grep-edit)'
	execute nmap '<m-n>          <plug>(wheel-dedibuf-narrow-operator)'
	execute vmap '<m-n>          <plug>(wheel-dedibuf-narrow)'
	execute nmap '<m-c-n>        <plug>(wheel-dedibuf-narrow-circle)'
	" ---- search
	" -- files
	execute nmap '<m-f>          <plug>(wheel-prompt-find)'
	execute nmap '<m-c-f>        <plug>(wheel-dedibuf-find)'
	execute nmap '<m-c-&>        <plug>(wheel-dedibuf-async-find)'
	execute nmap '<m-u>          <plug>(wheel-prompt-mru)'
	execute nmap '<m-c-u>        <plug>(wheel-dedibuf-mru)'
	execute nmap '<m-l>          <plug>(wheel-dedibuf-locate)'
	" -- inside files
	execute nmap '<m-o>          <plug>(wheel-prompt-occur)'
	execute nmap '<m-c-o>        <plug>(wheel-dedibuf-occur)'
	execute nmap '<m-g>          <plug>(wheel-dedibuf-grep)'
	execute nmap '<m-s-o>        <plug>(wheel-prompt-outline)'
	execute nmap '<c-s-o>        <plug>(wheel-dedibuf-outline)'
	" ---- yank ring
	execute nmap '<m-y>          <plug>(wheel-prompt-yank-plain-linewise-after)'
	execute nmap '<m-p>          <plug>(wheel-prompt-yank-plain-charwise-after)'
	execute nmap '<m-s-y>        <plug>(wheel-prompt-yank-plain-linewise-before)'
	execute nmap '<m-s-p>        <plug>(wheel-prompt-yank-plain-charwise-before)'
	execute nmap '<m-c-y>        <plug>(wheel-dedibuf-yank-plain)'
	execute nmap '<m-c-p>        <plug>(wheel-dedibuf-yank-list)'
	" ---- undo list
	execute nmap '<m-s-u>        <plug>(wheel-dedibuf-undo-list)'
	" ---- ex or shell command output
	execute nmap '<m-!>          <plug>(wheel-dedibuf-command)'
	execute nmap '<m-&>          <plug>(wheel-dedibuf-async)'
	" ---- dedicated buffers
	execute nmap '<m-tab>        <plug>(wheel-mandala-add)'
	execute nmap '<m-backspace>  <plug>(wheel-mandala-delete)'
	execute nmap '<m-left>       <plug>(wheel-mandala-backward)'
	execute nmap '<m-right>      <plug>(wheel-mandala-forward)'
	execute nmap '<c-up>         <plug>(wheel-mandala-switch)'
	" ---- layouts
	execute nmap '<m-z>          <plug>(wheel-zoom)'
endfun

" ---- link plugs & maps

fun! wheel#centre#cables ()
	" Link keys to <plug> mappings
	" ---- basic
	if g:wheel_config.mappings >= 0
		call wheel#centre#mappings (0)
	endif
	" ---- common
	if g:wheel_config.mappings >= 1
		call wheel#centre#mappings (1)
	endif
	" ---- advanced
	if g:wheel_config.mappings >= 2
		call wheel#centre#mappings (2)
		call wheel#centre#mappings (2, 'visual')
	endif
	" ---- without prefix
	if g:wheel_config.mappings >= 10
		call wheel#centre#prefixless ()
	endif
	" ---- debug
	if g:wheel_config.mappings >= 20
		call wheel#centre#mappings (20)
	endif
endfun
