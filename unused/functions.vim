" vim: set ft=vim fdm=indent iskeyword&:

" Unused functions

fun! wheel#disc#write (pointer, file, where = '>')
	" Write variable referenced by pointer to file
	" in a format that can be :sourced
	" Note : pointer = variable name in vim script
	" If optional argument 1 is :
	"   - '>' : replace file content (default)
	"   - '>>' : append to file content
	" Doesn't work well with some abbreviated echoed variables content in vim
	" disc#writefile is more reliable with vim
	let pointer = a:pointer
	if ! exists(pointer)
		return
	endif
	let file = fnamemodify(a:file, ':p')
	let where = a:where
	" create directory if needed
	let directory = fnamemodify(file, ':h')
	let returnstring = wheel#disc#mkdir(directory)
	if returnstring ==# 'failure'
		return v:false
	endif
	" write
	let var = {pointer}
	redir => content
	silent! echo 'let' pointer '=' var
	redir END
	let content = substitute(content, '\m[=,]', '\0\n\\', 'g')
	let content = substitute(content, '\m\n\{2,\}', '\n', 'g')
	exec 'redir!' where file
	silent! echo content
	redir END
endfun

fun! wheel#disc#read (file)
	" Read file
	let file = fnamemodify(a:file, ':p')
	if ! filereadable(file)
		echomsg 'Could not read' file
	endif
	execute 'source' file
endfun

fun! wheel#pendulum#older (level = 'wheel')
	" Go to older entry in g:wheel_history.circuit
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel older :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#older_anywhere ()
	endif
	" current coordin
	let names = wheel#referen#names ()
	" index for range in coordin
	let level_index = wheel#referen#coordin_index (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_left (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_left (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" older found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel older : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a copy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#pendulum#newer (level = 'wheel')
	" Go to newer entry in g:wheel_history.circuit
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel newer :' level 'is empty'
		return v:false
	endif
	if level == 'wheel'
		return wheel#pendulum#newer_anywhere ()
	endif
	" current coordin
	let names = wheel#referen#names ()
	" index for range in coordin
	let level_index = wheel#referen#coordin_index (level)
	" back in history
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#chain#rotate_right (timeloop)
	let coordin = timeloop[0].coordin
	let counter = 0
	let length = len(timeloop)
	while names[:level_index] != coordin[:level_index] && counter < length
		let timeloop = wheel#chain#rotate_right (timeloop)
		let coordin = timeloop[0].coordin
		let counter += 1
	endwhile
	" newer found in same torus or circle ?
	if names[:level_index] != coordin[:level_index]
		echomsg 'wheel newer : no location found in same' level
		return v:false
	endif
	" update timeloop : rotate left / right return a deepcopy
	let g:wheel_history.circuit = timeloop
	" jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#cylinder#first (window = 'furtive')
	" Add first mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let bufring = g:wheel_bufring
	let mandalas = g:wheel_bufring.mandalas
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	" -- empty ring ?
	if ! empty(mandalas)
		echomsg 'wheel cylinder first : mandala ring is not empty'
		return v:false
	endif
	call wheel#cylinder#delete_unused ()
	" ---- pre op buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" ---- new buffer
	if window == 'split'
		call wheel#cylinder#split ()
		hide enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current one has no name
			" so we need to use :new
			new
		else
			hide enew
		endif
	endif
	let novice = bufnr('%')
	" ---- add
	let bufring.current = 0
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	eval mandalas->add(novice)
	eval iden->add(0)
	eval names->add('0')
	eval types->add('')
	" ---- set filename
	call wheel#cylinder#filename ()
	" ---- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" ---- coda
	if window == 'furtive'
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			execute 'silent hide buffer' cur_buffer
		endif
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

fun! wheel#cylinder#add (window = 'furtive')
	" Add new mandala buffer
	" Optional argument :
	"   - furtive (default) : use current window and go back to previous buffer at the end
	"   - split : use a split
	let window = a:window
	let bufring = g:wheel_bufring
	" ---- pre-checks
	if ! window->wheel#chain#is_inside(['split', 'furtive'])
		echomsg 'wheel cylinder first : bad window argument'
		return v:false
	endif
	call wheel#cylinder#check ()
	call wheel#cylinder#delete_unused ()
	" ---- first one
	let mandalas = bufring.mandalas
	if empty(mandalas)
		return wheel#cylinder#first (window)
	endif
	" ---- not the first one
	" -- is current buffer a mandala buffer ?
	let was_mandala = wheel#cylinder#is_mandala ()
	" -- previous current mandala
	let current = bufring.current
	let elder = mandalas[current]
	" -- mandala window
	if window == 'split'
		call wheel#cylinder#window ('window')
	endif
	" -- pre op buffer
	let cur_buffer = bufnr('%')
	let empty_cur_buffer = empty(bufname(cur_buffer))
	" -- new buffer
	if window == 'split'
		call wheel#cylinder#split ()
		hide enew
	else
		if empty_cur_buffer
			" :enew does not create a new buffer if current want has no name
			" so we need to use :new
			new
		else
			hide enew
		endif
	endif
	let novice = bufnr('%')
	if novice == elder
		echomsg 'wheel mandala add : buffer' novice 'already in ring'
		return v:false
	endif
	" -- add
	let next = current + 1
	eval mandalas->insert(novice, next)
	let bufring.current = next
	let iden = bufring.iden
	let names = bufring.names
	let types = bufring.types
	let novice_iden = wheel#chain#lowest_outside (iden)
	let novice_name = string(novice_iden)
	eval iden->insert(novice_iden, next)
	eval names->insert(novice_name, next)
	eval types->insert('', next)
	" -- set filename
	call wheel#cylinder#filename ()
	" -- init mandala
	call wheel#mandala#init ()
	call wheel#mandala#common_maps ()
	" -- coda
	if window == 'furtive' && ! was_mandala
		if empty_cur_buffer
			" :new has opened a split, close it
			noautocmd close
		else
			execute 'silent hide buffer' cur_buffer
		endif
	endif
	call wheel#status#mandala_leaf ()
	return v:true
endfun

fun! wheel#centre#commands ()
	" Define commands
	" ---- meta command
	command! -nargs=* -complete=customlist,wheel#complete#meta_command Wheel call wheel#centre#meta(<f-args>)
	" ---- status
	command! WheelDashboard call wheel#status#dashboard()
	command! WheelJump      call wheel#vortex#jump()
	command! WheelFollow    call wheel#projection#follow()
	" ---- read / write
	command! WheelRead         call wheel#disc#read_wheel()
	command! WheelWrite        call wheel#disc#write_wheel()
	command! WheelReadSession  call wheel#disc#read_session()
	command! WheelWriteSession call wheel#disc#write_session()
	" ---- batch
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
	" ---- autogroup
	command! WheelAutogroup call wheel#group#menu()
	" ---- disc
	command! -nargs=+ -complete=file WheelMkdir  call wheel#disc#mkdir(<f-args>)
	command! -nargs=+ -complete=file WheelRename call wheel#disc#rename(<f-args>)
	command! -nargs=+ -complete=file WheelCopy   call wheel#disc#copy(<f-args>)
	command! -nargs=+ -complete=file WheelDelete call wheel#disc#delete(<f-args>)
	" ---- tree of symlinks/files reflecting wheel structure
	command! WheelTreeScript  call wheel#disc#tree_script()
	command! WheelSymlinkTree call wheel#disc#symlink_tree()
	command! WheelCopiedTree  call wheel#disc#copied_tree()
endfun

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
	nnoremap <plug>(wheel-prompt-switch-register) <cmd>call wheel#codex#switch_default()<cr>
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

