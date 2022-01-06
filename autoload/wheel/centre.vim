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
	" Add
	nnoremap <plug>(wheel-add-here) :call wheel#tree#add_here()<cr>
	nnoremap <plug>(wheel-add-circle) :call wheel#tree#add_circle()<cr>
	nnoremap <plug>(wheel-add-torus) :call wheel#tree#add_torus()<cr>
	nnoremap <plug>(wheel-add-file) :call wheel#tree#add_file()<cr>
	nnoremap <plug>(wheel-add-buffer) :call wheel#tree#add_buffer()<cr>
	nnoremap <plug>(wheel-add-glob) :call wheel#tree#add_glob()<cr>
	" Rename
	nnoremap <plug>(wheel-rename-location) :call wheel#tree#rename('location')<cr>
	nnoremap <plug>(wheel-rename-circle) :call wheel#tree#rename('circle')<cr>
	nnoremap <plug>(wheel-rename-torus) :call wheel#tree#rename('torus')<cr>
	nnoremap <plug>(wheel-rename-file) :call wheel#tree#rename_file()<cr>
	" Delete
	nnoremap <plug>(wheel-delete-location) :call wheel#tree#delete('location')<cr>
	nnoremap <plug>(wheel-delete-circle) :call wheel#tree#delete('circle')<cr>
	nnoremap <plug>(wheel-delete-torus) :call wheel#tree#delete('torus')<cr>
	" Copy
	nnoremap <plug>(wheel-copy-location) :call wheel#tree#copy('location')<cr>
	nnoremap <plug>(wheel-copy-circle) :call wheel#tree#copy('circle')<cr>
	nnoremap <plug>(wheel-copy-torus) :call wheel#tree#copy('torus')<cr>
	" Move
	nnoremap <plug>(wheel-move-location) :call wheel#tree#move('location')<cr>
	nnoremap <plug>(wheel-move-circle) :call wheel#tree#move('circle')<cr>
	" Load / Save wheel
	nnoremap <plug>(wheel-read-all) :call wheel#disc#read_all()<cr>
	nnoremap <plug>(wheel-write-all) :call wheel#disc#write_all()<cr>
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
	" Switch
	nnoremap <plug>(wheel-switch-location) :call wheel#vortex#switch('location')<cr>
	nnoremap <plug>(wheel-switch-circle) :call wheel#vortex#switch('circle')<cr>
	nnoremap <plug>(wheel-switch-torus) :call wheel#vortex#switch('torus')<cr>
	nnoremap <plug>(wheel-multi-switch) :call wheel#vortex#multi_switch()<cr>
	" History
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
	" Navigation
	nnoremap <plug>(wheel-navigation-location) :call wheel#sailing#switch('location')<cr>
	nnoremap <plug>(wheel-navigation-circle) :call wheel#sailing#switch('circle')<cr>
	nnoremap <plug>(wheel-navigation-torus) :call wheel#sailing#switch('torus')<cr>
	" Indexes
	nnoremap <plug>(wheel-switch-in-index) :call wheel#vortex#helix()<cr>
	nnoremap <plug>(wheel-index-locations) :call wheel#sailing#helix()<cr>
	nnoremap <plug>(wheel-index-circles) :call wheel#sailing#grid()<cr>
	nnoremap <plug>(wheel-tree) :call wheel#sailing#tree()<cr>
	"History
	nnoremap <plug>(wheel-history) :call wheel#sailing#history()<cr>
	" Follow current file
	nnoremap <plug>(wheel-follow) :call wheel#projection#follow()<cr>
	" Search for files
	nnoremap <plug>(wheel-locate) :call wheel#sailing#locate()<cr>
	nnoremap <plug>(wheel-find) :call wheel#sailing#find()<cr>
	nnoremap <plug>(wheel-async-find) :call wheel#sailing#async_find()<cr>
	nnoremap <plug>(wheel-mru) :call wheel#sailing#mru()<cr>
	" Buffers
	nnoremap <plug>(wheel-buffers) :call wheel#sailing#buffers()<cr>
	" Tabs & windows : visible buffers
	nnoremap <plug>(wheel-switch-tabwin) :call wheel#rectangle#switch()<cr>
	nnoremap <plug>(wheel-tabwins) :call wheel#sailing#tabwins()<cr>
	nnoremap <plug>(wheel-tabwins-tree) :call wheel#sailing#tabwins_tree()<cr>
	" Search inside files
	nnoremap <plug>(wheel-occur) :call wheel#sailing#occur()<cr>
	nnoremap <plug>(wheel-grep) :call wheel#sailing#grep()<cr>
	nnoremap <plug>(wheel-outline) :call wheel#sailing#outline()<cr>
	" (neo)vim points
	nnoremap <plug>(wheel-markers) :call wheel#sailing#markers()<cr>
	nnoremap <plug>(wheel-jumps) :call wheel#sailing#jumps()<cr>
	nnoremap <plug>(wheel-changes) :call wheel#sailing#changes()<cr>
	" Tags
	nnoremap <plug>(wheel-switch-tag) :call wheel#symbol#switch()<cr>
	nnoremap <plug>(wheel-tags) :call wheel#sailing#tags()<cr>
	" Yank wheel
	nnoremap <plug>(wheel-yank-list) :call wheel#clipper#yank('list')<cr>
	nnoremap <plug>(wheel-yank-plain) :call wheel#clipper#yank('plain')<cr>
	" Reorder
	nnoremap <plug>(wheel-reorder-location) :call wheel#shape#reorder('location')<cr>
	nnoremap <plug>(wheel-reorder-circle) :call wheel#shape#reorder('circle')<cr>
	nnoremap <plug>(wheel-reorder-torus) :call wheel#shape#reorder('torus')<cr>
	" Batch rename
	nnoremap <plug>(wheel-batch-rename-location) :call wheel#shape#rename('location')<cr>
	nnoremap <plug>(wheel-batch-rename-circle) :call wheel#shape#rename('circle')<cr>
	nnoremap <plug>(wheel-batch-rename-torus) :call wheel#shape#rename('torus')<cr>
	nnoremap <plug>(wheel-batch-rename-location-filename) :call wheel#shape#rename_files()<cr>
	" Batch copy/move
	nnoremap <plug>(wheel-batch-copy-move-location) :call wheel#shape#copy_move('location')<cr>
	nnoremap <plug>(wheel-batch-copy-move-circle) :call wheel#shape#copy_move('circle')<cr>
	nnoremap <plug>(wheel-batch-copy-move-torus) :call wheel#shape#copy_move('torus')<cr>
	" Reorganize
	nnoremap <plug>(wheel-reorganize) :call wheel#shape#reorganize()<cr>
	" Reorganize tabs & windows
	nnoremap <plug>(wheel-reorg-tabwins) :call wheel#shape#reorg_tabwins()<cr>
	" Grep edit mode
	nnoremap <plug>(wheel-grep-edit) :call wheel#shape#grep_edit()<cr>
	" Undo list
	nnoremap <plug>(wheel-undo-list) :call wheel#delta#undolist()<cr>
	" Generic buffer from ex or shell command output
	nnoremap <plug>(wheel-command) :call wheel#mandala#command()<cr>
	nnoremap <plug>(wheel-async) :call wheel#mandala#async()<cr>
	" Save (push) mandala buffer
	nnoremap <plug>(wheel-mandala-push) :call wheel#cylinder#push()<cr>
	" Remove (pop) mandala buffer
	nnoremap <plug>(wheel-mandala-pop) :call wheel#cylinder#pop()<cr>
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
	" layout subprefix
	let lay = 'z'
	" maps arguments
	let nmap = 'nmap <silent>'
	" Basic
	if g:wheel_config.mappings >= 0
		" Menus
		exe nmap prefix . '<m-m> <plug>(wheel-menu-main)'
		exe nmap prefix . '= <plug>(wheel-menu-meta)'
		" Dashboard, info
		exe nmap prefix . 'i <plug>(wheel-dashboard)'
		" Add
		exe nmap prefix . 'a <plug>(wheel-add-here)'
		exe nmap prefix . '<c-a> <plug>(wheel-add-circle)'
		exe nmap prefix . 'A <plug>(wheel-add-torus)'
		exe nmap prefix . '+f <plug>(wheel-add-file)'
		exe nmap prefix . '+b <plug>(wheel-add-buffer)'
		exe nmap prefix . '* <plug>(wheel-add-glob)'
		" Next / Previous
		exe nmap prefix . '<left> <plug>(wheel-previous-location)'
		exe nmap prefix . '<right> <plug>(wheel-next-location)'
		exe nmap prefix . '<c-left> <plug>(wheel-previous-circle)'
		exe nmap prefix . '<c-right> <plug>(wheel-next-circle)'
		exe nmap prefix . '<s-left> <plug>(wheel-previous-torus)'
		exe nmap prefix . '<s-right> <plug>(wheel-next-torus)'
		" History
		exe nmap prefix . '<up> <plug>(wheel-history-newer)'
		exe nmap prefix . '<down> <plug>(wheel-history-older)'
		exe nmap prefix . '<c-^> <plug>(wheel-alternate-anywhere)'
		exe nmap prefix . '<m-^> <plug>(wheel-alternate-same-circle)'
		exe nmap prefix . '<m-c-^> <plug>(wheel-alternate-same-torus-other-circle)'
		exe nmap prefix . '^ <plug>(wheel-alternate-menu)'
		" Load / Save wheel
		exe nmap prefix . 'r <plug>(wheel-read-all)'
		exe nmap prefix . 'w <plug>(wheel-write-all)'
		" Load / Save session file
		exe nmap prefix . 'R <plug>(wheel-read-session)'
		exe nmap prefix . 'W <plug>(wheel-write-session)'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Switch
		exe nmap prefix . '<cr> <plug>(wheel-switch-location)'
		exe nmap prefix . '<c-cr> <plug>(wheel-switch-circle)'
		exe nmap prefix . '<s-cr> <plug>(wheel-switch-torus)'
		exe nmap prefix . '<m-cr> <plug>(wheel-multi-switch)'
		" Follow
		exe nmap prefix . '<m-f> <plug>(wheel-follow)'
		" Navigation
		exe nmap prefix . '<space> <plug>(wheel-navigation-location)'
		exe nmap prefix . '<c-space> <plug>(wheel-navigation-circle)'
		exe nmap prefix . '<s-space> <plug>(wheel-navigation-torus)'
		" Indexes
		exe nmap prefix . 'x <plug>(wheel-switch-in-index)'
		exe nmap prefix . 'X <plug>(wheel-index-locations)'
		exe nmap prefix . '<c-x> <plug>(wheel-index-circles)'
		exe nmap prefix . '<m-x> <plug>(wheel-tree)'
		" History
		exe nmap prefix . 'h <plug>(wheel-history)'
		" Rename
		exe nmap prefix . 'n <plug>(wheel-rename-location)'
		exe nmap prefix . '<c-n> <plug>(wheel-rename-circle)'
		exe nmap prefix . 'N <plug>(wheel-rename-torus)'
		exe nmap prefix . '<m-n> <plug>(wheel-rename-file)'
		" Delete
		exe nmap prefix . 'd <plug>(wheel-delete-location)'
		exe nmap prefix . '<c-d> <plug>(wheel-delete-circle)'
		exe nmap prefix . 'D <plug>(wheel-delete-torus)'
		" Copy
		exe nmap prefix . 'c <plug>(wheel-copy-location)'
		" <c-c> does not work in maps
		exe nmap prefix . '<m-c> <plug>(wheel-copy-circle)'
		exe nmap prefix . 'C <plug>(wheel-copy-torus)'
		" Move
		exe nmap prefix . 'm <plug>(wheel-move-location)'
		exe nmap prefix . 'M <plug>(wheel-move-circle)'
		" Reorder
		exe nmap prefix . 'o <plug>(wheel-reorder-location)'
		exe nmap prefix . '<c-o> <plug>(wheel-reorder-circle)'
		exe nmap prefix . 'O <plug>(wheel-reorder-torus)'
		" Batch rename
		exe nmap prefix . batch . 'n <plug>(wheel-batch-rename-location)'
		exe nmap prefix . batch . '<c-n> <plug>(wheel-batch-rename-circle)'
		exe nmap prefix . batch . 'N <plug>(wheel-batch-rename-torus)'
		exe nmap prefix . batch . '<m-n> <plug>(wheel-batch-rename-location-filename)'
		" Batch copy/move
		exe nmap prefix . batch . 'c <plug>(wheel-batch-copy-move-location)'
		exe nmap prefix . batch . '<m-c> <plug>(wheel-batch-copy-move-circle)'
		exe nmap prefix . batch . 'C <plug>(wheel-batch-copy-move-torus)'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" Search for files
		exe nmap prefix . 'l <plug>(wheel-locate)'
		exe nmap prefix . 'f <plug>(wheel-find)'
		exe nmap prefix . '&f <plug>(wheel-async-find)'
		exe nmap prefix . 'u <plug>(wheel-mru)'
		" Buffers
		exe nmap prefix . 'b <plug>(wheel-buffers)'
		" Tabs & windows : visible buffers
		exe nmap prefix . 'v <plug>(wheel-switch-tabwin)'
		exe nmap prefix . 'V <plug>(wheel-tabwins)'
		exe nmap prefix . '<m-v> <plug>(wheel-tabwins-tree)'
		" Search inside files
		exe nmap prefix . 's <plug>(wheel-occur)'
		exe nmap prefix . 'g <plug>(wheel-grep)'
		exe nmap prefix . '<m-o> <plug>(wheel-outline)'
		" (neo)vim points
		exe nmap prefix . "' <plug>(wheel-markers)"
		exe nmap prefix . 'j <plug>(wheel-jumps)'
		exe nmap prefix . '; <plug>(wheel-changes)'
		" Tags
		exe nmap prefix . 't <plug>(wheel-switch-tag)'
		exe nmap prefix . '<m-t> <plug>(wheel-tags)'
		" Yank wheel
		exe nmap prefix . 'y <plug>(wheel-yank-list)'
		exe nmap prefix . 'p <plug>(wheel-yank-plain)'
		" Reorganize
		" wheel
		exe nmap prefix . '<m-r> <plug>(wheel-reorganize)'
		" tabs & windows
		exe nmap prefix . '<c-r> <plug>(wheel-reorg-tabwins)'
		" grep edit
		exe nmap prefix . '<m-g> <plug>(wheel-grep-edit)'
		" Undo list
		exe nmap prefix . '<m-u> <plug>(wheel-undo-list)'
		" Generic ex or shell command
		exe nmap prefix . ': <plug>(wheel-command)'
		exe nmap prefix . '&& <plug>(wheel-async)'
		" Save (push) mandala buffer
		exe nmap prefix . '<tab> <plug>(wheel-mandala-push)'
		" Remove (pop) mandala buffer
		exe nmap prefix . '<backspace> <plug>(wheel-mandala-pop)'
		" Cycle mandala buffers
		exe nmap prefix . '<home> <plug>(wheel-mandala-backward)'
		exe nmap prefix . '<end>  <plug>(wheel-mandala-forward)'
		" Switch mandala buffer
		exe nmap prefix . '<m-space> <plug>(wheel-mandala-switch)'
		" Layouts
		exe nmap prefix . lay . 'z <plug>(wheel-zoom)'
		" Tabs
		exe nmap prefix . lay . 't <plug>(wheel-tabs-locations)'
		exe nmap prefix . lay . '<c-t> <plug>(wheel-tabs-circles)'
		exe nmap prefix . lay . 'T <plug>(wheel-tabs-toruses)'
		" Windows
		exe nmap prefix . lay . 's <plug>(wheel-split-locations)'
		exe nmap prefix . lay . '<c-s> <plug>(wheel-split-circles)'
		exe nmap prefix . lay . 'S <plug>(wheel-split-toruses)'
		exe nmap prefix . lay . 'v <plug>(wheel-vsplit-locations)'
		exe nmap prefix . lay . '<c-v> <plug>(wheel-vsplit-circles)'
		exe nmap prefix . lay . 'V <plug>(wheel-vsplit-toruses)'
		" Main top
		exe nmap prefix . lay . 'm <plug>(wheel-main-top-locations)'
		exe nmap prefix . lay . '<c-m> <plug>(wheel-main-top-circles)'
		exe nmap prefix . lay . 'M <plug>(wheel-main-top-toruses)'
		" Main left
		exe nmap prefix . lay . 'l <plug>(wheel-main-left-locations)'
		exe nmap prefix . lay . '<c-l> <plug>(wheel-main-left-circles)'
		exe nmap prefix . lay . 'L <plug>(wheel-main-left-toruses)'
		" Grid
		exe nmap prefix . lay . 'g <plug>(wheel-grid-locations)'
		exe nmap prefix . lay . '<c-g> <plug>(wheel-grid-circles)'
		exe nmap prefix . lay . 'G <plug>(wheel-grid-toruses)'
		" Tabs & Windows
		exe nmap prefix . lay . '& <plug>(wheel-tab-win-circle)'
		exe nmap prefix . lay . '<M-&> <plug>(wheel-tab-win-torus)'
		" Rotating windows
		exe nmap prefix . lay . '<up> <plug>(wheel-rotate-counter-clockwise)'
		exe nmap prefix . lay . '<down> <plug>(wheel-rotate-clockwise)'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Menus
		exe nmap '<m-m>          <plug>(wheel-menu-main)'
		exe nmap '<m-=>          <plug>(wheel-menu-meta)'
		" Add, Delete
		exe nmap '<m-insert>     <plug>(wheel-add-here)'
		exe nmap '<m-del>        <plug>(wheel-delete-location)'
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
		" Switch prompt
		exe nmap '<m-cr>        <plug>(wheel-switch-location)'
		exe nmap '<c-cr>        <plug>(wheel-switch-circle)'
		exe nmap '<s-cr>        <plug>(wheel-switch-torus)'
		exe nmap '<m-c-cr>      <plug>(wheel-switch-in-index)'
		" Navigation buffers
		exe nmap '<space>        <plug>(wheel-navigation-location)'
		exe nmap '<c-space>      <plug>(wheel-navigation-circle)'
		exe nmap '<s-space>      <plug>(wheel-navigation-torus)'
		exe nmap '<m-x>          <plug>(wheel-tree)'
		exe nmap '<m-c-x>        <plug>(wheel-index-locations)'
		exe nmap '<m-h>          <plug>(wheel-history)'
		" Search for files
		exe nmap '<m-l>          <plug>(wheel-locate)'
		exe nmap '<m-f>          <plug>(wheel-find)'
		exe nmap '<m-c-f>        <plug>(wheel-async-find)'
		exe nmap '<m-u>          <plug>(wheel-mru)'
		" Buffers
		exe nmap '<m-b>          <plug>(wheel-buffers)'
		" Tabs & windows : visible buffers
		exe nmap '<m-v>          <plug>(wheel-switch-tabwin)'
		exe nmap '<m-c-v>        <plug>(wheel-tabwins-tree)'
		" Search inside files
		exe nmap '<m-s>          <plug>(wheel-occur)'
		exe nmap '<m-g>          <plug>(wheel-grep)'
		exe nmap '<m-o>          <plug>(wheel-outline)'
		" (neo)vim points
		exe nmap '<m-k>          <plug>(wheel-markers)'
		exe nmap '<m-j>          <plug>(wheel-jumps)'
		exe nmap '<m-c>          <plug>(wheel-changes)'
		" tags, labels
		exe nmap '<m-t>          <plug>(wheel-switch-tag)'
		exe nmap '<m-l>          <plug>(wheel-tags)'
		" Yank
		exe nmap '<m-y>          <plug>(wheel-yank-list)'
		exe nmap '<m-p>          <plug>(wheel-yank-plain)'
		" Reshaping buffers
		" wheel
		exe nmap '<m-r>          <plug>(wheel-reorganize)'
		" tabs & windows : visible buffers
		exe nmap '<m-c-r>        <plug>(wheel-reorg-tabwins)'
		" grep edit
		exe nmap '<m-c-g>        <plug>(wheel-grep-edit)'
		" Undo list
		exe nmap '<m-c-u>        <plug>(wheel-undo-list)'
		" Command
		exe nmap '<m-!>          <plug>(wheel-command)'
		exe nmap '<m-&>          <plug>(wheel-async)'
		" Save (push) mandala buffer
		exe nmap '<m-tab>        <plug>(wheel-mandala-push)'
		" Remove (pop) mandala buffer
		exe nmap '<m-backspace>  <plug>(wheel-mandala-pop)'
		" Cycle mandala buffers
		exe nmap '<m-home>        <plug>(wheel-mandala-backward)'
		exe nmap '<m-end>       <plug>(wheel-mandala-forward)'
		" Switch mandala buffers
		exe nmap '<m-space>      <plug>(wheel-mandala-switch)'
		" Layouts
		exe nmap '<m-z>          <plug>(wheel-zoom)'
		exe nmap '<m-pageup>     <plug>(wheel-rotate-counter-clockwise)'
		exe nmap '<m-pagedown>   <plug>(wheel-rotate-clockwise)'
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe nmap prefix . 'Z <plug>(wheel-debug-fresh-wheel)'
	endif
endfun
