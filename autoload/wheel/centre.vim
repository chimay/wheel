" vim: ft=vim fdm=indent:

" Command, Mappings

fun! wheel#centre#commands ()
	" Define commands
	" Status
	command! WheelDashboard call wheel#status#dashboard()
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
	command! -nargs=+ WheelGrep call wheel#sailing#grep(<q-args>)
endfun

fun! wheel#centre#mappings ()
	" Define mappings
	let prefix = g:wheel_config.prefix
	" Basic
	if g:wheel_config.mappings >= 0
		" Menus
		exe 'nnoremap ' . prefix . 'm :call wheel#hub#main()<cr>'
		exe 'nnoremap ' . prefix . '= :call wheel#hub#meta()<cr>'
		" Add
		exe 'nnoremap ' . prefix . 'a :call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . prefix . '<c-a> :call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . prefix . 'A :call wheel#tree#add_torus()<cr>'
		exe 'nnoremap ' . prefix . 'f :call wheel#tree#add_file()<cr>'
		exe 'nnoremap ' . prefix . 'b :call wheel#tree#add_buffer()<cr>'
		" Next / Previous
		exe 'nnoremap ' . prefix . "<left> :call wheel#vortex#previous('location')<cr>"
		exe 'nnoremap ' . prefix . "<right> :call wheel#vortex#next('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-left> :call wheel#vortex#previous('circle')<cr>"
		exe 'nnoremap ' . prefix . "<c-right> :call wheel#vortex#next('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-left> :call wheel#vortex#previous('torus')<cr>"
		exe 'nnoremap ' . prefix . "<s-right> :call wheel#vortex#next('torus')<cr>"
		" Load / Save wheel
		exe 'nnoremap ' . prefix . 'r :call wheel#disc#read_all()<cr>'
		exe 'nnoremap ' . prefix . 'w :call wheel#disc#write_all()<cr>'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Switch
		exe 'nnoremap ' . prefix . "<space> :call wheel#sailing#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-space> :call wheel#sailing#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-space> :call wheel#sailing#switch('torus')<cr>"
		" Indexes
		exe 'nnoremap ' . prefix . 'x :call wheel#sailing#helix()<cr>'
		exe 'nnoremap ' . prefix . '<c-x> :call wheel#sailing#grid()<cr>'
		exe 'nnoremap ' . prefix . '<m-x> :call wheel#sailing#tree()<cr>'
		"History
		exe 'nnoremap ' . prefix . 'h :call wheel#sailing#history()<cr>'
		" Reorder
		exe 'nnoremap ' . prefix . "o :call wheel#shape#reorder('location')<cr>"
		exe 'nnoremap ' . prefix . "<C-o> :call wheel#shape#reorder('circle')<cr>"
		exe 'nnoremap ' . prefix . "O :call wheel#shape#reorder('torus')<cr>"
		" Rename
		exe 'nnoremap ' . prefix . "n :call wheel#tree#rename('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-n> :call wheel#tree#rename('circle')<cr>"
		exe 'nnoremap ' . prefix . "N :call wheel#tree#rename('torus')<cr>"
		exe 'nnoremap ' . prefix . '<m-n> :call wheel#tree#rename_file()<cr>'
		" Delete
		exe 'nnoremap ' . prefix . "d :call wheel#tree#delete('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-d> :call wheel#tree#delete('circle')<cr>"
		exe 'nnoremap ' . prefix . "D :call wheel#tree#delete('torus')<cr>"
		" Navigation
		exe 'nnoremap ' . prefix . "<cr> :call wheel#vortex#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-cr> :call wheel#vortex#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-cr> :call wheel#vortex#switch('torus')<cr>"
		" History
		exe 'nnoremap ' . prefix . '<pageup> :call wheel#pendulum#newer()<cr>'
		exe 'nnoremap ' . prefix . '<pagedown> :call wheel#pendulum#older()<cr>'
		exe 'nnoremap ' . prefix . '^ :call wheel#pendulum#alternate()<cr>'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" Tabs
		exe 'nnoremap ' . prefix . "t :call wheel#mosaic#tabs('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-t> :call wheel#mosaic#tabs('circle')<cr>"
		exe 'nnoremap ' . prefix . "T :call wheel#mosaic#tabs('torus')<cr>"
		" Windows
		exe 'nnoremap ' . prefix . "s :call wheel#mosaic#split('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-s> :call wheel#mosaic#split('circle')<cr>"
		exe 'nnoremap ' . prefix . "S :call wheel#mosaic#split('torus')<cr>"
		exe 'nnoremap ' . prefix . "v :call wheel#mosaic#split('location', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "<c-v> :call wheel#mosaic#split('circle', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "V :call wheel#mosaic#split('torus', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "l :call wheel#mosaic#split('location', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "<c-l> :call wheel#mosaic#split('circle', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "L :call wheel#mosaic#split('torus', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "g :call wheel#mosaic#split_grid('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-g> :call wheel#mosaic#split_grid('circle')<cr>"
		exe 'nnoremap ' . prefix . "G :call wheel#mosaic#split_grid('torus')<cr>"
		" Rotating windows
		exe 'nnoremap ' . prefix . '<up> :call wheel#mosaic#rotate_counter_clockwise()<cr>'
		exe 'nnoremap ' . prefix . '<down> :call wheel#mosaic#rotate_clockwise()<cr>'
		" Tabs & Windows
		exe 'nnoremap ' . prefix . 'z :call wheel#mosaic#zoom()<cr>'
		exe 'nnoremap ' . prefix . "P :call wheel#pyramid#steps('torus')<cr>"
		exe 'nnoremap ' . prefix . "<c-p> :call wheel#pyramid#steps('circle')<cr>"
		" Search inside files
		exe 'nnoremap ' . prefix . ': :call wheel#sailing#occur()<cr>'
		exe 'nnoremap ' . prefix . '* :call wheel#sailing#grep()<cr>'
		exe 'nnoremap ' . prefix . '# :call wheel#sailing#outline()<cr>'
		exe 'nnoremap ' . prefix . '% :call wheel#sailing#symbol()<cr>'
		" Search for files
		exe 'nnoremap ' . prefix . '? :call wheel#sailing#attic()<cr>'
		exe 'nnoremap ' . prefix . '/ :call wheel#sailing#locate()<cr>'
		exe 'nnoremap ' . prefix . '& :call wheel#sailing#find()<cr>'
		" Yank wheel
		exe 'nnoremap ' . prefix . "y :call wheel#clipper#yank('list')<cr>"
		exe 'nnoremap ' . prefix . "<m-y> :call wheel#clipper#yank('plain')<cr>"
		" Reorganize
		exe 'nnoremap ' . prefix . '<m-o> :call wheel#shape#reorganize()<cr>'
		" Save (push) wheel buffer
		exe 'nnoremap ' . prefix . '<tab> :call wheel#mandala#push()<cr>'
		" Remove (pop) wheel buffer
		exe 'nnoremap ' . prefix . '<backspace> :call wheel#mandala#pop()<cr>'
		" Cycle wheel buffers
		exe 'nnoremap ' . prefix . '@ :call wheel#mandala#cycle()<cr>'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Menus
		nnoremap <M-m>        :call wheel#hub#main()<cr>
		nnoremap <M-=>        :call wheel#hub#meta()<cr>
		" Add, Delete
		nnoremap <M-Insert>   :call wheel#tree#add_here()<cr>
		nnoremap <M-Del>      :call wheel#tree#delete('location')<cr>
		" Next / Previous
		nnoremap <C-PageUp>   :call wheel#vortex#previous('location')<cr>
		nnoremap <C-PageDown> :call wheel#vortex#next('location')<cr>
		nnoremap <C-Home>     :call wheel#vortex#previous('circle')<cr>
		nnoremap <C-End>      :call wheel#vortex#next('circle')<cr>
		nnoremap <S-Home>     :call wheel#vortex#previous('torus')<cr>
		nnoremap <S-End>      :call wheel#vortex#next('torus')<cr>
		" History
		nnoremap <S-PageUp>     :call wheel#pendulum#newer()<cr>
		nnoremap <S-PageDown>   :call wheel#pendulum#older()<cr>
		" Alternate
		nnoremap <C-^>          :call wheel#pendulum#alternate()<cr>
		nnoremap <D-^>          :call wheel#pendulum#alternate_same_torus_other_circle()<cr>
		nnoremap <C-S-PageUp>   :call wheel#pendulum#alternate_same_torus()<cr>
		nnoremap <C-S-PageDown> :call wheel#pendulum#alternate_same_circle()<cr>
		nnoremap <C-S-Home>     :call wheel#pendulum#alternate_other_torus()<cr>
		nnoremap <C-S-End>      :call wheel#pendulum#alternate_other_circle()<cr>
		" Navigation buffers
		nnoremap <Space>      :call wheel#sailing#switch('location')<cr>
		nnoremap <C-Space>    :call wheel#sailing#switch('circle')<cr>
		nnoremap <S-Space>    :call wheel#sailing#switch('torus')<cr>
		nnoremap <M-x>        :call wheel#sailing#tree()<cr>
		nnoremap <D-x>        :call wheel#sailing#helix()<cr>
		nnoremap <M-h>        :call wheel#sailing#history()<cr>
		" Reshaping buffers
		nnoremap <M-r>        :call wheel#shape#reorganize()<cr>
		" Search inside files
		nnoremap <M-s>          :call wheel#sailing#occur()<cr>
		nnoremap <M-g>          :call wheel#sailing#grep()<cr>
		nnoremap <M-o>          :call wheel#sailing#outline()<cr>
		nnoremap <M-t>          :call wheel#sailing#symbol()<cr>
		" Search for files
		nnoremap <M-u>          :call wheel#sailing#attic()<cr>
		nnoremap <M-l>          :call wheel#sailing#locate()<cr>
		nnoremap <M-f>          :call wheel#sailing#find()<cr>
		" Yank
		nnoremap <M-y>          :call wheel#clipper#yank('list')<cr>
		nnoremap <M-p>          :call wheel#clipper#yank('plain')<cr>
		" Batch
		nnoremap <M-b>          :WheelBatch<space>
		" Windows
		nnoremap <M-z>          :call wheel#mosaic#zoom()<cr>
		nnoremap <M-Home>       :call wheel#mosaic#tabs('location')<cr>
		nnoremap <M-End>        :call wheel#mosaic#split('location', 'main_left')<cr>
		nnoremap <M-&>          :call wheel#pyramid#steps('circle')<cr>
		" Rotate windows
		nnoremap <M-PageUp>     :call wheel#mosaic#rotate_counter_clockwise()<cr>
		nnoremap <M-PageDown>   :call wheel#mosaic#rotate_clockwise()<cr>
		" Save (push) wheel buffer
		nnoremap <M-Tab>        :call wheel#mandala#push()<cr>
		" Remove (pop) wheel buffer
		nnoremap <M-Backspace>  :call wheel#mandala#pop()<cr>
		" Cycle wheel buffers
		nnoremap <M-Space>      :call wheel#mandala#cycle()<cr>
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe 'nnoremap ' . prefix . "Z :call wheel#void#fresh_wheel()<cr>"
	endif
endfun

fun! wheel#centre#plugs ()
	" Define <plug> mappings
	let prefix = g:wheel_config.prefix
	" Menus
	exe 'nnoremap <plug>(wheel-menu-main) :call wheel#hub#main()<cr>'
	exe 'nnoremap <plug>(wheel-menu-meta) :call wheel#hub#meta()<cr>'
	" Add
	exe 'nnoremap <plug>(wheel-add-here) :call wheel#tree#add_here()<cr>'
	exe 'nnoremap <plug>(wheel-add-circle) :call wheel#tree#add_circle()<cr>'
	exe 'nnoremap <plug>(wheel-add-torus) :call wheel#tree#add_torus()<cr>'
	exe 'nnoremap <plug>(wheel-add-file) :call wheel#tree#add_file()<cr>'
	exe 'nnoremap <plug>(wheel-add-buffer) :call wheel#tree#add_buffer()<cr>'
	" Rename
	exe 'nnoremap <plug>(wheel-rename-location) :call wheel#tree#rename('location')<cr>"
	exe 'nnoremap <plug>(wheel-rename-circle) :call wheel#tree#rename('circle')<cr>"
	exe 'nnoremap <plug>(wheel-rename-torus) :call wheel#tree#rename('torus')<cr>"
	exe 'nnoremap <plug>(wheel-rename-file) :call wheel#tree#rename_file()<cr>'
	" Delete
	exe 'nnoremap <plug>(wheel-delete-location) :call wheel#tree#delete('location')<cr>"
	exe 'nnoremap <plug>(wheel-delete-circle) :call wheel#tree#delete('circle')<cr>"
	exe 'nnoremap <plug>(wheel-delete-torus) :call wheel#tree#delete('torus')<cr>"
	" Load / Save wheel
	exe 'nnoremap <plug>(wheel-read-all) :call wheel#disc#read_all()<cr>'
	exe 'nnoremap <plug>(wheel-write-all) :call wheel#disc#write_all()<cr>'
	" Next / Previous
	exe 'nnoremap <plug>(wheel-previous-location) :call wheel#vortex#previous('location')<cr>"
	exe 'nnoremap <plug>(wheel-next-location) :call wheel#vortex#next('location')<cr>"
	exe 'nnoremap <plug>(wheel-previous-circle) :call wheel#vortex#previous('circle')<cr>"
	exe 'nnoremap <plug>(wheel-next-circle) :call wheel#vortex#next('circle')<cr>"
	exe 'nnoremap <plug>(wheel-previous-torus) :call wheel#vortex#previous('torus')<cr>"
	exe 'nnoremap <plug>(wheel-next-torus) :call wheel#vortex#next('torus')<cr>"
	" Switch
	exe 'nnoremap <plug>(wheel-switch-location) :call wheel#vortex#switch('location')<cr>"
	exe 'nnoremap <plug>(wheel-switch-circle) :call wheel#vortex#switch('circle')<cr>"
	exe 'nnoremap <plug>(wheel-switch-torus) :call wheel#vortex#switch('torus')<cr>"
	" History
	exe 'nnoremap <plug>(wheel-pendulum-newer) :call wheel#pendulum#newer()<cr>'
	exe 'nnoremap <plug>(wheel-pendulum-older) :call wheel#pendulum#older()<cr>'
	" Alternate
	exe 'nnoremap <plug>(wheel-alternate) :call wheel#pendulum#alternate()<cr>'
	exe 'nnoremap <plug>(wheel-alternate-same-torus-other-circle) :call wheel#pendulum#alternate_same_torus_other_circle()<cr>'
	exe 'nnoremap <plug>(wheel-alternate-same-torus) :call wheel#pendulum#alternate_same_torus()<cr>'
	exe 'nnoremap <plug>(wheel-alternate-same-circle) :call wheel#pendulum#alternate_same_circle()<cr>'
	exe 'nnoremap <plug>(wheel-alternate-other-torus) :call wheel#pendulum#alternate_other_torus()<cr>'
	exe 'nnoremap <plug>(wheel-alternate-other-circle) :call wheel#pendulum#alternate_other_circle()<cr>'
	" Navigation
	exe 'nnoremap <plug>(wheel-navigation-location) :call wheel#sailing#switch('location')<cr>"
	exe 'nnoremap <plug>(wheel-navigation-circle) :call wheel#sailing#switch('circle')<cr>"
	exe 'nnoremap <plug>(wheel-navigation-torus) :call wheel#sailing#switch('torus')<cr>"
	" Indexes
	exe 'nnoremap <plug>(wheel-navigation-helix) :call wheel#sailing#helix()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-grid) :call wheel#sailing#grid()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-tree) :call wheel#sailing#tree()<cr>'
	"History
	exe 'nnoremap <plug>(wheel-navigation-history) :call wheel#sailing#history()<cr>'
	" Search inside files
	exe 'nnoremap <plug>(wheel-navigation-occur) :call wheel#sailing#occur()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-grep) :call wheel#sailing#grep()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-outline) :call wheel#sailing#outline()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-tags) :call wheel#sailing#symbol()<cr>'
	" Search for files
	exe 'nnoremap <plug>(wheel-navigation-mru) :call wheel#sailing#attic()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-locate) :call wheel#sailing#locate()<cr>'
	exe 'nnoremap <plug>(wheel-navigation-find) :call wheel#sailing#find()<cr>'
	" Reorder
	exe 'nnoremap <plug>(wheel-reorder-location) :call wheel#shape#reorder('location')<cr>"
	exe 'nnoremap <plug>(wheel-reorder-circle) :call wheel#shape#reorder('circle')<cr>"
	exe 'nnoremap <plug>(wheel-reorder-torus) :call wheel#shape#reorder('torus')<cr>"
	" Reorganize
	exe 'nnoremap <plug>(wheel-reorganize) :call wheel#shape#reorganize()<cr>'
	" Yank wheel
	exe 'nnoremap <plug>(wheel-) :call wheel#clipper#yank('list')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#clipper#yank('plain')<cr>"
	" Save (push) wheel buffer
	exe 'nnoremap <plug>(wheel-) :call wheel#mandala#push()<cr>'
	" Remove (pop) wheel buffer
	exe 'nnoremap <plug>(wheel-) :call wheel#mandala#pop()<cr>'
	" Cycle wheel buffers
	exe 'nnoremap <pluig> :call wheel#mandala#cycle()<cr>'
	" Tabs
	exe 'nnoremap <plug>(wheel-mosaic-tabs-locations) :call wheel#mosaic#tabs('location')<cr>"
	exe 'nnoremap <plug>(wheel-mosaic-tabs-circles) :call wheel#mosaic#tabs('circle')<cr>"
	exe 'nnoremap <plug>(wheel-mosaic-tabs-toruses) :call wheel#mosaic#tabs('torus')<cr>"
	" Windows
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('location')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('circle')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('torus')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('location', 'vertical')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('circle', 'vertical')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('torus', 'vertical')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('location', 'main_left')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('circle', 'main_left')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split('torus', 'main_left')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split_grid('location')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split_grid('circle')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#split_grid('torus')<cr>"
	" Rotating windows
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#rotate_counter_clockwise()<cr>'
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#rotate_clockwise()<cr>'
	" Tabs & Windows
	exe 'nnoremap <plug>(wheel-) :call wheel#mosaic#zoom()<cr>'
	exe 'nnoremap <plug>(wheel-) :call wheel#pyramid#steps('torus')<cr>"
	exe 'nnoremap <plug>(wheel-) :call wheel#pyramid#steps('circle')<cr>"
	" Debug
	exe 'nnoremap <plug>(wheel-) :call wheel#void#fresh_wheel()<cr>"
endfun

fun! wheel#centre#cables ()
	" Link <Plug> mappings to keys
	let prefix = g:wheel_config.prefix
	" Basic
	if g:wheel_config.mappings >= 0
		" Menus
		exe 'nnoremap ' . prefix . '= :call wheel#hub#meta()<cr>'
		exe 'nnoremap ' . prefix . 'm :call wheel#hub#main()<cr>'
		" Add
		exe 'nnoremap ' . prefix . 'a :call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . prefix . '<c-a> :call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . prefix . 'A :call wheel#tree#add_torus()<cr>'
		exe 'nnoremap ' . prefix . 'f :call wheel#tree#add_file()<cr>'
		exe 'nnoremap ' . prefix . 'b :call wheel#tree#add_buffer()<cr>'
		" Next / Previous
		exe 'nnoremap ' . prefix . "<left> :call wheel#vortex#previous('location')<cr>"
		exe 'nnoremap ' . prefix . "<right> :call wheel#vortex#next('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-left> :call wheel#vortex#previous('circle')<cr>"
		exe 'nnoremap ' . prefix . "<c-right> :call wheel#vortex#next('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-left> :call wheel#vortex#previous('torus')<cr>"
		exe 'nnoremap ' . prefix . "<s-right> :call wheel#vortex#next('torus')<cr>"
		" Load / Save wheel
		exe 'nnoremap ' . prefix . 'r :call wheel#disc#read_all()<cr>'
		exe 'nnoremap ' . prefix . 'w :call wheel#disc#write_all()<cr>'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Switch
		exe 'nnoremap ' . prefix . "<space> :call wheel#sailing#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-space> :call wheel#sailing#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-space> :call wheel#sailing#switch('torus')<cr>"
		" Indexes
		exe 'nnoremap ' . prefix . 'x :call wheel#sailing#helix()<cr>'
		exe 'nnoremap ' . prefix . '<c-x> :call wheel#sailing#grid()<cr>'
		exe 'nnoremap ' . prefix . '<m-x> :call wheel#sailing#tree()<cr>'
		"History
		exe 'nnoremap ' . prefix . 'h :call wheel#sailing#history()<cr>'
		" Reorder
		exe 'nnoremap ' . prefix . "o :call wheel#shape#reorder('location')<cr>"
		exe 'nnoremap ' . prefix . "<C-o> :call wheel#shape#reorder('circle')<cr>"
		exe 'nnoremap ' . prefix . "O :call wheel#shape#reorder('torus')<cr>"
		" Rename
		exe 'nnoremap ' . prefix . "n :call wheel#tree#rename('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-n> :call wheel#tree#rename('circle')<cr>"
		exe 'nnoremap ' . prefix . "N :call wheel#tree#rename('torus')<cr>"
		exe 'nnoremap ' . prefix . '<m-n> :call wheel#tree#rename_file()<cr>'
		" Delete
		exe 'nnoremap ' . prefix . "d :call wheel#tree#delete('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-d> :call wheel#tree#delete('circle')<cr>"
		exe 'nnoremap ' . prefix . "D :call wheel#tree#delete('torus')<cr>"
		" Navigation
		exe 'nnoremap ' . prefix . "<cr> :call wheel#vortex#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-cr> :call wheel#vortex#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-cr> :call wheel#vortex#switch('torus')<cr>"
		" History
		exe 'nnoremap ' . prefix . '<pageup> :call wheel#pendulum#newer()<cr>'
		exe 'nnoremap ' . prefix . '<pagedown> :call wheel#pendulum#older()<cr>'
		exe 'nnoremap ' . prefix . '^ :call wheel#pendulum#alternate()<cr>'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" Tabs
		exe 'nnoremap ' . prefix . "t :call wheel#mosaic#tabs('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-t> :call wheel#mosaic#tabs('circle')<cr>"
		exe 'nnoremap ' . prefix . "T :call wheel#mosaic#tabs('torus')<cr>"
		" Windows
		exe 'nnoremap ' . prefix . "s :call wheel#mosaic#split('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-s> :call wheel#mosaic#split('circle')<cr>"
		exe 'nnoremap ' . prefix . "S :call wheel#mosaic#split('torus')<cr>"
		exe 'nnoremap ' . prefix . "v :call wheel#mosaic#split('location', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "<c-v> :call wheel#mosaic#split('circle', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "V :call wheel#mosaic#split('torus', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "l :call wheel#mosaic#split('location', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "<c-l> :call wheel#mosaic#split('circle', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "L :call wheel#mosaic#split('torus', 'main_left')<cr>"
		exe 'nnoremap ' . prefix . "g :call wheel#mosaic#split_grid('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-g> :call wheel#mosaic#split_grid('circle')<cr>"
		exe 'nnoremap ' . prefix . "G :call wheel#mosaic#split_grid('torus')<cr>"
		" Rotating windows
		exe 'nnoremap ' . prefix . '<up> :call wheel#mosaic#rotate_counter_clockwise()<cr>'
		exe 'nnoremap ' . prefix . '<down> :call wheel#mosaic#rotate_clockwise()<cr>'
		" Tabs & Windows
		exe 'nnoremap ' . prefix . 'z :call wheel#mosaic#zoom()<cr>'
		exe 'nnoremap ' . prefix . "P :call wheel#pyramid#steps('torus')<cr>"
		exe 'nnoremap ' . prefix . "<c-p> :call wheel#pyramid#steps('circle')<cr>"
		" Search inside files
		exe 'nnoremap ' . prefix . ': :call wheel#sailing#occur()<cr>'
		exe 'nnoremap ' . prefix . '* :call wheel#sailing#grep()<cr>'
		exe 'nnoremap ' . prefix . '# :call wheel#sailing#outline()<cr>'
		exe 'nnoremap ' . prefix . '% :call wheel#sailing#symbol()<cr>'
		" Search for files
		exe 'nnoremap ' . prefix . '? :call wheel#sailing#attic()<cr>'
		exe 'nnoremap ' . prefix . '/ :call wheel#sailing#locate()<cr>'
		exe 'nnoremap ' . prefix . '& :call wheel#sailing#find()<cr>'
		" Yank wheel
		exe 'nnoremap ' . prefix . "y :call wheel#clipper#yank('list')<cr>"
		exe 'nnoremap ' . prefix . "<m-y> :call wheel#clipper#yank('plain')<cr>"
		" Reorganize
		exe 'nnoremap ' . prefix . '<m-o> :call wheel#shape#reorganize()<cr>'
		" Save (push) wheel buffer
		exe 'nnoremap ' . prefix . '<tab> :call wheel#mandala#push()<cr>'
		" Remove (pop) wheel buffer
		exe 'nnoremap ' . prefix . '<backspace> :call wheel#mandala#pop()<cr>'
		" Cycle wheel buffers
		exe 'nnoremap ' . prefix . '@ :call wheel#mandala#cycle()<cr>'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Menus
		nnoremap <M-=>        :call wheel#hub#meta()<cr>
		nnoremap <M-m>        :call wheel#hub#main()<cr>
		" Add, Delete
		nnoremap <M-Insert>   :call wheel#tree#add_here()<cr>
		nnoremap <M-Del>      :call wheel#tree#delete('location')<cr>
		" Next / Previous
		nnoremap <C-PageUp>   :call wheel#vortex#previous('location')<cr>
		nnoremap <C-PageDown> :call wheel#vortex#next('location')<cr>
		nnoremap <C-Home>     :call wheel#vortex#previous('circle')<cr>
		nnoremap <C-End>      :call wheel#vortex#next('circle')<cr>
		nnoremap <S-Home>     :call wheel#vortex#previous('torus')<cr>
		nnoremap <S-End>      :call wheel#vortex#next('torus')<cr>
		" History
		nnoremap <S-PageUp>     :call wheel#pendulum#newer()<cr>
		nnoremap <S-PageDown>   :call wheel#pendulum#older()<cr>
		" Alternate
		nnoremap <C-^>          :call wheel#pendulum#alternate()<cr>
		nnoremap <D-^>          :call wheel#pendulum#alternate_same_torus_other_circle()<cr>
		nnoremap <C-S-PageUp>   :call wheel#pendulum#alternate_same_torus()<cr>
		nnoremap <C-S-PageDown> :call wheel#pendulum#alternate_same_circle()<cr>
		nnoremap <C-S-Home>     :call wheel#pendulum#alternate_other_torus()<cr>
		nnoremap <C-S-End>      :call wheel#pendulum#alternate_other_circle()<cr>
		" Navigation buffers
		nnoremap <Space>      :call wheel#sailing#switch('location')<cr>
		nnoremap <C-Space>    :call wheel#sailing#switch('circle')<cr>
		nnoremap <S-Space>    :call wheel#sailing#switch('torus')<cr>
		nnoremap <M-x>        :call wheel#sailing#tree()<cr>
		nnoremap <D-x>        :call wheel#sailing#helix()<cr>
		nnoremap <M-h>        :call wheel#sailing#history()<cr>
		" Reshaping buffers
		nnoremap <M-r>        :call wheel#shape#reorganize()<cr>
		" Search inside files
		nnoremap <M-s>          :call wheel#sailing#occur()<cr>
		nnoremap <M-g>          :call wheel#sailing#grep()<cr>
		nnoremap <M-o>          :call wheel#sailing#outline()<cr>
		nnoremap <M-t>          :call wheel#sailing#symbol()<cr>
		" Search for files
		nnoremap <M-u>          :call wheel#sailing#attic()<cr>
		nnoremap <M-l>          :call wheel#sailing#locate()<cr>
		nnoremap <M-f>          :call wheel#sailing#find()<cr>
		" Yank
		nnoremap <M-y>          :call wheel#clipper#yank('list')<cr>
		nnoremap <M-p>          :call wheel#clipper#yank('plain')<cr>
		" Batch
		nnoremap <M-b>          :WheelBatch<space>
		" Windows
		nnoremap <M-z>          :call wheel#mosaic#zoom()<cr>
		nnoremap <M-Home>       :call wheel#mosaic#tabs('location')<cr>
		nnoremap <M-End>        :call wheel#mosaic#split('location', 'main_left')<cr>
		nnoremap <M-&>          :call wheel#pyramid#steps('circle')<cr>
		" Rotate windows
		nnoremap <M-PageUp>     :call wheel#mosaic#rotate_counter_clockwise()<cr>
		nnoremap <M-PageDown>   :call wheel#mosaic#rotate_clockwise()<cr>
		" Save (push) wheel buffer
		nnoremap <M-Tab>        :call wheel#mandala#push()<cr>
		" Remove (pop) wheel buffer
		nnoremap <M-Backspace>  :call wheel#mandala#pop()<cr>
		" Cycle wheel buffers
		nnoremap <M-Space>      :call wheel#mandala#cycle()<cr>
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe 'nnoremap ' . prefix . "Z :call wheel#void#fresh_wheel()<cr>"
	endif
endfun

