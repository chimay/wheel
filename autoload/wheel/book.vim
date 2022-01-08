" vim: set ft=vim fdm=indent iskeyword&:

" Layers ring in each mandala buffer
"
" A book contains leaves, sheets, layers

" second implementation
"
" the ring contain the current mandala lines & settings

" Script constants

if ! exists('s:mandala_options')
	let s:mandala_options = wheel#crystal#fetch('mandala/options')
	lockvar s:mandala_options
endif

if ! exists('s:map_keys')
	let s:map_keys = wheel#crystal#fetch('map/keys')
	lockvar s:map_keys
endif

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:mandala_autocmds_events')
	let s:mandala_autocmds_events = wheel#crystal#fetch('mandala/autocmds/events')
	lockvar s:mandala_autocmds_events
endif

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

" Init ring

fun! wheel#book#init ()
	" Init ring and buffer variables
	call wheel#mandala#init ()
	if ! exists('b:wheel_ring')
		let b:wheel_ring = {}
		let ring = b:wheel_ring
		" index of current leaf
		let ring.current = -1
		let ring.leaves = []
	endif
endfun

" State

fun! wheel#book#ring (...)
	" Return ring of field given by optional argument
	" Return all book (leaves ring) if no argument is given
	" Useful for debugging
	if a:0 == 0
		return b:wheel_ring.leaves
	endif
	let ring = b:wheel_ring
	let fieldname = a:1
	let field_stack = []
	for elem in ring.leaves
		let shadow = deepcopy(elem[fieldname])
		call add(field_stack, shadow)
	endfor
	return field_stack
endfun

fun! wheel#book#previous (...)
	" Return previous field given by optional argument
	" Return previous leaf if no argument is given
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	let previous = wheel#gear#circular_minus (ring.current, length)
	if a:0 == 0
		return ring.leaves[previous]
	endif
	let fieldname = a:1
	return ring.leaves[previous][fieldname]
endfun

" Clearing things

fun! wheel#book#clear_options ()
	" Clear mandala local options
	setlocal nofoldenable
endfun

fun! wheel#book#clear_maps ()
	" Clear mandala local maps
	call wheel#gear#unmap(s:map_keys)
endfun

fun! wheel#book#clear_autocmds ()
	" Clear mandala local autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	call wheel#gear#clear_autocmds (group, events)
endfun

fun! wheel#book#clear_vars ()
	" Clear mandala local variables, except the leaves ring
	call wheel#gear#unlet (s:mandala_vars)
endfun

fun! wheel#book#fresh ()
	" Fresh empty leaves : clear mandala local data
	call wheel#book#clear_options ()
	call wheel#book#clear_maps ()
	call wheel#book#clear_autocmds ()
	call wheel#book#clear_vars ()
	" delete lines -> underscore _ = no storing register
	silent! 1,$ delete _
endfun

" Saving things

fun! wheel#book#save_options ()
	" Save options
	return wheel#gear#save_options (s:mandala_options)
endfun

fun! wheel#book#save_maps ()
	" Save maps
	return wheel#gear#save_maps (s:map_keys)
endfun

fun! wheel#book#save_autocmds ()
	" Save autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	return wheel#gear#save_autocmds (group, events)
endfun

" Restoring things

fun! wheel#book#restore_autocmds (autodict)
	" Restore autocommands
	let group = s:mandala_autocmds_group
	call wheel#gear#restore_autocmds (group, a:autodict)
endfun

" Sync

fun! wheel#book#syncup ()
	" Sync mandala state to current leaf in ring
	" state = vars, options, maps, autocmds
	" -- init leaf ring if necessary
	call wheel#book#init ()
	" -- build leaf
	let leaf = {}
	" pseudo filename
	let leaf.filename = expand('%')
	" options
	let leaf.options = wheel#layer#save_options ()
	" mappings
	let leaf.mappings = wheel#layer#save_maps ()
	" autocommands
	let leaf.autocmds = wheel#layer#save_autocmds ()
	" lines, without filtering
	if empty(b:wheel_lines)
		let begin = wheel#mandala#first_data_line ()
		let leaf.lines = getline(begin, '$')
	else
		let leaf.lines = copy(b:wheel_lines)
	endif
	" filtered content
	let leaf.filtered = getline(1, '$')
	" cursor position
	let leaf.position = getcurpos()
	" address of cursor line
	" useful for boomerang = context menus
	let leaf.address = wheel#line#address()
	" selected lines
	let leaf.selected = deepcopy(b:wheel_selected)
	" settings
	if exists('b:wheel_settings')
		let leaf.settings = b:wheel_settings
	else
		let leaf.settings = {}
	endif
	" reload
	if exists('b:wheel_reload')
		let leaf.reload = b:wheel_reload
	else
		let leaf.reload = ''
	endif
	" add to leaf ring
	let ring = b:wheel_ring
	let current = ring.current
	let length = length(ring.leaves)
endfun

fun! wheel#book#syncdown ()
	" Sync current leaf in ring to mandala state
	" state = vars, options, maps, autocmds
	let ring = b:wheel_ring
	let length = length(ring.leaves)
	if length == 0)
		echomsg 'wheel book syncdown : empty ring'
		return v:false
	endif
	let current = ring.current
	let leaf = ring.leaves[current]
	" pseudo filename
	let pseudo_file = leaf.filename
	exe 'silent file' pseudo_file
	" options
	call wheel#gear#restore_options (leaf.options)
	" mappings
	let mappings = deepcopy(leaf.mappings)
	call wheel#gear#restore_maps (mappings)
	" autocommands
	let autodict = copy(leaf.autocmds)
	call wheel#book#restore_autocmds (autodict)
	" lines, without filtering
	let b:wheel_lines = copy(leaf.lines)
	" filtered mandala content
	" leaf.filtered should contain also the original first line, so we have
	" to delete the first line added by :put in the replace routine
	call wheel#mandala#replace (leaf.filtered, 'delete')
	" cursor position
	call wheel#gear#restore_cursor (leaf.position)
	" address linked to cursor line & context
	let b:wheel_address = copy(leaf.address)
	" selection
	let b:wheel_selected = deepcopy(leaf.selected)
	" settings
	let b:wheel_settings = deepcopy(leaf.settings)
	" reload
	let b:wheel_reload = leaf.reload
	" Tell (neo)vim the buffer is to be considered not modified
	setlocal nomodified
endfun

