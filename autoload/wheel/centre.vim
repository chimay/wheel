" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Meta command, mappings

" ---- script constants

if ! exists('s:subcommands_actions')
	let s:subcommands_actions = wheel#pearl#fetch('command/meta/actions')
	lockvar s:subcommands_actions
endif

if ! exists('s:prompt_actions')
	let s:prompt_actions = wheel#pearl#fetch('command/meta/prompt/actions')
	lockvar s:prompt_actions
endif

if ! exists('s:dedibuf_actions')
	let s:dedibuf_actions = wheel#pearl#fetch('command/meta/dedibuf/actions')
	lockvar s:dedibuf_actions
endif

if ! exists('s:normal_plugs')
	let s:normal_plugs = wheel#geode#fetch('plugs/normal')
	lockvar s:normal_plugs
endif

if ! exists('s:visual_plugs')
	let s:visual_plugs = wheel#geode#fetch('plugs/visual')
	lockvar s:visual_plugs
endif

if ! exists('s:expr_plugs')
	let s:expr_plugs = wheel#geode#fetch('plugs/expr')
	lockvar s:expr_plugs
endif

if ! exists('s:level_0_normal_maps')
	let s:level_0_normal_maps = wheel#geode#fetch('maps/level_0/normal')
	lockvar s:level_0_normal_maps
endif

if ! exists('s:level_1_normal_maps')
	let s:level_1_normal_maps = wheel#geode#fetch('maps/level_1/normal')
	lockvar s:level_1_normal_maps
endif

if ! exists('s:level_2_normal_maps')
	let s:level_2_normal_maps = wheel#geode#fetch('maps/level_2/normal')
	lockvar s:level_2_normal_maps
endif

if ! exists('s:level_2_visual_maps')
	let s:level_2_visual_maps = wheel#geode#fetch('maps/level_2/visual')
	lockvar s:level_2_visual_maps
endif

if ! exists('s:level_20_normal_maps')
	let s:level_20_normal_maps = wheel#geode#fetch('maps/level_20/normal')
	lockvar s:level_20_normal_maps
endif

" ---- commands

fun! wheel#centre#meta (subcommand, ...)
	" Function for meta command
	let subcommand = a:subcommand
	let arguments = a:000
	" ---- prompt
	if subcommand ==# 'prompt'
		let action_dict = wheel#matrix#items2dict(s:prompt_actions)
		let subcom = arguments[0]
		let action = action_dict[subcom]
		return eval(action)
	endif
	" ---- dedibuf
	if subcommand ==# 'dedibuf'
		let action_dict = wheel#matrix#items2dict(s:dedibuf_actions)
		let subcom = arguments[0]
		let action = action_dict[subcom]
		return eval(action)
	endif
	" ---- others actions
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

" ---- maps

fun! wheel#centre#plugs ()
	" Link <plug> mappings to wheel functions
	" ---- normal maps
	let begin = 'nnoremap <plug>('
	let middle = ') <cmd>call'
	let end = '<cr>'
	for item in s:normal_plugs
		let left = item[0]
		let right = item[1]
		exe begin .. left .. middle right .. end
	endfor
	" ---- visual maps
	let begin = 'vnoremap <plug>('
	" use colon instead of <cmd> to catch the range
	let middle = ') :call'
	for item in s:visual_plugs
		let left = item[0]
		let right = item[1]
		exe begin .. left .. middle right .. end
	endfor
	" ---- expr maps
	let begin = 'nnoremap <expr> <plug>('
	let middle = ')'
	for item in s:expr_plugs
		let left = item[0]
		let right = item[1]
		execute begin .. left .. middle right
	endfor
endfun

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
	" ---- vars
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
	exe nmap '<m-m>         <plug>(wheel-menu-main)'
	exe nmap '<m-=>         <plug>(wheel-menu-meta)'
	" Sync
	exe nmap '<m-i>         <plug>(wheel-dashboard)'
	exe nmap '<m-$>         <plug>(wheel-sync-up)'
	exe nmap '<c-$>         <plug>(wheel-sync-down)'
	" ---- navigate in the wheel
	" --  next / previous
	exe nmap '<m-pageup>    <plug>(wheel-previous-location)'
	exe nmap '<m-pagedown>  <plug>(wheel-next-location)'
	exe nmap '<c-pageup>    <plug>(wheel-previous-circle)'
	exe nmap '<c-pagedown>  <plug>(wheel-next-circle)'
	exe nmap '<s-pageup>    <plug>(wheel-previous-torus)'
	exe nmap '<s-pagedown>  <plug>(wheel-next-torus)'
	" -- switch
	exe nmap '<m-cr>        <plug>(wheel-prompt-location)'
	exe nmap '<c-cr>        <plug>(wheel-prompt-circle)'
	exe nmap '<s-cr>        <plug>(wheel-prompt-torus)'
	exe nmap '<m-space>     <plug>(wheel-dedibuf-location)'
	exe nmap '<c-space>     <plug>(wheel-dedibuf-circle)'
	exe nmap '<s-space>     <plug>(wheel-dedibuf-torus)'
	" -- index
	exe nmap '<m-x>         <plug>(wheel-prompt-index)'
	exe nmap '<m-s-x>       <plug>(wheel-dedibuf-index)'
	exe nmap '<m-c-x>       <plug>(wheel-dedibuf-index-tree)'
	" -- history
	exe nmap '<m-home>      <plug>(wheel-history-newer)'
	exe nmap '<m-end>       <plug>(wheel-history-older)'
	exe nmap '<c-home>      <plug>(wheel-history-newer-in-circle)'
	exe nmap '<c-end>       <plug>(wheel-history-older-in-circle)'
	exe nmap '<s-home>      <plug>(wheel-history-newer-in-torus)'
	exe nmap '<s-end>       <plug>(wheel-history-older-in-torus)'
	exe nmap '<m-h>         <plug>(wheel-prompt-history)'
	exe nmap '<m-c-h>       <plug>(wheel-dedibuf-history)'
	" -- alternate
	exe nmap '<c-^>         <plug>(wheel-alternate-anywhere)'
	exe nmap '<m-^>         <plug>(wheel-alternate-same-circle)'
	exe nmap '<m-c-^>       <plug>(wheel-alternate-same-torus-other-circle)'
	" -- frecency
	exe nmap '<m-e>         <plug>(wheel-prompt-frecency)'
	exe nmap '<m-c-e>       <plug>(wheel-dedibuf-frecency)'
	" ---- navigate with vim native tools
	" -- buffers
	exe nmap '<m-b>          <plug>(wheel-prompt-buffer)'
	exe nmap '<m-c-b>        <plug>(wheel-dedibuf-buffer)'
	exe nmap '<m-s-b>        <plug>(wheel-dedibuf-buffer-all)'
	" -- tabs & windows : visible buffers
	exe nmap '<m-v>          <plug>(wheel-prompt-tabwin)'
	exe nmap '<m-c-v>        <plug>(wheel-dedibuf-tabwin-tree)'
	exe nmap '<m-s-v>        <plug>(wheel-dedibuf-tabwin)'
	" -- (neo)vim lists
	exe nmap "<m-'>          <plug>(wheel-prompt-marker)"
	exe nmap "<m-k>          <plug>(wheel-prompt-marker)"
	exe nmap '<m-j>          <plug>(wheel-prompt-jump)'
	exe nmap '<m-,>          <plug>(wheel-prompt-change)'
	exe nmap '<m-c>          <plug>(wheel-prompt-change)'
	exe nmap '<m-t>          <plug>(wheel-prompt-tag)'
	exe nmap "<m-c-k>        <plug>(wheel-dedibuf-marker)"
	exe nmap '<m-c-j>        <plug>(wheel-dedibuf-jump)'
	exe nmap '<m-;>          <plug>(wheel-dedibuf-change)'
	exe nmap '<m-c-t>        <plug>(wheel-dedibuf-tag)'
	" ---- organize the wheel
	exe nmap '<m-insert>     <plug>(wheel-prompt-add-here)'
	exe nmap '<m-del>        <plug>(wheel-prompt-delete-location)'
	exe nmap '<m-r>          <plug>(wheel-dedibuf-reorganize)'
	" ---- organize other things
	exe nmap '<m-c-r>        <plug>(wheel-dedibuf-reorg-tabwin)'
	" ---- refactoring
	exe nmap '<m-c-g>        <plug>(wheel-dedibuf-grep-edit)'
	exe nmap '<m-n>          <plug>(wheel-dedibuf-narrow-operator)'
	exe vmap '<m-n>          <plug>(wheel-dedibuf-narrow)'
	exe nmap '<m-c-n>        <plug>(wheel-dedibuf-narrow-circle)'
	" ---- search
	" -- files
	exe nmap '<m-f>          <plug>(wheel-prompt-find)'
	exe nmap '<m-c-f>        <plug>(wheel-dedibuf-find)'
	exe nmap '<m-c-&>        <plug>(wheel-dedibuf-async-find)'
	exe nmap '<m-u>          <plug>(wheel-prompt-mru)'
	exe nmap '<m-c-u>        <plug>(wheel-dedibuf-mru)'
	exe nmap '<m-l>          <plug>(wheel-dedibuf-locate)'
	" -- inside files
	exe nmap '<m-o>          <plug>(wheel-prompt-occur)'
	exe nmap '<m-c-o>        <plug>(wheel-dedibuf-occur)'
	exe nmap '<m-g>          <plug>(wheel-dedibuf-grep)'
	exe nmap '<m-s-o>        <plug>(wheel-dedibuf-outline)'
	" ---- yank ring
	exe nmap '<m-y>          <plug>(wheel-prompt-yank-plain-linewise-after)'
	exe nmap '<m-p>          <plug>(wheel-prompt-yank-plain-charwise-after)'
	exe nmap '<m-s-y>        <plug>(wheel-prompt-yank-plain-linewise-before)'
	if has('nvim') || has('gui_running')
		" strange behavior in terminal vim
		exe nmap '<m-s-p>    <plug>(wheel-prompt-yank-plain-charwise-before)'
	endif
	exe nmap '<m-c-y>        <plug>(wheel-dedibuf-yank-plain)'
	exe nmap '<m-c-p>        <plug>(wheel-dedibuf-yank-list)'
	" ---- undo list
	exe nmap '<m-s-u>        <plug>(wheel-dedibuf-undo-list)'
	" ---- ex or shell command output
	exe nmap '<m-!>          <plug>(wheel-dedibuf-command)'
	exe nmap '<m-&>          <plug>(wheel-dedibuf-async)'
	" ---- dedicated buffers
	exe nmap '<m-tab>        <plug>(wheel-mandala-add)'
	exe nmap '<m-backspace>  <plug>(wheel-mandala-delete)'
	exe nmap '<m-left>       <plug>(wheel-mandala-backward)'
	exe nmap '<m-right>      <plug>(wheel-mandala-forward)'
	exe nmap '<c-up>         <plug>(wheel-mandala-switch)'
	" ---- layouts
	exe nmap '<m-z>          <plug>(wheel-zoom)'
endfun

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
