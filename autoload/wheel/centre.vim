" vim: set ft=vim fdm=indent iskeyword&:

" Command, Mappings

fun! wheel#centre#commands ()
	" Define commands
	" Status
	command! WheelDashboard call wheel#status#dashboard()
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
	command! WheelAutogroup call wheel#group#menu()
	command! WheelTreeScript call wheel#disc#tree_script()
	command! WheelSymlinkTree call wheel#disc#symlink_tree()
	command! WheelCopiedTree call wheel#disc#copied_tree()
endfun

fun! wheel#centre#plugs ()
	" Link <plug> mappings to wheel functions
	" ---- menus
	nnoremap <plug>(wheel-menu-main) <cmd>call wheel#helm#main()<cr>
	nnoremap <plug>(wheel-menu-meta) <cmd>call wheel#helm#meta()<cr>
	" ---- dashboard
	nnoremap <plug>(wheel-dashboard) <cmd>call wheel#status#dashboard()<cr>
	" ---- sync
	" -- sync down : jump
	nnoremap <plug>(wheel-sync-down) <cmd>call wheel#vortex#jump()<cr>
	" -- sync up : follow
	nnoremap <plug>(wheel-sync-up) <cmd>call wheel#projection#follow()<cr>
	" ---- load / save
	" -- load / save wheel
	nnoremap <plug>(wheel-read-wheel) <cmd>call wheel#disc#read_all()<cr>
	nnoremap <plug>(wheel-write-wheel) <cmd>call wheel#disc#write_all()<cr>
	" -- load / save session
	nnoremap <plug>(wheel-read-session) <cmd>call wheel#disc#read_session()<cr>
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
	nnoremap <plug>(wheel-dedibuf-location) <cmd>call wheel#sailing#switch('location')<cr>
	nnoremap <plug>(wheel-dedibuf-circle) <cmd>call wheel#sailing#switch('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-torus) <cmd>call wheel#sailing#switch('torus')<cr>
	" -- indexes
	nnoremap <plug>(wheel-prompt-index) <cmd>call wheel#vortex#helix()<cr>
	nnoremap <plug>(wheel-prompt-index-circles) <cmd>call wheel#vortex#grid()<cr>
	nnoremap <plug>(wheel-dedibuf-index) <cmd>call wheel#sailing#helix()<cr>
	nnoremap <plug>(wheel-dedibuf-index-circles) <cmd>call wheel#sailing#grid()<cr>
	nnoremap <plug>(wheel-dedibuf-tree) <cmd>call wheel#sailing#tree()<cr>
	" -- history
	nnoremap <plug>(wheel-history-newer) <cmd>call wheel#pendulum#newer()<cr>
	nnoremap <plug>(wheel-history-older) <cmd>call wheel#pendulum#older()<cr>
	nnoremap <plug>(wheel-history-newer-in-circle) <cmd>call wheel#pendulum#newer('circle')<cr>
	nnoremap <plug>(wheel-history-older-in-circle) <cmd>call wheel#pendulum#older('circle')<cr>
	nnoremap <plug>(wheel-history-newer-in-torus) <cmd>call wheel#pendulum#newer('torus')<cr>
	nnoremap <plug>(wheel-history-older-in-torus) <cmd>call wheel#pendulum#older('torus')<cr>
	nnoremap <plug>(wheel-prompt-history) <cmd>call wheel#vortex#history()<cr>
	nnoremap <plug>(wheel-dedibuf-history) <cmd>call wheel#sailing#history()<cr>
	" -- alternate
	nnoremap <plug>(wheel-alternate-anywhere) <cmd>call wheel#pendulum#alternate('anywhere')<cr>
	nnoremap <plug>(wheel-alternate-same-torus) <cmd>call wheel#pendulum#alternate('same_torus')<cr>
	nnoremap <plug>(wheel-alternate-same-circle) <cmd>call wheel#pendulum#alternate('same_circle')<cr>
	nnoremap <plug>(wheel-alternate-other-torus) <cmd>call wheel#pendulum#alternate('other_torus')<cr>
	nnoremap <plug>(wheel-alternate-other-circle) <cmd>call wheel#pendulum#alternate('other_circle')<cr>
	nnoremap <plug>(wheel-alternate-same-torus-other-circle) <cmd>call wheel#pendulum#alternate('same_torus_other_circle')<cr>
	nnoremap <plug>(wheel-alternate-menu) <cmd>call wheel#pendulum#alternate_menu()<cr>
	" ---- navigate with vim native tools
	" -- buffers
	nnoremap <plug>(wheel-prompt-buffers) <cmd>call wheel#whirl#buffer()<cr>
	nnoremap <plug>(wheel-dedibuf-buffers) <cmd>call wheel#frigate#buffers()<cr>
	nnoremap <plug>(wheel-dedibuf-buffers-all) <cmd>call wheel#frigate#buffers('all')<cr>
	" -- tabs & windows : visible buffers
	nnoremap <plug>(wheel-prompt-tabwin) <cmd>call wheel#whirl#tabwin()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwins) <cmd>call wheel#frigate#tabwins()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwins-tree) <cmd>call wheel#frigate#tabwins_tree()<cr>
	" -- (neo)vim lists
	nnoremap <plug>(wheel-prompt-marker) <cmd>call wheel#whirl#marker()<cr>
	nnoremap <plug>(wheel-prompt-jump) <cmd>call wheel#whirl#jump()<cr>
	nnoremap <plug>(wheel-prompt-change) <cmd>call wheel#whirl#change()<cr>
	nnoremap <plug>(wheel-prompt-tag) <cmd>call wheel#whirl#tag()<cr>
	nnoremap <plug>(wheel-dedibuf-markers) <cmd>call wheel#frigate#markers()<cr>
	nnoremap <plug>(wheel-dedibuf-jumps) <cmd>call wheel#frigate#jumps()<cr>
	nnoremap <plug>(wheel-dedibuf-changes) <cmd>call wheel#frigate#changes()<cr>
	nnoremap <plug>(wheel-dedibuf-tags) <cmd>call wheel#frigate#tags()<cr>
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
	nnoremap <plug>(wheel-dedibuf-rename-location-filename) <cmd>call wheel#yggdrasil#rename_files()<cr>
	" -- delete
	nnoremap <plug>(wheel-prompt-delete-location) <cmd>call wheel#tree#delete('location')<cr>
	nnoremap <plug>(wheel-prompt-delete-circle) <cmd>call wheel#tree#delete('circle')<cr>
	nnoremap <plug>(wheel-prompt-delete-torus) <cmd>call wheel#tree#delete('torus')<cr>
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
	nnoremap <plug>(wheel-dedibuf-reorg-tabwins) <cmd>call wheel#shape#reorg_tabwins()<cr>
	" ---- refactor
	" -- grep edit mode
	nnoremap <plug>(wheel-dedibuf-grep-edit) <cmd>call wheel#shape#grep_edit()<cr>
	" -- narrow
	nnoremap <plug>(wheel-dedibuf-narrow) <cmd>call wheel#shape#narrow_file()<cr>
	nnoremap <expr> <plug>(wheel-dedibuf-narrow-operator) wheel#polyphony#operator()
	nnoremap <plug>(wheel-dedibuf-narrow-circle) <cmd>call wheel#shape#narrow_circle()<cr>
	" use colon instead of <cmd> to catch the range
	vnoremap <plug>(wheel-dedibuf-narrow) :call wheel#shape#narrow_file()<cr>
	" ---- search
	" -- files
	nnoremap <plug>(wheel-prompt-mru) <cmd>call wheel#whirl#mru()<cr>
	nnoremap <plug>(wheel-dedibuf-mru) <cmd>call wheel#frigate#mru()<cr>
	nnoremap <plug>(wheel-dedibuf-locate) <cmd>call wheel#frigate#locate()<cr>
	nnoremap <plug>(wheel-dedibuf-find) <cmd>call wheel#frigate#find()<cr>
	nnoremap <plug>(wheel-dedibuf-async-find) <cmd>call wheel#frigate#async_find()<cr>
	" -- inside files
	nnoremap <plug>(wheel-prompt-occur) <cmd>call wheel#whirl#occur()<cr>
	nnoremap <plug>(wheel-dedibuf-occur) <cmd>call wheel#frigate#occur()<cr>
	nnoremap <plug>(wheel-dedibuf-grep) <cmd>call wheel#frigate#grep()<cr>
	nnoremap <plug>(wheel-dedibuf-outline) <cmd>call wheel#frigate#outline()<cr>
	" ---- yank ring
	nnoremap <plug>(wheel-dedibuf-yank-list) <cmd>call wheel#clipper#yank('list')<cr>
	nnoremap <plug>(wheel-dedibuf-yank-plain) <cmd>call wheel#clipper#yank('plain')<cr>
	" ---- undo list
	nnoremap <plug>(wheel-dedibuf-undo-list) <cmd>call wheel#triangle#undolist()<cr>
	" ---- ex or shell command output
	nnoremap <plug>(wheel-dedibuf-command) <cmd>call wheel#mandala#command()<cr>
	nnoremap <plug>(wheel-dedibuf-async) <cmd>call wheel#mandala#async()<cr>
	" ---- dedicated buffer
	nnoremap <plug>(wheel-mandala-add) <cmd>call wheel#cylinder#add()<cr>
	nnoremap <plug>(wheel-mandala-delete) <cmd>call wheel#cylinder#delete()<cr>
	nnoremap <plug>(wheel-mandala-forward) <cmd>call wheel#cylinder#forward()<cr>
	nnoremap <plug>(wheel-mandala-backward) <cmd>call wheel#cylinder#backward()<cr>
	nnoremap <plug>(wheel-mandala-switch) <cmd>call wheel#cylinder#switch()<cr>
	" ---- layouts
	nnoremap <plug>(wheel-zoom) <cmd>call wheel#mosaic#zoom()<cr>
	" -- tabs
	nnoremap <plug>(wheel-tabs-locations) <cmd>call wheel#mosaic#tabs('location')<cr>
	nnoremap <plug>(wheel-tabs-circles) <cmd>call wheel#mosaic#tabs('circle')<cr>
	nnoremap <plug>(wheel-tabs-toruses) <cmd>call wheel#mosaic#tabs('torus')<cr>
	" -- windows
	nnoremap <plug>(wheel-split-locations) <cmd>call wheel#mosaic#split('location')<cr>
	nnoremap <plug>(wheel-split-circles) <cmd>call wheel#mosaic#split('circle')<cr>
	nnoremap <plug>(wheel-split-toruses) <cmd>call wheel#mosaic#split('torus')<cr>
	nnoremap <plug>(wheel-vsplit-locations) <cmd>call wheel#mosaic#split('location', 'vertical')<cr>
	nnoremap <plug>(wheel-vsplit-circles) <cmd>call wheel#mosaic#split('circle', 'vertical')<cr>
	nnoremap <plug>(wheel-vsplit-toruses) <cmd>call wheel#mosaic#split('torus', 'vertical')<cr>
	nnoremap <plug>(wheel-main-top-locations) <cmd>call wheel#mosaic#split('location', 'main_top')<cr>
	nnoremap <plug>(wheel-main-top-circles) <cmd>call wheel#mosaic#split('circle', 'main_top')<cr>
	nnoremap <plug>(wheel-main-top-toruses) <cmd>call wheel#mosaic#split('torus', 'main_top')<cr>
	nnoremap <plug>(wheel-main-left-locations) <cmd>call wheel#mosaic#split('location', 'main_left')<cr>
	nnoremap <plug>(wheel-main-left-circles) <cmd>call wheel#mosaic#split('circle', 'main_left')<cr>
	nnoremap <plug>(wheel-main-left-toruses) <cmd>call wheel#mosaic#split('torus', 'main_left')<cr>
	nnoremap <plug>(wheel-grid-locations) <cmd>call wheel#mosaic#split_grid('location')<cr>
	nnoremap <plug>(wheel-grid-circles) <cmd>call wheel#mosaic#split_grid('circle')<cr>
	nnoremap <plug>(wheel-grid-toruses) <cmd>call wheel#mosaic#split_grid('torus')<cr>
	" -- tabs & windows
	nnoremap <plug>(wheel-tab-win-torus) <cmd>call wheel#pyramid#steps('torus')<cr>
	nnoremap <plug>(wheel-tab-win-circle) <cmd>call wheel#pyramid#steps('circle')<cr>
	" -- rotating windows
	nnoremap <plug>(wheel-rotate-counter-clockwise) <cmd>call wheel#mosaic#rotate_counter_clockwise()<cr>
	nnoremap <plug>(wheel-rotate-clockwise) <cmd>call wheel#mosaic#rotate_clockwise()<cr>
	" ---- misc
	nnoremap <plug>(wheel-spiral-cursor) <cmd>call wheel#spiral#cursor()<cr>
	" ---- debug
	nnoremap <plug>(wheel-debug-fresh-wheel) <cmd>call wheel#void#fresh_wheel()<cr>
	nnoremap <plug>(wheel-debug-clear-echo-area) <cmd>call wheel#status#clear()<cr>
	nnoremap <plug>(wheel-debug-prompt-history-circuit) <cmd>call wheel#vortex#history_circuit()<cr>
	nnoremap <plug>(wheel-debug-dedibuf-history-circuit) <cmd>call wheel#sailing#history_circuit()<cr>
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
		" -- down : jump
		exe nmap prefix .. '$ <plug>(wheel-sync-down)'
		" -- up : follow
		exe nmap prefix .. '<m-$> <plug>(wheel-sync-up)'
		" ---- load / Save
		" -- wheel
		exe nmap prefix .. 'r <plug>(wheel-read-wheel)'
		exe nmap prefix .. 'w <plug>(wheel-write-wheel)'
		" -- session file
		exe nmap prefix .. 'R <plug>(wheel-read-session)'
		exe nmap prefix .. 'W <plug>(wheel-write-session)'
		" ---- navigate in the wheel
		" -- next / previous
		exe nmap prefix .. '<left> <plug>(wheel-previous-location)'
		exe nmap prefix .. '<right> <plug>(wheel-next-location)'
		exe nmap prefix .. '<c-left> <plug>(wheel-previous-circle)'
		exe nmap prefix .. '<c-right> <plug>(wheel-next-circle)'
		exe nmap prefix .. '<s-left> <plug>(wheel-previous-torus)'
		exe nmap prefix .. '<s-right> <plug>(wheel-next-torus)'
		" -- history
		exe nmap prefix .. '<up> <plug>(wheel-history-newer)'
		exe nmap prefix .. '<down> <plug>(wheel-history-older)'
		exe nmap prefix .. '<c-up> <plug>(wheel-history-newer-in-circle)'
		exe nmap prefix .. '<c-down> <plug>(wheel-history-older-in-circle)'
		exe nmap prefix .. '<s-up> <plug>(wheel-history-newer-in-torus)'
		exe nmap prefix .. '<s-down> <plug>(wheel-history-older-in-torus)'
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
		exe nmap prefix .. '<m-x> <plug>(wheel-dedibuf-tree)'
		exe nmap prefix .. '<m-s-x> <plug>(wheel-dedibuf-index-circles)'
		" -- history
		exe nmap prefix .. 'h <plug>(wheel-prompt-history)'
		" ---- organize wheel
		exe nmap prefix .. '<m-h> <plug>(wheel-dedibuf-history)'
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
		" -- copy
		exe nmap prefix .. 'c <plug>(wheel-prompt-copy-location)'
		" <c-c> does not work in maps
		exe nmap prefix .. '<m-c> <plug>(wheel-prompt-copy-circle)'
		exe nmap prefix .. 'C <plug>(wheel-prompt-copy-torus)'
		" -- move
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
		exe nmap prefix .. 'b <plug>(wheel-prompt-buffers)'
		exe nmap prefix .. '<m-b> <plug>(wheel-dedibuf-buffers)'
		exe nmap prefix .. '<c-b> <plug>(wheel-dedibuf-buffers-all)'
		" -- tabs & windows : visible buffers
		exe nmap prefix .. 'v <plug>(wheel-prompt-tabwin)'
		exe nmap prefix .. '<m-v> <plug>(wheel-dedibuf-tabwins-tree)'
		exe nmap prefix .. '<c-v> <plug>(wheel-dedibuf-tabwins)'
		" -- (neo)vim lists
		exe nmap prefix .. "' <plug>(wheel-prompt-marker)"
		exe nmap prefix .. 'j <plug>(wheel-prompt-jump)'
		exe nmap prefix .. ', <plug>(wheel-prompt-change)'
		exe nmap prefix .. 't <plug>(wheel-prompt-tag)'
		exe nmap prefix .. "<m-'> <plug>(wheel-dedibuf-markers)"
		exe nmap prefix .. '<m-j> <plug>(wheel-dedibuf-jumps)'
		exe nmap prefix .. '; <plug>(wheel-dedibuf-changes)'
		exe nmap prefix .. '<m-t> <plug>(wheel-dedibuf-tags)'
		" ---- reorganize wheel
		exe nmap prefix .. '<m-r> <plug>(wheel-dedibuf-reorganize)'
		" ---- reorganize other things
		exe nmap prefix .. '<c-r> <plug>(wheel-dedibuf-reorg-tabwins)'
		" ---- refactor
		exe nmap prefix .. '<m-g> <plug>(wheel-dedibuf-grep-edit)'
		exe nmap prefix .. '-% <plug>(wheel-dedibuf-narrow)'
		exe nmap prefix .. '-- <plug>(wheel-dedibuf-narrow-operator)'
		exe vmap prefix .. '-- <plug>(wheel-dedibuf-narrow)'
		exe nmap prefix .. '-c <plug>(wheel-dedibuf-narrow-circle)'
		" ---- search
		" -- files
		exe nmap prefix .. 'l <plug>(wheel-dedibuf-locate)'
		exe nmap prefix .. 'f <plug>(wheel-dedibuf-find)'
		exe nmap prefix .. async .. 'f <plug>(wheel-dedibuf-async-find)'
		exe nmap prefix .. 'u <plug>(wheel-prompt-mru)'
		exe nmap prefix .. '<m-u> <plug>(wheel-dedibuf-mru)'
		" -- inside files
		exe nmap prefix .. 'o <plug>(wheel-prompt-occur)'
		exe nmap prefix .. '<m-o> <plug>(wheel-dedibuf-occur)'
		exe nmap prefix .. 'g <plug>(wheel-dedibuf-grep)'
		exe nmap prefix .. '<c-o> <plug>(wheel-dedibuf-outline)'
		" ---- yank ring
		exe nmap prefix .. 'y <plug>(wheel-dedibuf-yank-list)'
		exe nmap prefix .. 'p <plug>(wheel-dedibuf-yank-plain)'
		" ---- undo list
		exe nmap prefix .. '<c-u> <plug>(wheel-dedibuf-undo-list)'
		" ---- generic ex or shell command
		exe nmap prefix .. ': <plug>(wheel-dedibuf-command)'
		exe nmap prefix .. async .. '& <plug>(wheel-dedibuf-async)'
		" ---- dedicated buffers
		exe nmap prefix .. '<tab> <plug>(wheel-mandala-add)'
		exe nmap prefix .. '<backspace> <plug>(wheel-mandala-delete)'
		exe nmap prefix .. '<home> <plug>(wheel-mandala-backward)'
		exe nmap prefix .. '<end>  <plug>(wheel-mandala-forward)'
		exe nmap prefix .. '<m-space> <plug>(wheel-mandala-switch)'
		" ---- layouts
		exe nmap prefix .. layout .. 'z <plug>(wheel-zoom)'
		" -- tabs
		exe nmap prefix .. layout .. 't <plug>(wheel-tabs-locations)'
		exe nmap prefix .. layout .. '<c-t> <plug>(wheel-tabs-circles)'
		exe nmap prefix .. layout .. 'T <plug>(wheel-tabs-toruses)'
		" -- windows
		exe nmap prefix .. layout .. 's <plug>(wheel-split-locations)'
		exe nmap prefix .. layout .. '<c-s> <plug>(wheel-split-circles)'
		exe nmap prefix .. layout .. 'S <plug>(wheel-split-toruses)'
		exe nmap prefix .. layout .. 'v <plug>(wheel-vsplit-locations)'
		exe nmap prefix .. layout .. '<c-v> <plug>(wheel-vsplit-circles)'
		exe nmap prefix .. layout .. 'V <plug>(wheel-vsplit-toruses)'
		" -- main top
		exe nmap prefix .. layout .. 'm <plug>(wheel-main-top-locations)'
		exe nmap prefix .. layout .. '<c-m> <plug>(wheel-main-top-circles)'
		exe nmap prefix .. layout .. 'M <plug>(wheel-main-top-toruses)'
		" -- main left
		exe nmap prefix .. layout .. 'l <plug>(wheel-main-left-locations)'
		exe nmap prefix .. layout .. '<c-l> <plug>(wheel-main-left-circles)'
		exe nmap prefix .. layout .. 'L <plug>(wheel-main-left-toruses)'
		" -- grid
		exe nmap prefix .. layout .. 'g <plug>(wheel-grid-locations)'
		exe nmap prefix .. layout .. '<c-g> <plug>(wheel-grid-circles)'
		exe nmap prefix .. layout .. 'G <plug>(wheel-grid-toruses)'
		" -- tabs & windows
		exe nmap prefix .. layout .. '& <plug>(wheel-tab-win-circle)'
		exe nmap prefix .. layout .. '<M-&> <plug>(wheel-tab-win-torus)'
		" -- rotating windows
		exe nmap prefix .. layout .. '<up> <plug>(wheel-rotate-counter-clockwise)'
		exe nmap prefix .. layout .. '<down> <plug>(wheel-rotate-clockwise)'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Menus
		exe nmap '<m-m>          <plug>(wheel-menu-main)'
		exe nmap '<m-=>          <plug>(wheel-menu-meta)'
		" Sync
		exe nmap '<m-i>          <plug>(wheel-dashboard)'
		exe nmap '<c-$>          <plug>(wheel-sync-down)'
		exe nmap '<m-$>          <plug>(wheel-sync-up)'
		" ---- navigate in the wheel
		" --  next / previous
		exe nmap '<c-pageup>     <plug>(wheel-previous-location)'
		exe nmap '<c-pagedown>   <plug>(wheel-next-location)'
		exe nmap '<c-home>       <plug>(wheel-previous-circle)'
		exe nmap '<c-end>        <plug>(wheel-next-circle)'
		exe nmap '<s-home>       <plug>(wheel-previous-torus)'
		exe nmap '<s-end>        <plug>(wheel-next-torus)'
		" -- switch
		exe nmap '<m-cr>        <plug>(wheel-prompt-location)'
		exe nmap '<c-cr>        <plug>(wheel-prompt-circle)'
		exe nmap '<s-cr>        <plug>(wheel-prompt-torus)'
		exe nmap '<space>       <plug>(wheel-dedibuf-location)'
		exe nmap '<c-space>     <plug>(wheel-dedibuf-circle)'
		exe nmap '<s-space>     <plug>(wheel-dedibuf-torus)'
		" -- index
		exe nmap '<m-x>         <plug>(wheel-prompt-index)'
		exe nmap '<m-s-x>       <plug>(wheel-dedibuf-index)'
		exe nmap '<m-c-x>       <plug>(wheel-dedibuf-tree)'
		" -- history
		exe nmap '<m-pageup>     <plug>(wheel-history-newer)'
		exe nmap '<m-pagedown>   <plug>(wheel-history-older)'
		exe nmap '<m-c-pageup>     <plug>(wheel-history-newer-in-circle)'
		exe nmap '<m-c-pagedown>   <plug>(wheel-history-older-in-circle)'
		exe nmap '<m-s-pageup>     <plug>(wheel-history-newer-in-torus)'
		exe nmap '<m-s-pagedown>   <plug>(wheel-history-older-in-torus)'
		exe nmap '<m-h>         <plug>(wheel-prompt-history)'
		exe nmap '<m-c-h>       <plug>(wheel-dedibuf-history)'
		" -- alternate
		exe nmap '<c-^>          <plug>(wheel-alternate-anywhere)'
		exe nmap '<m-^>          <plug>(wheel-alternate-same-circle)'
		exe nmap '<m-c-^>        <plug>(wheel-alternate-same-torus-other-circle)'
		" ---- navigate with vim native tools
		" -- buffers
		exe nmap '<m-b>          <plug>(wheel-prompt-buffers)'
		exe nmap '<m-c-b>        <plug>(wheel-dedibuf-buffers)'
		exe nmap '<m-s-b>        <plug>(wheel-dedibuf-buffers-all)'
		" -- tabs & windows : visible buffers
		exe nmap '<m-v>          <plug>(wheel-prompt-tabwin)'
		exe nmap '<m-c-v>        <plug>(wheel-dedibuf-tabwins-tree)'
		exe nmap '<m-s-v>        <plug>(wheel-dedibuf-tabwins)'
		" -- (neo)vim lists
		exe nmap "<m-'>          <plug>(wheel-prompt-marker)"
		exe nmap "<m-k>          <plug>(wheel-prompt-marker)"
		exe nmap '<m-j>          <plug>(wheel-prompt-jump)'
		exe nmap '<m-,>          <plug>(wheel-prompt-change)'
		exe nmap '<m-c>          <plug>(wheel-prompt-change)'
		exe nmap '<m-t>          <plug>(wheel-prompt-tag)'
		exe nmap "<m-c-k>        <plug>(wheel-dedibuf-markers)"
		exe nmap '<m-c-j>        <plug>(wheel-dedibuf-jumps)'
		exe nmap '<m-;>          <plug>(wheel-dedibuf-changes)'
		exe nmap '<m-c-t>        <plug>(wheel-dedibuf-tags)'
		" ---- organize the wheel
		exe nmap '<m-insert>     <plug>(wheel-prompt-add-here)'
		exe nmap '<m-del>        <plug>(wheel-prompt-delete-location)'
		exe nmap '<m-r>          <plug>(wheel-dedibuf-reorganize)'
		" ---- organize other things
		exe nmap '<m-c-r>        <plug>(wheel-dedibuf-reorg-tabwins)'
		" ---- refactor
		exe nmap '<m-c-g>        <plug>(wheel-dedibuf-grep-edit)'
		exe nmap '<m-n>          <plug>(wheel-dedibuf-narrow-operator)'
		exe vmap '<m-n>          <plug>(wheel-dedibuf-narrow)'
		exe nmap '<m-c-n>        <plug>(wheel-dedibuf-narrow-circle)'
		" ---- search
		" -- files
		exe nmap '<m-l>          <plug>(wheel-dedibuf-locate)'
		exe nmap '<m-f>          <plug>(wheel-dedibuf-find)'
		exe nmap '<m-c-f>        <plug>(wheel-dedibuf-async-find)'
		exe nmap '<m-u>          <plug>(wheel-prompt-mru)'
		exe nmap '<m-c-u>        <plug>(wheel-dedibuf-mru)'
		" -- inside files
		exe nmap '<m-o>          <plug>(wheel-prompt-occur)'
		exe nmap '<m-c-o>        <plug>(wheel-dedibuf-occur)'
		exe nmap '<m-g>          <plug>(wheel-dedibuf-grep)'
		exe nmap '<m-s-o>        <plug>(wheel-dedibuf-outline)'
		" ---- yank ring
		exe nmap '<m-y>          <plug>(wheel-dedibuf-yank-list)'
		exe nmap '<m-p>          <plug>(wheel-dedibuf-yank-plain)'
		" ---- undo list
		exe nmap '<m-s-u>        <plug>(wheel-dedibuf-undo-list)'
		" ---- ex or shell command output
		exe nmap '<m-!>          <plug>(wheel-dedibuf-command)'
		exe nmap '<m-&>          <plug>(wheel-dedibuf-async)'
		" ---- dedicated buffers
		exe nmap '<m-tab>        <plug>(wheel-mandala-add)'
		exe nmap '<m-backspace>  <plug>(wheel-mandala-delete)'
		exe nmap '<m-home>        <plug>(wheel-mandala-backward)'
		exe nmap '<m-end>         <plug>(wheel-mandala-forward)'
		exe nmap '<m-space>      <plug>(wheel-mandala-switch)'
		" ---- layouts
		exe nmap '<m-z>          <plug>(wheel-zoom)'
		exe nmap '<s-pageup>     <plug>(wheel-rotate-counter-clockwise)'
		exe nmap '<s-pagedown>   <plug>(wheel-rotate-clockwise)'
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe nmap prefix .. debug .. 'Z <plug>(wheel-debug-fresh-wheel)'
		exe nmap prefix .. debug .. 'c <plug>(wheel-debug-clear-echo-area)'
		exe nmap prefix .. debug .. 'h <plug>(wheel-debug-prompt-history-circuit)'
		exe nmap prefix .. debug .. '<m-h> <plug>(wheel-debug-dedibuf-history-circuit)'
	endif
endfun
