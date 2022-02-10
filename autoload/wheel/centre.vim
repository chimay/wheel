" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Command, Mappings

" ---- script constants

if ! exists('s:meta_actions')
	let s:meta_actions = wheel#crystal#fetch('command/meta/actions', 'dict')
	lockvar s:meta_actions
endif

if ! exists('s:meta_prompt_actions')
	let s:meta_prompt_actions = wheel#crystal#fetch('command/meta/prompt/actions', 'dict')
	lockvar s:meta_prompt_actions
endif

if ! exists('s:meta_dedibuf_actions')
	let s:meta_dedibuf_actions = wheel#crystal#fetch('command/meta/dedibuf/actions', 'dict')
	lockvar s:meta_dedibuf_actions
endif

" ---- commands

fun! wheel#centre#meta (subcommand, ...)
	" Function for meta command
	let subcommand = a:subcommand
	let arguments = a:000
	" ---- prompt
	if subcommand ==# 'prompt'
		let subcom = arguments[0]
		let action = s:meta_prompt_actions[subcom]
		return eval(action)
	endif
	" ---- dedibuf
	if subcommand ==# 'dedibuf'
		let subcom = arguments[0]
		let action = s:meta_dedibuf_actions[subcom]
		return eval(action)
	endif
	" ---- others actions
	let action = s:meta_actions[subcommand]
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
	" ---- menus
	nnoremap <plug>(wheel-menu-main) <cmd>call wheel#helm#main()<cr>
	nnoremap <plug>(wheel-menu-meta) <cmd>call wheel#helm#meta()<cr>
	" ---- dashboard
	nnoremap <plug>(wheel-dashboard) <cmd>call wheel#status#dashboard()<cr>
	" ---- sync
	" -- sync up : follow
	nnoremap <plug>(wheel-sync-up) <cmd>call wheel#projection#follow()<cr>
	" -- sync down : jump
	nnoremap <plug>(wheel-sync-down) <cmd>call wheel#vortex#jump()<cr>
	" ---- load / save
	" -- load / save wheel
	nnoremap <plug>(wheel-read-wheel) <cmd>call wheel#disc#read_wheel()<cr>
	nnoremap <plug>(wheel-write-wheel) <cmd>call wheel#disc#write_wheel()<cr>
	" -- load / save session
	nnoremap <plug>(wheel-read-session) <cmd>call wheel#disc#read_session()<cr>
	nnoremap <plug>(wheel-write-layout) <cmd>call wheel#disc#write_layout()<cr>
	nnoremap <plug>(wheel-write-session) <cmd>call wheel#disc#write_session()<cr>
	" ---- navigate in the wheel
	" -- next / previous
	nnoremap <plug>(wheel-previous-location) <cmd>call wheel#vortex#previous('location')<cr>
	nnoremap <plug>(wheel-next-location) <cmd>call wheel#vortex#next('location')<cr>
	nnoremap <plug>(wheel-previous-circle) <cmd>call wheel#vortex#previous('circle')<cr>
	nnoremap <plug>(wheel-next-circle) <cmd>call wheel#vortex#next('circle')<cr>
	nnoremap <plug>(wheel-previous-torus) <cmd>call wheel#vortex#previous('torus')<cr>
	nnoremap <plug>(wheel-next-torus) <cmd>call wheel#vortex#next('torus')<cr>
	" -- switch
	nnoremap <plug>(wheel-prompt-location) <cmd>call wheel#vortex#switch('location')<cr>
	nnoremap <plug>(wheel-prompt-circle) <cmd>call wheel#vortex#switch('circle')<cr>
	nnoremap <plug>(wheel-prompt-torus) <cmd>call wheel#vortex#switch('torus')<cr>
	nnoremap <plug>(wheel-prompt-multi-switch) <cmd>call wheel#vortex#multi_switch()<cr>
	nnoremap <plug>(wheel-dedibuf-location) <cmd>call wheel#whirl#switch('location')<cr>
	nnoremap <plug>(wheel-dedibuf-circle) <cmd>call wheel#whirl#switch('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-torus) <cmd>call wheel#whirl#switch('torus')<cr>
	" -- indexes
	nnoremap <plug>(wheel-prompt-index) <cmd>call wheel#vortex#helix()<cr>
	nnoremap <plug>(wheel-prompt-index-circles) <cmd>call wheel#vortex#grid()<cr>
	nnoremap <plug>(wheel-dedibuf-index) <cmd>call wheel#whirl#helix()<cr>
	nnoremap <plug>(wheel-dedibuf-index-circles) <cmd>call wheel#whirl#grid()<cr>
	nnoremap <plug>(wheel-dedibuf-index-tree) <cmd>call wheel#whirl#tree()<cr>
	" -- history
	nnoremap <plug>(wheel-history-newer) <cmd>call wheel#pendulum#newer()<cr>
	nnoremap <plug>(wheel-history-older) <cmd>call wheel#pendulum#older()<cr>
	nnoremap <plug>(wheel-history-newer-in-circle) <cmd>call wheel#pendulum#newer('circle')<cr>
	nnoremap <plug>(wheel-history-older-in-circle) <cmd>call wheel#pendulum#older('circle')<cr>
	nnoremap <plug>(wheel-history-newer-in-torus) <cmd>call wheel#pendulum#newer('torus')<cr>
	nnoremap <plug>(wheel-history-older-in-torus) <cmd>call wheel#pendulum#older('torus')<cr>
	nnoremap <plug>(wheel-prompt-history) <cmd>call wheel#vortex#history()<cr>
	nnoremap <plug>(wheel-dedibuf-history) <cmd>call wheel#whirl#history()<cr>
	" -- alternate
	nnoremap <plug>(wheel-alternate-anywhere) <cmd>call wheel#pendulum#alternate('anywhere')<cr>
	nnoremap <plug>(wheel-alternate-same-torus) <cmd>call wheel#pendulum#alternate('same_torus')<cr>
	nnoremap <plug>(wheel-alternate-same-circle) <cmd>call wheel#pendulum#alternate('same_circle')<cr>
	nnoremap <plug>(wheel-alternate-other-torus) <cmd>call wheel#pendulum#alternate('other_torus')<cr>
	nnoremap <plug>(wheel-alternate-other-circle) <cmd>call wheel#pendulum#alternate('other_circle')<cr>
	nnoremap <plug>(wheel-alternate-same-torus-other-circle) <cmd>call wheel#pendulum#alternate('same_torus_other_circle')<cr>
	nnoremap <plug>(wheel-alternate-menu) <cmd>call wheel#pendulum#alternate_menu()<cr>
	" -- frecency
	nnoremap <plug>(wheel-prompt-frecency) <cmd>call wheel#vortex#frecency()<cr>
	nnoremap <plug>(wheel-dedibuf-frecency) <cmd>call wheel#whirl#frecency()<cr>
	" ---- navigate with vim native tools
	" -- buffers
	nnoremap <plug>(wheel-prompt-buffer) <cmd>call wheel#sailing#buffer()<cr>
	nnoremap <plug>(wheel-dedibuf-buffer) <cmd>call wheel#frigate#buffer()<cr>
	nnoremap <plug>(wheel-dedibuf-buffer-all) <cmd>call wheel#frigate#buffer('all')<cr>
	" -- tabs & windows : visible buffers
	nnoremap <plug>(wheel-prompt-tabwin) <cmd>call wheel#sailing#tabwin()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwin) <cmd>call wheel#frigate#tabwin()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwin-tree) <cmd>call wheel#frigate#tabwin_tree()<cr>
	" -- (neo)vim lists
	nnoremap <plug>(wheel-prompt-marker) <cmd>call wheel#sailing#marker()<cr>
	nnoremap <plug>(wheel-prompt-jump) <cmd>call wheel#sailing#jump()<cr>
	nnoremap <plug>(wheel-prompt-change) <cmd>call wheel#sailing#change()<cr>
	nnoremap <plug>(wheel-prompt-tag) <cmd>call wheel#sailing#tag()<cr>
	nnoremap <plug>(wheel-dedibuf-marker) <cmd>call wheel#frigate#marker()<cr>
	nnoremap <plug>(wheel-dedibuf-jump) <cmd>call wheel#frigate#jump()<cr>
	nnoremap <plug>(wheel-dedibuf-change) <cmd>call wheel#frigate#change()<cr>
	nnoremap <plug>(wheel-dedibuf-tag) <cmd>call wheel#frigate#tag()<cr>
	" ---- organize the wheel
	" -- add
	nnoremap <plug>(wheel-prompt-add-here) <cmd>call wheel#tree#add_here()<cr>
	nnoremap <plug>(wheel-prompt-add-circle) <cmd>call wheel#tree#add_circle()<cr>
	nnoremap <plug>(wheel-prompt-add-torus) <cmd>call wheel#tree#add_torus()<cr>
	nnoremap <plug>(wheel-prompt-add-file) <cmd>call wheel#tree#add_file()<cr>
	nnoremap <plug>(wheel-prompt-add-buffer) <cmd>call wheel#tree#add_buffer()<cr>
	nnoremap <plug>(wheel-prompt-add-glob) <cmd>call wheel#tree#add_glob()<cr>
	" -- reorder
	nnoremap <plug>(wheel-dedibuf-reorder-location) <cmd>call wheel#yggdrasil#reorder('location')<cr>
	nnoremap <plug>(wheel-dedibuf-reorder-circle) <cmd>call wheel#yggdrasil#reorder('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-reorder-torus) <cmd>call wheel#yggdrasil#reorder('torus')<cr>
	" -- rename
	nnoremap <plug>(wheel-prompt-rename-location) <cmd>call wheel#tree#rename('location')<cr>
	nnoremap <plug>(wheel-prompt-rename-circle) <cmd>call wheel#tree#rename('circle')<cr>
	nnoremap <plug>(wheel-prompt-rename-torus) <cmd>call wheel#tree#rename('torus')<cr>
	nnoremap <plug>(wheel-prompt-rename-file) <cmd>call wheel#tree#rename_file()<cr>
	nnoremap <plug>(wheel-dedibuf-rename-location) <cmd>call wheel#yggdrasil#rename('location')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-circle) <cmd>call wheel#yggdrasil#rename('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-torus) <cmd>call wheel#yggdrasil#rename('torus')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-location-filename) <cmd>call wheel#yggdrasil#rename_file()<cr>
	" -- delete
	nnoremap <plug>(wheel-prompt-delete-location) <cmd>call wheel#tree#delete('location')<cr>
	nnoremap <plug>(wheel-prompt-delete-circle) <cmd>call wheel#tree#delete('circle')<cr>
	nnoremap <plug>(wheel-prompt-delete-torus) <cmd>call wheel#tree#delete('torus')<cr>
	nnoremap <plug>(wheel-dedibuf-delete-location) <cmd>call wheel#yggdrasil#delete('location')<cr>
	nnoremap <plug>(wheel-dedibuf-delete-circle) <cmd>call wheel#yggdrasil#delete('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-delete-torus) <cmd>call wheel#yggdrasil#delete('torus')<cr>
	" -- copy & move
	nnoremap <plug>(wheel-prompt-copy-location) <cmd>call wheel#tree#copy('location')<cr>
	nnoremap <plug>(wheel-prompt-copy-circle) <cmd>call wheel#tree#copy('circle')<cr>
	nnoremap <plug>(wheel-prompt-copy-torus) <cmd>call wheel#tree#copy('torus')<cr>
	nnoremap <plug>(wheel-prompt-move-location) <cmd>call wheel#tree#move('location')<cr>
	nnoremap <plug>(wheel-prompt-move-circle) <cmd>call wheel#tree#move('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-copy-move-location) <cmd>call wheel#yggdrasil#copy_move('location')<cr>
	nnoremap <plug>(wheel-dedibuf-copy-move-circle) <cmd>call wheel#yggdrasil#copy_move('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-copy-move-torus) <cmd>call wheel#yggdrasil#copy_move('torus')<cr>
	" -- reorganize
	nnoremap <plug>(wheel-dedibuf-reorganize) <cmd>call wheel#yggdrasil#reorganize()<cr>
	" ---- organize elsewhere
	" -- tabs & windows
	nnoremap <plug>(wheel-dedibuf-reorg-tabwin) <cmd>call wheel#mirror#reorg_tabwin()<cr>
	" ---- refactoring
	" -- grep edit mode
	nnoremap <plug>(wheel-dedibuf-grep-edit) <cmd>call wheel#shadow#grep_edit()<cr>
	" -- narrow
	nnoremap <plug>(wheel-dedibuf-narrow) <cmd>call wheel#shadow#narrow_file()<cr>
	nnoremap <expr> <plug>(wheel-dedibuf-narrow-operator) wheel#shadow#narrow_file_operator()
	nnoremap <plug>(wheel-dedibuf-narrow-circle) <cmd>call wheel#shadow#narrow_circle()<cr>
	" use colon instead of <cmd> to catch the range
	vnoremap <plug>(wheel-dedibuf-narrow) :call wheel#shadow#narrow_file()<cr>
	" ---- search
	" -- files
	nnoremap <plug>(wheel-prompt-find) <cmd>call wheel#sailing#find()<cr>
	nnoremap <plug>(wheel-dedibuf-find) <cmd>call wheel#frigate#find()<cr>
	nnoremap <plug>(wheel-dedibuf-async-find) <cmd>call wheel#frigate#async_find()<cr>
	nnoremap <plug>(wheel-prompt-mru) <cmd>call wheel#sailing#mru()<cr>
	nnoremap <plug>(wheel-dedibuf-mru) <cmd>call wheel#frigate#mru()<cr>
	nnoremap <plug>(wheel-dedibuf-locate) <cmd>call wheel#frigate#locate()<cr>
	" -- inside files
	nnoremap <plug>(wheel-prompt-occur) <cmd>call wheel#sailing#occur()<cr>
	nnoremap <plug>(wheel-dedibuf-occur) <cmd>call wheel#frigate#occur()<cr>
	nnoremap <plug>(wheel-dedibuf-grep) <cmd>call wheel#frigate#grep()<cr>
	nnoremap <plug>(wheel-dedibuf-outline) <cmd>call wheel#frigate#outline()<cr>
	" ---- yank ring
	nnoremap <plug>(wheel-prompt-yank-plain-linewise-after) <cmd>call wheel#codex#yank_plain()<cr>
	nnoremap <plug>(wheel-prompt-yank-plain-charwise-after) <cmd>call wheel#codex#yank_plain('charwise-after')<cr>
	nnoremap <plug>(wheel-prompt-yank-plain-linewise-before) <cmd>call wheel#codex#yank_plain('linewise-before')<cr>
	nnoremap <plug>(wheel-prompt-yank-plain-charwise-before) <cmd>call wheel#codex#yank_plain('charwise-before')<cr>
	nnoremap <plug>(wheel-prompt-yank-list-linewise-after) <cmd>call wheel#codex#yank_list()<cr>
	nnoremap <plug>(wheel-prompt-yank-list-charwise-after) <cmd>call wheel#codex#yank_list('charwise-after')<cr>
	nnoremap <plug>(wheel-prompt-yank-list-linewise-before) <cmd>call wheel#codex#yank_list('linewise-before')<cr>
	nnoremap <plug>(wheel-prompt-yank-list-charwise-before) <cmd>call wheel#codex#yank_list('charwise-before')<cr>
	nnoremap <plug>(wheel-prompt-switch-register) <cmd>call wheel#codex#prompt_switch()<cr>
	nnoremap <plug>(wheel-dedibuf-yank-plain) <cmd>call wheel#clipper#yank('plain')<cr>
	nnoremap <plug>(wheel-dedibuf-yank-list) <cmd>call wheel#clipper#yank('list')<cr>
	" ---- undo list
	nnoremap <plug>(wheel-dedibuf-undo-list) <cmd>call wheel#triangle#undolist()<cr>
	" ---- ex or shell command output
	nnoremap <plug>(wheel-dedibuf-command) <cmd>call wheel#mandala#command()<cr>
	nnoremap <plug>(wheel-dedibuf-async) <cmd>call wheel#mandala#async()<cr>
	" ---- dedicated buffer
	nnoremap <plug>(wheel-mandala-add) <cmd>call wheel#cylinder#add('furtive')<cr>
	nnoremap <plug>(wheel-mandala-delete) <cmd>call wheel#cylinder#delete()<cr>
	nnoremap <plug>(wheel-mandala-forward) <cmd>call wheel#cylinder#forward()<cr>
	nnoremap <plug>(wheel-mandala-backward) <cmd>call wheel#cylinder#backward()<cr>
	nnoremap <plug>(wheel-mandala-switch) <cmd>call wheel#cylinder#switch()<cr>
	" ---- layouts
	nnoremap <plug>(wheel-layout-zoom) <cmd>call wheel#mosaic#zoom()<cr>
	" -- tabs
	nnoremap <plug>(wheel-layout-tabs-locations) <cmd>call wheel#mosaic#tabs('location')<cr>
	nnoremap <plug>(wheel-layout-tabs-circles) <cmd>call wheel#mosaic#tabs('circle')<cr>
	nnoremap <plug>(wheel-layout-tabs-toruses) <cmd>call wheel#mosaic#tabs('torus')<cr>
	" -- windows
	nnoremap <plug>(wheel-layout-split-locations) <cmd>call wheel#mosaic#split('location')<cr>
	nnoremap <plug>(wheel-layout-split-circles) <cmd>call wheel#mosaic#split('circle')<cr>
	nnoremap <plug>(wheel-layout-split-toruses) <cmd>call wheel#mosaic#split('torus')<cr>
	nnoremap <plug>(wheel-layout-vsplit-locations) <cmd>call wheel#mosaic#split('location', 'vertical')<cr>
	nnoremap <plug>(wheel-layout-vsplit-circles) <cmd>call wheel#mosaic#split('circle', 'vertical')<cr>
	nnoremap <plug>(wheel-layout-vsplit-toruses) <cmd>call wheel#mosaic#split('torus', 'vertical')<cr>
	nnoremap <plug>(wheel-layout-main-top-locations) <cmd>call wheel#mosaic#split('location', 'main_top')<cr>
	nnoremap <plug>(wheel-layout-main-top-circles) <cmd>call wheel#mosaic#split('circle', 'main_top')<cr>
	nnoremap <plug>(wheel-layout-main-top-toruses) <cmd>call wheel#mosaic#split('torus', 'main_top')<cr>
	nnoremap <plug>(wheel-layout-main-left-locations) <cmd>call wheel#mosaic#split('location', 'main_left')<cr>
	nnoremap <plug>(wheel-layout-main-left-circles) <cmd>call wheel#mosaic#split('circle', 'main_left')<cr>
	nnoremap <plug>(wheel-layout-main-left-toruses) <cmd>call wheel#mosaic#split('torus', 'main_left')<cr>
	nnoremap <plug>(wheel-layout-grid-locations) <cmd>call wheel#mosaic#split_grid('location')<cr>
	nnoremap <plug>(wheel-layout-grid-circles) <cmd>call wheel#mosaic#split_grid('circle')<cr>
	nnoremap <plug>(wheel-layout-grid-toruses) <cmd>call wheel#mosaic#split_grid('torus')<cr>
	" -- tabs & windows
	nnoremap <plug>(wheel-layout-tab-win-torus) <cmd>call wheel#pyramid#steps('torus')<cr>
	nnoremap <plug>(wheel-layout-tab-win-circle) <cmd>call wheel#pyramid#steps('circle')<cr>
	" -- rotating windows
	nnoremap <plug>(wheel-layout-rotate-counter-clockwise) <cmd>call wheel#mosaic#rotate_counter_clockwise()<cr>
	nnoremap <plug>(wheel-layout-rotate-clockwise) <cmd>call wheel#mosaic#rotate_clockwise()<cr>
	" ---- misc
	nnoremap <plug>(wheel-spiral-cursor) <cmd>call wheel#spiral#cursor()<cr>
	" ---- debug
	nnoremap <plug>(wheel-debug-fresh-wheel) <cmd>call wheel#void#fresh_wheel()<cr>
	nnoremap <plug>(wheel-debug-clear-echo-area) <cmd>call wheel#status#clear()<cr>
	nnoremap <plug>(wheel-debug-clear-messages) <cmd>call wheel#status#clear_messages()<cr>
	nnoremap <plug>(wheel-debug-clear-signs) <cmd>call wheel#chakra#clear()<cr>
	nnoremap <plug>(wheel-debug-prompt-history-circuit) <cmd>call wheel#vortex#history_circuit()<cr>
	nnoremap <plug>(wheel-debug-dedibuf-history-circuit) <cmd>call wheel#whirl#history_circuit()<cr>
endfun

fun! wheel#centre#cables ()
	" Link keys to <plug> mappings
	" maps arguments
	let nmap = 'nmap <silent>'
	let vmap = 'vmap <silent>'
	" general prefix
	let prefix = g:wheel_config.prefix
	" subprefixes
	let batch = '@'
	let async = '&'
	let layout = 'z'
	let debug = 'Z'
	" Basic
	if g:wheel_config.mappings >= 0
		" ---- menus
		exe nmap prefix .. '<m-m> <plug>(wheel-menu-main)'
		exe nmap prefix .. '= <plug>(wheel-menu-meta)'
		" ---- dashboard, info
		exe nmap prefix .. 'i <plug>(wheel-dashboard)'
		" ---- sync
		" -- up : follow
		exe nmap prefix .. '<m-$> <plug>(wheel-sync-up)'
		" -- down : jump
		exe nmap prefix .. '$ <plug>(wheel-sync-down)'
		" ---- load / Save
		" -- wheel
		exe nmap prefix .. 'r <plug>(wheel-read-wheel)'
		exe nmap prefix .. 'w <plug>(wheel-write-wheel)'
		" -- session file
		exe nmap prefix .. 'R <plug>(wheel-read-session)'
		exe nmap prefix .. 'W <plug>(wheel-write-layout)'
		" ---- navigate in the wheel
		" -- next / previous
		exe nmap prefix .. '<pageup>     <plug>(wheel-previous-location)'
		exe nmap prefix .. '<pagedown>   <plug>(wheel-next-location)'
		exe nmap prefix .. '<c-pageup>   <plug>(wheel-previous-circle)'
		exe nmap prefix .. '<c-pagedown> <plug>(wheel-next-circle)'
		exe nmap prefix .. '<s-pageup>   <plug>(wheel-previous-torus)'
		exe nmap prefix .. '<s-pagedown> <plug>(wheel-next-torus)'
		" -- history
		exe nmap prefix .. '<home>   <plug>(wheel-history-newer)'
		exe nmap prefix .. '<end>    <plug>(wheel-history-older)'
		exe nmap prefix .. '<c-home> <plug>(wheel-history-newer-in-circle)'
		exe nmap prefix .. '<c-end>  <plug>(wheel-history-older-in-circle)'
		exe nmap prefix .. '<s-home> <plug>(wheel-history-newer-in-torus)'
		exe nmap prefix .. '<s-end>  <plug>(wheel-history-older-in-torus)'
		" -- alternate
		exe nmap prefix .. '<c-^> <plug>(wheel-alternate-anywhere)'
		exe nmap prefix .. '<m-^> <plug>(wheel-alternate-same-circle)'
		exe nmap prefix .. '<m-c-^> <plug>(wheel-alternate-same-torus-other-circle)'
		exe nmap prefix .. '^ <plug>(wheel-alternate-menu)'
		" ---- organize wheel
		" -- add
		exe nmap prefix .. 'a <plug>(wheel-prompt-add-here)'
		exe nmap prefix .. '<c-a> <plug>(wheel-prompt-add-circle)'
		exe nmap prefix .. 'A <plug>(wheel-prompt-add-torus)'
		exe nmap prefix .. '+f <plug>(wheel-prompt-add-file)'
		exe nmap prefix .. '+b <plug>(wheel-prompt-add-buffer)'
		exe nmap prefix .. '* <plug>(wheel-prompt-add-glob)'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" ---- navigate in the wheel
		" -- switch
		exe nmap prefix .. '<cr> <plug>(wheel-prompt-location)'
		exe nmap prefix .. '<c-cr> <plug>(wheel-prompt-circle)'
		exe nmap prefix .. '<s-cr> <plug>(wheel-prompt-torus)'
		exe nmap prefix .. '<m-cr> <plug>(wheel-prompt-multi-switch)'
		exe nmap prefix .. '<space> <plug>(wheel-dedibuf-location)'
		exe nmap prefix .. '<c-space> <plug>(wheel-dedibuf-circle)'
		exe nmap prefix .. '<s-space> <plug>(wheel-dedibuf-torus)'
		" -- indexes
		exe nmap prefix .. 'x <plug>(wheel-prompt-index)'
		exe nmap prefix .. '<c-x> <plug>(wheel-prompt-index-circles)'
		exe nmap prefix .. 'X <plug>(wheel-dedibuf-index)'
		exe nmap prefix .. '<m-x> <plug>(wheel-dedibuf-index-tree)'
		exe nmap prefix .. '<m-s-x> <plug>(wheel-dedibuf-index-circles)'
		" -- history
		exe nmap prefix .. 'h <plug>(wheel-prompt-history)'
		exe nmap prefix .. '<m-h> <plug>(wheel-dedibuf-history)'
		" -- frecency
		exe nmap prefix .. 'e <plug>(wheel-prompt-frecency)'
		exe nmap prefix .. '<m-e> <plug>(wheel-dedibuf-frecency)'
		" ---- organize wheel
		" -- reorder
		exe nmap prefix .. batch .. 'o <plug>(wheel-dedibuf-reorder-location)'
		exe nmap prefix .. batch .. '<c-o> <plug>(wheel-dedibuf-reorder-circle)'
		exe nmap prefix .. batch .. 'O <plug>(wheel-dedibuf-reorder-torus)'
		" -- rename
		exe nmap prefix .. 'n <plug>(wheel-prompt-rename-location)'
		exe nmap prefix .. '<c-n> <plug>(wheel-prompt-rename-circle)'
		exe nmap prefix .. 'N <plug>(wheel-prompt-rename-torus)'
		exe nmap prefix .. '<m-n> <plug>(wheel-prompt-rename-file)'
		exe nmap prefix .. batch .. 'n <plug>(wheel-dedibuf-rename-location)'
		exe nmap prefix .. batch .. '<c-n> <plug>(wheel-dedibuf-rename-circle)'
		exe nmap prefix .. batch .. 'N <plug>(wheel-dedibuf-rename-torus)'
		exe nmap prefix .. batch .. '<m-n> <plug>(wheel-dedibuf-rename-location-filename)'
		" -- delete
		exe nmap prefix .. 'd <plug>(wheel-prompt-delete-location)'
		exe nmap prefix .. '<c-d> <plug>(wheel-prompt-delete-circle)'
		exe nmap prefix .. 'D <plug>(wheel-prompt-delete-torus)'
		exe nmap prefix .. batch .. 'd <plug>(wheel-dedibuf-delete-location)'
		exe nmap prefix .. batch .. '<c-d> <plug>(wheel-dedibuf-delete-circle)'
		exe nmap prefix .. batch .. 'D <plug>(wheel-dedibuf-delete-torus)'
		" -- copy & move
		exe nmap prefix .. 'c <plug>(wheel-prompt-copy-location)'
		" <c-c> does not work in maps
		exe nmap prefix .. '<m-c> <plug>(wheel-prompt-copy-circle)'
		exe nmap prefix .. 'C <plug>(wheel-prompt-copy-torus)'
		exe nmap prefix .. 'm <plug>(wheel-prompt-move-location)'
		exe nmap prefix .. 'M <plug>(wheel-prompt-move-circle)'
		exe nmap prefix .. batch .. 'c <plug>(wheel-dedibuf-copy-move-location)'
		exe nmap prefix .. batch .. '<m-c> <plug>(wheel-dedibuf-copy-move-circle)'
		exe nmap prefix .. batch .. 'C <plug>(wheel-dedibuf-copy-move-torus)'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" ---- navigate with vim native tools
		" -- buffers
		exe nmap prefix .. 'b <plug>(wheel-prompt-buffer)'
		exe nmap prefix .. '<m-b> <plug>(wheel-dedibuf-buffer)'
		exe nmap prefix .. '<c-b> <plug>(wheel-dedibuf-buffer-all)'
		" -- tabs & windows : visible buffers
		exe nmap prefix .. 'v <plug>(wheel-prompt-tabwin)'
		exe nmap prefix .. '<m-v> <plug>(wheel-dedibuf-tabwin-tree)'
		exe nmap prefix .. '<c-v> <plug>(wheel-dedibuf-tabwin)'
		" -- (neo)vim lists
		exe nmap prefix .. "' <plug>(wheel-prompt-marker)"
		exe nmap prefix .. 'j <plug>(wheel-prompt-jump)'
		exe nmap prefix .. ', <plug>(wheel-prompt-change)'
		exe nmap prefix .. 't <plug>(wheel-prompt-tag)'
		exe nmap prefix .. "<m-'> <plug>(wheel-dedibuf-marker)"
		exe nmap prefix .. '<m-j> <plug>(wheel-dedibuf-jump)'
		exe nmap prefix .. '; <plug>(wheel-dedibuf-change)'
		exe nmap prefix .. '<m-t> <plug>(wheel-dedibuf-tag)'
		" ---- reorganize wheel
		exe nmap prefix .. '<m-r> <plug>(wheel-dedibuf-reorganize)'
		" ---- reorganize other things
		exe nmap prefix .. '<c-r> <plug>(wheel-dedibuf-reorg-tabwin)'
		" ---- refactoring
		exe nmap prefix .. '<m-g> <plug>(wheel-dedibuf-grep-edit)'
		exe nmap prefix .. '-% <plug>(wheel-dedibuf-narrow)'
		exe nmap prefix .. '-- <plug>(wheel-dedibuf-narrow-operator)'
		exe vmap prefix .. '-- <plug>(wheel-dedibuf-narrow)'
		exe nmap prefix .. '-c <plug>(wheel-dedibuf-narrow-circle)'
		" ---- search
		" -- files
		exe nmap prefix .. 'f <plug>(wheel-prompt-find)'
		exe nmap prefix .. '<m-f> <plug>(wheel-dedibuf-find)'
		exe nmap prefix .. async .. 'f <plug>(wheel-dedibuf-async-find)'
		exe nmap prefix .. 'u <plug>(wheel-prompt-mru)'
		exe nmap prefix .. '<m-u> <plug>(wheel-dedibuf-mru)'
		exe nmap prefix .. 'l <plug>(wheel-dedibuf-locate)'
		" -- inside files
		exe nmap prefix .. 'o <plug>(wheel-prompt-occur)'
		exe nmap prefix .. '<m-o> <plug>(wheel-dedibuf-occur)'
		exe nmap prefix .. 'g <plug>(wheel-dedibuf-grep)'
		exe nmap prefix .. '<c-o> <plug>(wheel-dedibuf-outline)'
		" ---- yank ring
		exe nmap prefix .. '<C-y> <plug>(wheel-prompt-switch-register)'
		exe nmap prefix .. 'y <plug>(wheel-prompt-yank-plain-linewise-after)'
		exe nmap prefix .. 'p <plug>(wheel-prompt-yank-plain-charwise-after)'
		exe nmap prefix .. 'Y <plug>(wheel-prompt-yank-plain-linewise-before)'
		exe nmap prefix .. 'P <plug>(wheel-prompt-yank-plain-charwise-before)'
		exe nmap prefix .. '<m-y> <plug>(wheel-dedibuf-yank-plain)'
		exe nmap prefix .. '<m-p> <plug>(wheel-dedibuf-yank-list)'
		" ---- undo list
		exe nmap prefix .. '<c-u> <plug>(wheel-dedibuf-undo-list)'
		" ---- generic ex or shell command
		exe nmap prefix .. ': <plug>(wheel-dedibuf-command)'
		exe nmap prefix .. async .. '& <plug>(wheel-dedibuf-async)'
		" ---- dedicated buffers
		exe nmap prefix .. '<tab> <plug>(wheel-mandala-add)'
		exe nmap prefix .. '<backspace> <plug>(wheel-mandala-delete)'
		exe nmap prefix .. '<left> <plug>(wheel-mandala-backward)'
		exe nmap prefix .. '<right>  <plug>(wheel-mandala-forward)'
		exe nmap prefix .. '<up> <plug>(wheel-mandala-switch)'
		" ---- layouts
		exe nmap prefix .. layout .. 'z <plug>(wheel-layout-zoom)'
		" -- tabs
		exe nmap prefix .. layout .. 't <plug>(wheel-layout-tabs-locations)'
		exe nmap prefix .. layout .. '<c-t> <plug>(wheel-layout-tabs-circles)'
		exe nmap prefix .. layout .. 'T <plug>(wheel-layout-tabs-toruses)'
		" -- windows
		exe nmap prefix .. layout .. 's <plug>(wheel-layout-split-locations)'
		exe nmap prefix .. layout .. '<c-s> <plug>(wheel-layout-split-circles)'
		exe nmap prefix .. layout .. 'S <plug>(wheel-layout-split-toruses)'
		exe nmap prefix .. layout .. 'v <plug>(wheel-layout-vsplit-locations)'
		exe nmap prefix .. layout .. '<c-v> <plug>(wheel-layout-vsplit-circles)'
		exe nmap prefix .. layout .. 'V <plug>(wheel-layout-vsplit-toruses)'
		" -- main top
		exe nmap prefix .. layout .. 'm <plug>(wheel-layout-main-top-locations)'
		exe nmap prefix .. layout .. '<c-m> <plug>(wheel-layout-main-top-circles)'
		exe nmap prefix .. layout .. 'M <plug>(wheel-layout-main-top-toruses)'
		" -- main left
		exe nmap prefix .. layout .. 'l <plug>(wheel-layout-main-left-locations)'
		exe nmap prefix .. layout .. '<c-l> <plug>(wheel-layout-main-left-circles)'
		exe nmap prefix .. layout .. 'L <plug>(wheel-layout-main-left-toruses)'
		" -- grid
		exe nmap prefix .. layout .. 'g <plug>(wheel-layout-grid-locations)'
		exe nmap prefix .. layout .. '<c-g> <plug>(wheel-layout-grid-circles)'
		exe nmap prefix .. layout .. 'G <plug>(wheel-layout-grid-toruses)'
		" -- tabs & windows
		exe nmap prefix .. layout .. '& <plug>(wheel-layout-tab-win-circle)'
		exe nmap prefix .. layout .. '<M-&> <plug>(wheel-layout-tab-win-torus)'
		" -- rotating windows
		exe nmap prefix .. layout .. '<up> <plug>(wheel-layout-rotate-counter-clockwise)'
		exe nmap prefix .. layout .. '<down> <plug>(wheel-layout-rotate-clockwise)'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
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
		exe nmap '<m-s-p>        <plug>(wheel-prompt-yank-plain-charwise-before)'
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
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe nmap prefix .. debug .. 'Z <plug>(wheel-debug-fresh-wheel)'
		exe nmap prefix .. debug .. 'e <plug>(wheel-debug-clear-echo-area)'
		exe nmap prefix .. debug .. 'm <plug>(wheel-debug-clear-messages)'
		exe nmap prefix .. debug .. 's <plug>(wheel-debug-clear-signs)'
		exe nmap prefix .. debug .. 'h <plug>(wheel-debug-prompt-history-circuit)'
		exe nmap prefix .. debug .. '<m-h> <plug>(wheel-debug-dedibuf-history-circuit)'
	endif
endfun
