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
	" Menus
	nnoremap <plug>(wheel-menu-main) :call wheel#hub#main()<cr>
	nnoremap <plug>(wheel-menu-meta) :call wheel#hub#meta()<cr>
	" Dashboard
	nnoremap <plug>(wheel-dashboard) :call wheel#status#dashboard()<cr>
	" Sync up : follow
	nnoremap <plug>(wheel-sync-up) :call wheel#projection#follow()<cr>
	" Sync down : jump
	nnoremap <plug>(wheel-sync-down) :call wheel#vortex#jump()<cr>
	" Load / Save wheel
	nnoremap <plug>(wheel-read-wheel) :call wheel#disc#read_all()<cr>
	nnoremap <plug>(wheel-write-wheel) :call wheel#disc#write_all()<cr>
	" Load / Save session
	nnoremap <plug>(wheel-read-session) :call wheel#disc#read_session()<cr>
	nnoremap <plug>(wheel-write-session) :call wheel#disc#write_session()<cr>
	" Next / Previous
	nnoremap <plug>(wheel-previous-location) :call wheel#vortex#previous('location')<cr>
	nnoremap <plug>(wheel-next-location) :call wheel#vortex#next('location')<cr>
	nnoremap <plug>(wheel-previous-circle) :call wheel#vortex#previous('circle')<cr>
	nnoremap <plug>(wheel-next-circle) :call wheel#vortex#next('circle')<cr>
	nnoremap <plug>(wheel-previous-torus) :call wheel#vortex#previous('torus')<cr>
	nnoremap <plug>(wheel-next-torus) :call wheel#vortex#next('torus')<cr>
	nnoremap <plug>(wheel-history-newer) :call wheel#pendulum#newer()<cr>
	nnoremap <plug>(wheel-history-older) :call wheel#pendulum#older()<cr>
	" Alternate
	nnoremap <plug>(wheel-alternate-anywhere) :call wheel#pendulum#alternate('anywhere')<cr>
	nnoremap <plug>(wheel-alternate-same-torus-other-circle) :call wheel#pendulum#alternate('same_torus_other_circle')<cr>
	nnoremap <plug>(wheel-alternate-same-torus) :call wheel#pendulum#alternate('same_torus')<cr>
	nnoremap <plug>(wheel-alternate-same-circle) :call wheel#pendulum#alternate('same_circle')<cr>
	nnoremap <plug>(wheel-alternate-other-torus) :call wheel#pendulum#alternate('other_torus')<cr>
	nnoremap <plug>(wheel-alternate-other-circle) :call wheel#pendulum#alternate('other_circle')<cr>
	nnoremap <plug>(wheel-alternate-menu) :call wheel#pendulum#alternate_menu()<cr>
	" Add
	nnoremap <plug>(wheel-prompt-add-here) :call wheel#tree#add_here()<cr>
	nnoremap <plug>(wheel-prompt-add-circle) :call wheel#tree#add_circle()<cr>
	nnoremap <plug>(wheel-prompt-add-torus) :call wheel#tree#add_torus()<cr>
	nnoremap <plug>(wheel-prompt-add-file) :call wheel#tree#add_file()<cr>
	nnoremap <plug>(wheel-prompt-add-buffer) :call wheel#tree#add_buffer()<cr>
	nnoremap <plug>(wheel-prompt-add-glob) :call wheel#tree#add_glob()<cr>
	" Rename
	nnoremap <plug>(wheel-prompt-rename-location) :call wheel#tree#rename('location')<cr>
	nnoremap <plug>(wheel-prompt-rename-circle) :call wheel#tree#rename('circle')<cr>
	nnoremap <plug>(wheel-prompt-rename-torus) :call wheel#tree#rename('torus')<cr>
	nnoremap <plug>(wheel-prompt-rename-file) :call wheel#tree#rename_file()<cr>
	" Delete
	nnoremap <plug>(wheel-prompt-delete-location) :call wheel#tree#delete('location')<cr>
	nnoremap <plug>(wheel-prompt-delete-circle) :call wheel#tree#delete('circle')<cr>
	nnoremap <plug>(wheel-prompt-delete-torus) :call wheel#tree#delete('torus')<cr>
	" Copy
	nnoremap <plug>(wheel-prompt-copy-location) :call wheel#tree#copy('location')<cr>
	nnoremap <plug>(wheel-prompt-copy-circle) :call wheel#tree#copy('circle')<cr>
	nnoremap <plug>(wheel-prompt-copy-torus) :call wheel#tree#copy('torus')<cr>
	" Move
	nnoremap <plug>(wheel-prompt-move-location) :call wheel#tree#move('location')<cr>
	nnoremap <plug>(wheel-prompt-move-circle) :call wheel#tree#move('circle')<cr>
	" Switch
	nnoremap <plug>(wheel-prompt-location) :call wheel#vortex#switch('location')<cr>
	nnoremap <plug>(wheel-prompt-circle) :call wheel#vortex#switch('circle')<cr>
	nnoremap <plug>(wheel-prompt-torus) :call wheel#vortex#switch('torus')<cr>
	nnoremap <plug>(wheel-prompt-multi-switch) :call wheel#vortex#multi_switch()<cr>
	nnoremap <plug>(wheel-dedibuf-location) :call wheel#sailing#switch('location')<cr>
	nnoremap <plug>(wheel-dedibuf-circle) :call wheel#sailing#switch('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-torus) :call wheel#sailing#switch('torus')<cr>
	" Indexes
	nnoremap <plug>(wheel-prompt-index) :call wheel#vortex#helix()<cr>
	nnoremap <plug>(wheel-dedibuf-index) :call wheel#sailing#helix()<cr>
	nnoremap <plug>(wheel-dedibuf-index-circles) :call wheel#sailing#grid()<cr>
	nnoremap <plug>(wheel-dedibuf-tree) :call wheel#sailing#tree()<cr>
	" History
	nnoremap <plug>(wheel-prompt-history) :call wheel#vortex#history()<cr>
	nnoremap <plug>(wheel-dedibuf-history) :call wheel#sailing#history()<cr>
	" Search for files
	nnoremap <plug>(wheel-dedibuf-locate) :call wheel#sailing#locate()<cr>
	nnoremap <plug>(wheel-dedibuf-find) :call wheel#sailing#find()<cr>
	nnoremap <plug>(wheel-dedibuf-async-find) :call wheel#sailing#async_find()<cr>
	nnoremap <plug>(wheel-dedibuf-mru) :call wheel#sailing#mru()<cr>
	" Buffers
	nnoremap <plug>(wheel-dedibuf-buffers) :call wheel#sailing#buffers()<cr>
	nnoremap <plug>(wheel-dedibuf-buffers-all) :call wheel#sailing#buffers('all')<cr>
	" Tabs & windows : visible buffers
	nnoremap <plug>(wheel-prompt-tabwin) :call wheel#rectangle#switch()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwins) :call wheel#sailing#tabwins()<cr>
	nnoremap <plug>(wheel-dedibuf-tabwins-tree) :call wheel#sailing#tabwins_tree()<cr>
	" Search inside files
	nnoremap <plug>(wheel-dedibuf-occur) :call wheel#sailing#occur()<cr>
	nnoremap <plug>(wheel-dedibuf-grep) :call wheel#sailing#grep()<cr>
	nnoremap <plug>(wheel-dedibuf-outline) :call wheel#sailing#outline()<cr>
	" (neo)vim lists, prompt completion
	nnoremap <plug>(wheel-prompt-marker) :call wheel#whirl#marker()<cr>
	nnoremap <plug>(wheel-prompt-jump) :call wheel#whirl#jump()<cr>
	nnoremap <plug>(wheel-prompt-change) :call wheel#whirl#change()<cr>
	nnoremap <plug>(wheel-prompt-tag) :call wheel#whirl#tag()<cr>
	" (neo)vim lists, dedicated buffer
	nnoremap <plug>(wheel-dedibuf-markers) :call wheel#sailing#markers()<cr>
	nnoremap <plug>(wheel-dedibuf-jumps) :call wheel#sailing#jumps()<cr>
	nnoremap <plug>(wheel-dedibuf-changes) :call wheel#sailing#changes()<cr>
	nnoremap <plug>(wheel-dedibuf-tags) :call wheel#sailing#tags()<cr>
	" Yank wheel
	nnoremap <plug>(wheel-dedibuf-yank-list) :call wheel#clipper#yank('list')<cr>
	nnoremap <plug>(wheel-dedibuf-yank-plain) :call wheel#clipper#yank('plain')<cr>
	" Reorder
	nnoremap <plug>(wheel-dedibuf-reorder-location) :call wheel#shape#reorder('location')<cr>
	nnoremap <plug>(wheel-dedibuf-reorder-circle) :call wheel#shape#reorder('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-reorder-torus) :call wheel#shape#reorder('torus')<cr>
	" Batch rename
	nnoremap <plug>(wheel-dedibuf-rename-location) :call wheel#shape#rename('location')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-circle) :call wheel#shape#rename('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-torus) :call wheel#shape#rename('torus')<cr>
	nnoremap <plug>(wheel-dedibuf-rename-location-filename) :call wheel#shape#rename_files()<cr>
	" Batch copy/move
	nnoremap <plug>(wheel-dedibuf-copy-move-location) :call wheel#shape#copy_move('location')<cr>
	nnoremap <plug>(wheel-dedibuf-copy-move-circle) :call wheel#shape#copy_move('circle')<cr>
	nnoremap <plug>(wheel-dedibuf-copy-move-torus) :call wheel#shape#copy_move('torus')<cr>
	" Reorganize
	nnoremap <plug>(wheel-dedibuf-reorganize) :call wheel#shape#reorganize()<cr>
	" Reorganize tabs & windows
	nnoremap <plug>(wheel-dedibuf-reorg-tabwins) :call wheel#shape#reorg_tabwins()<cr>
	" Grep edit mode
	nnoremap <plug>(wheel-dedibuf-grep-edit) :call wheel#shape#grep_edit()<cr>
	" Undo list
	nnoremap <plug>(wheel-dedibuf-undo-list) :call wheel#delta#undolist()<cr>
	" Generic buffer from ex or shell command output
	nnoremap <plug>(wheel-dedibuf-command) :call wheel#mandala#command()<cr>
	nnoremap <plug>(wheel-dedibuf-async) :call wheel#mandala#async()<cr>
	" Add new mandala buffer
	nnoremap <plug>(wheel-mandala-add) :call wheel#cylinder#add()<cr>
	" Delete mandala buffer
	nnoremap <plug>(wheel-mandala-delete) :call wheel#cylinder#delete()<cr>
	" Cycle mandala buffers
	nnoremap <plug>(wheel-mandala-forward) :call wheel#cylinder#forward()<cr>
	nnoremap <plug>(wheel-mandala-backward) :call wheel#cylinder#backward()<cr>
	" Switch mandala buffer
	nnoremap <plug>(wheel-mandala-switch) :call wheel#cylinder#switch()<cr>
	" Layouts
	nnoremap <plug>(wheel-zoom) :call wheel#mosaic#zoom()<cr>
	" Tabs
	nnoremap <plug>(wheel-tabs-locations) :call wheel#mosaic#tabs('location')<cr>
	nnoremap <plug>(wheel-tabs-circles) :call wheel#mosaic#tabs('circle')<cr>
	nnoremap <plug>(wheel-tabs-toruses) :call wheel#mosaic#tabs('torus')<cr>
	" Windows
	nnoremap <plug>(wheel-split-locations) :call wheel#mosaic#split('location')<cr>
	nnoremap <plug>(wheel-split-circles) :call wheel#mosaic#split('circle')<cr>
	nnoremap <plug>(wheel-split-toruses) :call wheel#mosaic#split('torus')<cr>
	nnoremap <plug>(wheel-vsplit-locations) :call wheel#mosaic#split('location', 'vertical')<cr>
	nnoremap <plug>(wheel-vsplit-circles) :call wheel#mosaic#split('circle', 'vertical')<cr>
	nnoremap <plug>(wheel-vsplit-toruses) :call wheel#mosaic#split('torus', 'vertical')<cr>
	nnoremap <plug>(wheel-main-top-locations) :call wheel#mosaic#split('location', 'main_top')<cr>
	nnoremap <plug>(wheel-main-top-circles) :call wheel#mosaic#split('circle', 'main_top')<cr>
	nnoremap <plug>(wheel-main-top-toruses) :call wheel#mosaic#split('torus', 'main_top')<cr>
	nnoremap <plug>(wheel-main-left-locations) :call wheel#mosaic#split('location', 'main_left')<cr>
	nnoremap <plug>(wheel-main-left-circles) :call wheel#mosaic#split('circle', 'main_left')<cr>
	nnoremap <plug>(wheel-main-left-toruses) :call wheel#mosaic#split('torus', 'main_left')<cr>
	nnoremap <plug>(wheel-grid-locations) :call wheel#mosaic#split_grid('location')<cr>
	nnoremap <plug>(wheel-grid-circles) :call wheel#mosaic#split_grid('circle')<cr>
	nnoremap <plug>(wheel-grid-toruses) :call wheel#mosaic#split_grid('torus')<cr>
	" Tabs & Windows
	nnoremap <plug>(wheel-tab-win-torus) :call wheel#pyramid#steps('torus')<cr>
	nnoremap <plug>(wheel-tab-win-circle) :call wheel#pyramid#steps('circle')<cr>
	" Rotating windows
	nnoremap <plug>(wheel-rotate-counter-clockwise) :call wheel#mosaic#rotate_counter_clockwise()<cr>
	nnoremap <plug>(wheel-rotate-clockwise) :call wheel#mosaic#rotate_clockwise()<cr>
	" Debug
	nnoremap <plug>(wheel-debug-fresh-wheel) :call wheel#void#fresh_wheel()<cr>
	" Misc
	nnoremap <plug>(wheel-spiral-cursor) :call wheel#spiral#cursor()<cr>
endfun

fun! wheel#centre#cables ()
	" Link keys to <plug> mappings
	" general prefix
	let prefix = g:wheel_config.prefix
	" batch subprefix
	let batch = '@'
	" async subprefix
	let async = '&'
	" layout subprefix
	let lay = 'z'
	" maps arguments
	let nmap = 'nmap <silent>'
	" Basic
	if g:wheel_config.mappings >= 0
		" Menus
		exe nmap prefix .. '<m-m> <plug>(wheel-menu-main)'
		exe nmap prefix .. '= <plug>(wheel-menu-meta)'
		" Dashboard, info
		exe nmap prefix .. 'i <plug>(wheel-dashboard)'
		" Sync up : follow
		exe nmap prefix .. '<m-$> <plug>(wheel-sync-up)'
		" Sync down : jump
		exe nmap prefix .. '$ <plug>(wheel-sync-down)'
		" Load / Save wheel
		exe nmap prefix .. 'r <plug>(wheel-read-wheel)'
		exe nmap prefix .. 'w <plug>(wheel-write-wheel)'
		" Load / Save session file
		exe nmap prefix .. 'R <plug>(wheel-read-session)'
		exe nmap prefix .. 'W <plug>(wheel-write-session)'
		" Next / Previous
		exe nmap prefix .. '<left> <plug>(wheel-previous-location)'
		exe nmap prefix .. '<right> <plug>(wheel-next-location)'
		exe nmap prefix .. '<c-left> <plug>(wheel-previous-circle)'
		exe nmap prefix .. '<c-right> <plug>(wheel-next-circle)'
		exe nmap prefix .. '<s-left> <plug>(wheel-previous-torus)'
		exe nmap prefix .. '<s-right> <plug>(wheel-next-torus)'
		" History
		exe nmap prefix .. '<up> <plug>(wheel-history-newer)'
		exe nmap prefix .. '<down> <plug>(wheel-history-older)'
		" Alternate
		exe nmap prefix .. '<c-^> <plug>(wheel-alternate-anywhere)'
		exe nmap prefix .. '<m-^> <plug>(wheel-alternate-same-circle)'
		exe nmap prefix .. '<m-c-^> <plug>(wheel-alternate-same-torus-other-circle)'
		exe nmap prefix .. '^ <plug>(wheel-alternate-menu)'
		" Add
		exe nmap prefix .. 'a <plug>(wheel-prompt-add-here)'
		exe nmap prefix .. '<c-a> <plug>(wheel-prompt-add-circle)'
		exe nmap prefix .. 'A <plug>(wheel-prompt-add-torus)'
		exe nmap prefix .. '+f <plug>(wheel-prompt-add-file)'
		exe nmap prefix .. '+b <plug>(wheel-prompt-add-buffer)'
		exe nmap prefix .. '* <plug>(wheel-prompt-add-glob)'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Switch
		exe nmap prefix .. '<cr> <plug>(wheel-prompt-location)'
		exe nmap prefix .. '<c-cr> <plug>(wheel-prompt-circle)'
		exe nmap prefix .. '<s-cr> <plug>(wheel-prompt-torus)'
		exe nmap prefix .. '<m-cr> <plug>(wheel-prompt-multi-switch)'
		exe nmap prefix .. '<space> <plug>(wheel-dedibuf-location)'
		exe nmap prefix .. '<c-space> <plug>(wheel-dedibuf-circle)'
		exe nmap prefix .. '<s-space> <plug>(wheel-dedibuf-torus)'
		" Indexes
		exe nmap prefix .. 'x <plug>(wheel-prompt-index)'
		exe nmap prefix .. 'X <plug>(wheel-dedibuf-index)'
		exe nmap prefix .. '<c-x> <plug>(wheel-dedibuf-index-circles)'
		exe nmap prefix .. '<m-x> <plug>(wheel-dedibuf-tree)'
		" History
		exe nmap prefix .. 'h <plug>(wheel-prompt-history)'
		exe nmap prefix .. '<m-h> <plug>(wheel-dedibuf-history)'
		" Rename
		exe nmap prefix .. 'n <plug>(wheel-prompt-rename-location)'
		exe nmap prefix .. '<c-n> <plug>(wheel-prompt-rename-circle)'
		exe nmap prefix .. 'N <plug>(wheel-prompt-rename-torus)'
		exe nmap prefix .. '<m-n> <plug>(wheel-prompt-rename-file)'
		" Delete
		exe nmap prefix .. 'd <plug>(wheel-prompt-delete-location)'
		exe nmap prefix .. '<c-d> <plug>(wheel-prompt-delete-circle)'
		exe nmap prefix .. 'D <plug>(wheel-prompt-delete-torus)'
		" Copy
		exe nmap prefix .. 'c <plug>(wheel-prompt-copy-location)'
		" <c-c> does not work in maps
		exe nmap prefix .. '<m-c> <plug>(wheel-prompt-copy-circle)'
		exe nmap prefix .. 'C <plug>(wheel-prompt-copy-torus)'
		" Move
		exe nmap prefix .. 'm <plug>(wheel-prompt-move-location)'
		exe nmap prefix .. 'M <plug>(wheel-prompt-move-circle)'
		" Reorder
		exe nmap prefix .. 'o <plug>(wheel-dedibuf-reorder-location)'
		exe nmap prefix .. '<c-o> <plug>(wheel-dedibuf-reorder-circle)'
		exe nmap prefix .. 'O <plug>(wheel-dedibuf-reorder-torus)'
		" Batch rename
		exe nmap prefix .. batch .. 'n <plug>(wheel-dedibuf-rename-location)'
		exe nmap prefix .. batch .. '<c-n> <plug>(wheel-dedibuf-rename-circle)'
		exe nmap prefix .. batch .. 'N <plug>(wheel-dedibuf-rename-torus)'
		exe nmap prefix .. batch .. '<m-n> <plug>(wheel-dedibuf-rename-location-filename)'
		" Batch copy/move
		exe nmap prefix .. batch .. 'c <plug>(wheel-dedibuf-copy-move-location)'
		exe nmap prefix .. batch .. '<m-c> <plug>(wheel-dedibuf-copy-move-circle)'
		exe nmap prefix .. batch .. 'C <plug>(wheel-dedibuf-copy-move-torus)'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" Search for files
		exe nmap prefix .. 'l <plug>(wheel-dedibuf-locate)'
		exe nmap prefix .. 'f <plug>(wheel-dedibuf-find)'
		exe nmap prefix .. async .. 'f <plug>(wheel-dedibuf-async-find)'
		exe nmap prefix .. 'u <plug>(wheel-dedibuf-mru)'
		" Buffers
		exe nmap prefix .. 'b <plug>(wheel-dedibuf-buffers)'
		exe nmap prefix .. 'B <plug>(wheel-dedibuf-buffers-all)'
		" Tabs & windows : visible buffers
		exe nmap prefix .. 'v <plug>(wheel-prompt-tabwin)'
		exe nmap prefix .. 'V <plug>(wheel-dedibuf-tabwins)'
		exe nmap prefix .. '<m-v> <plug>(wheel-dedibuf-tabwins-tree)'
		" Search inside files
		exe nmap prefix .. 's <plug>(wheel-dedibuf-occur)'
		exe nmap prefix .. 'g <plug>(wheel-dedibuf-grep)'
		exe nmap prefix .. '<m-o> <plug>(wheel-dedibuf-outline)'
		" (neo)vim lists
		exe nmap prefix .. "' <plug>(wheel-prompt-marker)"
		exe nmap prefix .. 'j <plug>(wheel-prompt-jump)'
		exe nmap prefix .. '; <plug>(wheel-prompt-change)'
		exe nmap prefix .. 't <plug>(wheel-prompt-tag)'
		exe nmap prefix .. "<m-'> <plug>(wheel-dedibuf-markers)"
		exe nmap prefix .. '<m-j> <plug>(wheel-dedibuf-jumps)'
		exe nmap prefix .. ', <plug>(wheel-dedibuf-changes)'
		exe nmap prefix .. '<m-t> <plug>(wheel-dedibuf-tags)'
		" Yank wheel
		exe nmap prefix .. 'y <plug>(wheel-dedibuf-yank-list)'
		exe nmap prefix .. 'p <plug>(wheel-dedibuf-yank-plain)'
		" Reorganize
		" wheel
		exe nmap prefix .. '<m-r> <plug>(wheel-dedibuf-reorganize)'
		" tabs & windows
		exe nmap prefix .. '<c-r> <plug>(wheel-dedibuf-reorg-tabwins)'
		" grep edit
		exe nmap prefix .. '<m-g> <plug>(wheel-dedibuf-grep-edit)'
		" Undo list
		exe nmap prefix .. '<m-u> <plug>(wheel-dedibuf-undo-list)'
		" Generic ex or shell command
		exe nmap prefix .. ': <plug>(wheel-dedibuf-command)'
		exe nmap prefix .. async .. '& <plug>(wheel-dedibuf-async)'
		" Add new mandala buffer
		exe nmap prefix .. '<tab> <plug>(wheel-mandala-add)'
		" Delete mandala buffer
		exe nmap prefix .. '<backspace> <plug>(wheel-mandala-delete)'
		" Cycle mandala buffers
		exe nmap prefix .. '<home> <plug>(wheel-mandala-backward)'
		exe nmap prefix .. '<end>  <plug>(wheel-mandala-forward)'
		" Switch mandala buffer
		exe nmap prefix .. '<m-space> <plug>(wheel-mandala-switch)'
		" Layouts
		exe nmap prefix .. lay .. 'z <plug>(wheel-zoom)'
		" Tabs
		exe nmap prefix .. lay .. 't <plug>(wheel-tabs-locations)'
		exe nmap prefix .. lay .. '<c-t> <plug>(wheel-tabs-circles)'
		exe nmap prefix .. lay .. 'T <plug>(wheel-tabs-toruses)'
		" Windows
		exe nmap prefix .. lay .. 's <plug>(wheel-split-locations)'
		exe nmap prefix .. lay .. '<c-s> <plug>(wheel-split-circles)'
		exe nmap prefix .. lay .. 'S <plug>(wheel-split-toruses)'
		exe nmap prefix .. lay .. 'v <plug>(wheel-vsplit-locations)'
		exe nmap prefix .. lay .. '<c-v> <plug>(wheel-vsplit-circles)'
		exe nmap prefix .. lay .. 'V <plug>(wheel-vsplit-toruses)'
		" Main top
		exe nmap prefix .. lay .. 'm <plug>(wheel-main-top-locations)'
		exe nmap prefix .. lay .. '<c-m> <plug>(wheel-main-top-circles)'
		exe nmap prefix .. lay .. 'M <plug>(wheel-main-top-toruses)'
		" Main left
		exe nmap prefix .. lay .. 'l <plug>(wheel-main-left-locations)'
		exe nmap prefix .. lay .. '<c-l> <plug>(wheel-main-left-circles)'
		exe nmap prefix .. lay .. 'L <plug>(wheel-main-left-toruses)'
		" Grid
		exe nmap prefix .. lay .. 'g <plug>(wheel-grid-locations)'
		exe nmap prefix .. lay .. '<c-g> <plug>(wheel-grid-circles)'
		exe nmap prefix .. lay .. 'G <plug>(wheel-grid-toruses)'
		" Tabs & Windows
		exe nmap prefix .. lay .. '& <plug>(wheel-tab-win-circle)'
		exe nmap prefix .. lay .. '<M-&> <plug>(wheel-tab-win-torus)'
		" Rotating windows
		exe nmap prefix .. lay .. '<up> <plug>(wheel-rotate-counter-clockwise)'
		exe nmap prefix .. lay .. '<down> <plug>(wheel-rotate-clockwise)'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Menus
		exe nmap '<m-m>          <plug>(wheel-menu-main)'
		exe nmap '<m-=>          <plug>(wheel-menu-meta)'
		" Sync
		exe nmap '<m-$>          <plug>(wheel-sync-up)'
		" Add, Delete
		exe nmap '<m-insert>     <plug>(wheel-prompt-add-here)'
		exe nmap '<m-del>        <plug>(wheel-prompt-delete-location)'
		" Next / Previous
		exe nmap '<c-pageup>     <plug>(wheel-previous-location)'
		exe nmap '<c-pagedown>   <plug>(wheel-next-location)'
		exe nmap '<c-home>       <plug>(wheel-previous-circle)'
		exe nmap '<c-end>        <plug>(wheel-next-circle)'
		exe nmap '<s-home>       <plug>(wheel-previous-torus)'
		exe nmap '<s-end>        <plug>(wheel-next-torus)'
		" History
		exe nmap '<s-pageup>     <plug>(wheel-history-newer)'
		exe nmap '<s-pagedown>   <plug>(wheel-history-older)'
		" Alternate
		exe nmap '<c-^>          <plug>(wheel-alternate-anywhere)'
		exe nmap '<m-^>          <plug>(wheel-alternate-same-circle)'
		exe nmap '<m-c-^>        <plug>(wheel-alternate-same-torus-other-circle)'
		" Switch
		exe nmap '<m-cr>        <plug>(wheel-prompt-location)'
		exe nmap '<c-cr>        <plug>(wheel-prompt-circle)'
		exe nmap '<s-cr>        <plug>(wheel-prompt-torus)'
		exe nmap '<m-c-cr>      <plug>(wheel-prompt-index)'
		exe nmap '<m-h>         <plug>(wheel-prompt-history)'
		exe nmap '<space>       <plug>(wheel-dedibuf-location)'
		exe nmap '<c-space>     <plug>(wheel-dedibuf-circle)'
		exe nmap '<s-space>     <plug>(wheel-dedibuf-torus)'
		exe nmap '<m-x>         <plug>(wheel-dedibuf-tree)'
		exe nmap '<m-c-x>       <plug>(wheel-dedibuf-index)'
		exe nmap '<m-c-h>       <plug>(wheel-dedibuf-history)'
		" Search for files
		exe nmap '<m-l>          <plug>(wheel-dedibuf-locate)'
		exe nmap '<m-f>          <plug>(wheel-dedibuf-find)'
		exe nmap '<m-c-f>        <plug>(wheel-dedibuf-async-find)'
		exe nmap '<m-u>          <plug>(wheel-dedibuf-mru)'
		" Buffers
		exe nmap '<m-b>          <plug>(wheel-dedibuf-buffers)'
		exe nmap '<m-c-b>        <plug>(wheel-dedibuf-buffers-all)'
		" Tabs & windows : visible buffers
		exe nmap '<m-v>          <plug>(wheel-prompt-tabwin)'
		exe nmap '<m-c-v>        <plug>(wheel-dedibuf-tabwins-tree)'
		" Search inside files
		exe nmap '<m-s>          <plug>(wheel-dedibuf-occur)'
		exe nmap '<m-g>          <plug>(wheel-dedibuf-grep)'
		exe nmap '<m-o>          <plug>(wheel-dedibuf-outline)'
		" (neo)vim lists
		exe nmap "<m-'>          <plug>(wheel-prompt-marker)"
		exe nmap '<m-j>          <plug>(wheel-prompt-jump)'
		exe nmap '<m-;>          <plug>(wheel-prompt-change)'
		exe nmap '<m-c>          <plug>(wheel-prompt-change)'
		exe nmap '<m-t>          <plug>(wheel-prompt-tag)'
		exe nmap "<m-k>          <plug>(wheel-dedibuf-markers)"
		exe nmap '<m-c-j>        <plug>(wheel-dedibuf-jumps)'
		exe nmap '<m-,>          <plug>(wheel-dedibuf-changes)'
		exe nmap '<m-c-t>        <plug>(wheel-dedibuf-tags)'
		" Yank
		exe nmap '<m-y>          <plug>(wheel-dedibuf-yank-list)'
		exe nmap '<m-p>          <plug>(wheel-dedibuf-yank-plain)'
		" Reshaping buffers
		" wheel
		exe nmap '<m-r>          <plug>(wheel-dedibuf-reorganize)'
		" tabs & windows : visible buffers
		exe nmap '<m-c-r>        <plug>(wheel-dedibuf-reorg-tabwins)'
		" grep edit
		exe nmap '<m-c-g>        <plug>(wheel-dedibuf-grep-edit)'
		" Undo list
		exe nmap '<m-c-u>        <plug>(wheel-dedibuf-undo-list)'
		" Command
		exe nmap '<m-!>          <plug>(wheel-dedibuf-command)'
		exe nmap '<m-&>          <plug>(wheel-dedibuf-async)'
		" Add new mandala buffer
		exe nmap '<m-tab>        <plug>(wheel-mandala-add)'
		" Delete mandala buffer
		exe nmap '<m-backspace>  <plug>(wheel-mandala-delete)'
		" Cycle mandala buffers
		exe nmap '<m-home>        <plug>(wheel-mandala-backward)'
		exe nmap '<m-end>         <plug>(wheel-mandala-forward)'
		" Switch mandala buffers
		exe nmap '<m-space>      <plug>(wheel-mandala-switch)'
		" Layouts
		exe nmap '<m-z>          <plug>(wheel-zoom)'
		exe nmap '<m-pageup>     <plug>(wheel-rotate-counter-clockwise)'
		exe nmap '<m-pagedown>   <plug>(wheel-rotate-clockwise)'
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe nmap prefix .. 'Z <plug>(wheel-debug-fresh-wheel)'
	endif
endfun
