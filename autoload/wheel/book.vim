" vim: set ft=vim fdm=indent iskeyword&:

" Book
"
" Leaf (layer) ring in each mandala buffer
"
" Each leaf contains all information about a mandala
"
" A book contains leaves, sheets, layers

" ---- script constants

if exists('s:mandala_options')
	unlockvar s:mandala_options
endif
let s:mandala_options = wheel#crystal#fetch('mandala/options')
lockvar s:mandala_options

if exists('s:map_keys')
	unlockvar s:map_keys
endif
let s:map_keys = wheel#crystal#fetch('map/keys')
lockvar s:map_keys

if exists('s:mandala_autocmds_group')
	unlockvar s:mandala_autocmds_group
endif
let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
lockvar s:mandala_autocmds_group

if exists('s:mandala_autocmds_events')
	unlockvar s:mandala_autocmds_events
endif
let s:mandala_autocmds_events = wheel#crystal#fetch('mandala/autocmds/events')
lockvar s:mandala_autocmds_events

if exists('s:mandala_vars')
	unlockvar s:mandala_vars
endif
let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
lockvar s:mandala_vars

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- helpers

fun! wheel#book#indexes_to_keep ()
	" Return list of indexes to keep & new current index
	" Used to keep ring length <= g:wheel_config.maxim.layers
	let maxim = g:wheel_config.maxim.layers
	" ring
	let ring = b:wheel_ring
	let current = ring.current
	let leaves = ring.leaves
	let length = len(leaves)
	" still under maxim : nothing to do
	if length < maxim
		return []
	endif
	" euclidian integer division
	if maxim % 2 == 1
		let share = maxim / 2
	else
		let share = maxim / 2 - 1
	endif
	let delta = current - share
	" indexes
	let indexes = range(maxim)
	eval indexes->map({ _, val -> val + delta })
	eval indexes->map({ _, val -> val % length })
	for ind in range(maxim)
		if indexes[ind] < 0
			let indexes[ind] += length
		endif
	endfor
	" new current
	let new_current = share
	return [indexes, new_current]
endfun

fun! wheel#book#limit ()
	" Limit number of leaves to the configured maximum
	" Used to keep ring length <= g:wheel_config.maxim.layers
	let maxim = g:wheel_config.maxim.layers
	" ring
	let ring = b:wheel_ring
	let leaves = ring.leaves
	let length = len(leaves)
	" still under maxim : nothing to do
	if length < maxim
		" still under maxim
		" nothing to do
		return v:false
	endif
	let [indexes, new_current] = wheel#book#indexes_to_keep ()
	let new_leaves = leaves->wheel#chain#sublist(indexes)
	let ring.current = new_current
	let ring.leaves = new_leaves
	return v:true
endfun

fun! wheel#book#template ()
	" Return empty template leaf
	let leaf = {}
	" -- vim stuff
	let leaf.filename = ''
	let leaf.options = {}
	let leaf.mappings = {}
	let leaf.autocmds = {}
	" -- general qualities
	let leaf.nature = {}
	let leaf.nature.empty = v:true
	let leaf.nature.class = 'generic'
	let leaf.nature.type = 'empty'
	let leaf.nature.is_treeish = v:false
	let leaf.nature.is_writable = v:false
	let leaf.nature.has_filter = v:false
	let leaf.nature.has_selection = v:false
	let leaf.nature.has_preview = v:false
	let leaf.nature.has_navigation = v:false
	" -- related
	let leaf.related = {}
	let leaf.related.tabnum = 'undefined'
	let leaf.related.winum = 'undefined'
	let leaf.related.winiden = 'undefined'
	let leaf.related.bufnum = 'undefined'
	" -- all original lines
	let leaf.lines = []
	" -- all original full lines information
	let leaf.full = []
	" -- filter
	let leaf.filter = {}
	let leaf.filter.words = []
	let leaf.filter.indexes = []
	let leaf.filter.lines = []
	" -- selection
	let leaf.selection = {}
	let leaf.selection.indexes = []
	let leaf.selection.components = []
	" -- preview
	let leaf.preview = {}
	let leaf.preview.used = v:false
	let leaf.preview.follow = v:false
	let leaf.preview.original = 'undefined'
	" -- cursor
	let leaf.cursor = {}
	let leaf.cursor.position = []
	let leaf.cursor.selection = {}
	" -- settings for loop & line functions
	let leaf.settings = {}
	" -- reload function string
	let leaf.reload = ''
	" coda
	return leaf
endfun

" ---- init ring

fun! wheel#book#init ()
	" Init ring
	if exists('b:wheel_ring')
		return v:false
	endif
	let b:wheel_ring = {}
	let ring = b:wheel_ring
	let ring.current = 0
	let ring.leaves = [ wheel#book#template () ]
	return v:true
endfun

" ---- access elements

fun! wheel#book#ring (...)
	" Return ring of field given by optional argument
	" Return all book (leaves ring) if no argument is given
	if a:0 == 0
		return b:wheel_ring.leaves
	endif
	let ring = b:wheel_ring
	let fieldname = a:1
	let field_ring = []
	for elem in ring.leaves
		let shadow = deepcopy(elem[fieldname])
		eval field_ring->add(shadow)
	endfor
	return field_ring
endfun

fun! wheel#book#previous (...)
	" Return previous field given by optional argument
	" Return previous leaf if no argument is given
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel book previous : empty leaf ring (should not happen)'
		return v:false
	endif
	if length == 1
		echomsg 'wheel book previous : only one leaf in the ring'
		return []
	endif
	let previous = wheel#taijitu#circular_minus (ring.current, length)
	if a:0 == 0
		return ring.leaves[previous]
	endif
	let fieldname = a:1
	return ring.leaves[previous][fieldname]
endfun

fun! wheel#book#current (...)
	" Return current field given by optional argument
	" Return current leaf if no argument is given
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel book previous : empty leaf ring (should not happen)'
		return v:false
	endif
	let current = ring.current
	if a:0 == 0
		return ring.leaves[current]
	endif
	let fieldname = a:1
	return ring.leaves[current][fieldname]
endfun

fun! wheel#book#next (...)
	" Return next field given by optional argument
	" Return next leaf if no argument is given
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel book next : empty leaf ring (should not happen)'
		return v:false
	endif
	if length == 1
		echomsg 'wheel book next : only one leaf in the ring'
		return []
	endif
	let next = wheel#taijitu#circular_plus (ring.current, length)
	if a:0 == 0
		return ring.leaves[next]
	endif
	let fieldname = a:1
	return ring.leaves[next][fieldname]
endfun

" ---- saving things

fun! wheel#book#save_options ()
	" Save options
	return wheel#ouroboros#save_options (s:mandala_options)
endfun

fun! wheel#book#save_maps ()
	" Save maps
	return wheel#ouroboros#save_maps (s:map_keys)
endfun

fun! wheel#book#save_autocmds ()
	" Save autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	return wheel#ouroboros#save_autocmds (group, events)
endfun

" ---- restoring things

fun! wheel#book#restore_autocmds (autodict)
	" Restore autocommands
	let group = s:mandala_autocmds_group
	call wheel#ouroboros#restore_autocmds (group, a:autodict)
endfun

" Sync

fun! wheel#book#syncup ()
	" Sync mandala state to current leaf in ring
	" state = vars, options, maps, autocmds
	" -- empty mandala ?
	if wheel#mandala#is_empty()
		return v:false
	endif
	" -- update visible lines -> local vars lines
	call wheel#polyphony#update_var_lines ()
	" -- leaves ring
	let ring = b:wheel_ring
	" -- leaf to fill / update
	let current = ring.current
	let leaf = ring.leaves[current]
	" -- pseudo filename
	let leaf.filename = expand('%')
	" -- options
	let leaf.options = wheel#book#save_options ()
	" -- mappings
	let leaf.mappings = wheel#book#save_maps ()
	" -- autocommands
	let leaf.autocmds = wheel#book#save_autocmds ()
	" -- general qualities
	let leaf.nature = copy(b:wheel_nature)
	" -- related
	let leaf.related = b:wheel_related
	" -- all original lines
	let leaf.lines = copy(b:wheel_lines)
	" -- all original full lines information
	let leaf.full = deepcopy(b:wheel_full)
	" -- filter
	let leaf.filter = deepcopy(b:wheel_filter)
	" -- selection
	let leaf.selection = deepcopy(b:wheel_selection)
	" -- preview
	let leaf.preview = copy(b:wheel_preview)
	" -- cursor
	" position
	call wheel#teapot#filter_to_default_line ()
	let cursor = leaf.cursor
	let cursor.position = getcurpos()
	" virtual selection of cursor line : useful for context menus
	let cursor.selection = wheel#pencil#virtual()
	" -- settings
	let leaf.settings = deepcopy(b:wheel_settings)
	" -- reload
	let leaf.reload = b:wheel_reload
	return v:true
endfun

fun! wheel#book#syncdown ()
	" Sync current leaf in ring to mandala state
	" state = vars, options, maps, autocmds
	" -- leaves ring
	let ring = b:wheel_ring
	" -- leaf to activate
	let current = ring.current
	let leaf = ring.leaves[current]
	" -- pseudo filename
	let pseudo_file = leaf.filename
	execute 'silent file' pseudo_file
	" -- options
	call wheel#ouroboros#restore_options (leaf.options)
	" -- mappings
	let mappings = deepcopy(leaf.mappings)
	call wheel#ouroboros#restore_maps (mappings)
	" -- autocommands
	let autodict = deepcopy(leaf.autocmds)
	call wheel#book#restore_autocmds (autodict)
	" -- general qualities
	let b:wheel_nature = copy(leaf.nature)
	" -- related
	let b:wheel_related = leaf.related
	" -- all original lines
	let b:wheel_lines = copy(leaf.lines)
	" -- all original full lines information
	let b:wheel_full = deepcopy(leaf.full)
	" -- filter
	let filter = deepcopy(leaf.filter)
	let b:wheel_filter = filter
	if wheel#teapot#has_filter ()
		" filter available
		if wheel#teapot#is_filtered ()
			" filtered
			let visible_lines = filter.lines
			call wheel#teapot#set_prompt (filter.words)
		else
			" not filtered
			let visible_lines = b:wheel_lines
			call wheel#teapot#set_prompt ()
		endif
		call wheel#mandala#replace (visible_lines, 'keep-first')
	else
		" no filter
		let visible_lines = b:wheel_lines
		call wheel#mandala#replace (visible_lines, 'delete-first')
	endif
	" -- selection
	let b:wheel_selection = deepcopy(leaf.selection)
	call wheel#pencil#show ()
	" -- preview
	let b:wheel_preview = copy(leaf.preview)
	" -- cursor
	let cursor = deepcopy(leaf.cursor)
	" position ; must be done after mandala#replace
	call wheel#gear#restore_cursor (cursor.position)
	" -- settings
	let b:wheel_settings = deepcopy(leaf.settings)
	" -- reload
	let b:wheel_reload = leaf.reload
	" -- tell (neo)vim the buffer is to be considered not modified
	setlocal nomodified
	call wheel#status#mandala_leaf ()
endfun

" ---- add & delete

fun! wheel#book#add (clear_mandala = 'dont-clear')
	" Add empty leaf in ring
	" Optional argument :
	"   - default : add a new leaf
	"   - clear : add a new leaf and clear mandala
	let clear_mandala = a:clear_mandala
	" -- first leaf
	if wheel#book#init ()
		return v:false
	endif
	" -- empty mandala
	if wheel#mandala#is_empty ()
		return v:false
	endif
	" -- sync up old leaf
	call wheel#book#syncup ()
	" -- new leaf
	let leaf = wheel#book#template ()
	let ring = b:wheel_ring
	let next = ring.current + 1
	eval ring.leaves->insert(leaf, next)
	let ring.current = next
	call wheel#book#limit ()
	" -- clear mandala
	if clear_mandala ==# 'clear'
		call wheel#mandala#clear ()
	endif
	return v:true
endfun

fun! wheel#book#delete ()
	" Delete current leaf in ring
	let ring = b:wheel_ring
	let leaves = ring.leaves
	let length = len(leaves)
	" -- do not delete element from empty ring
	if length == 0
		echomsg 'wheel book delete : empty leaf ring (should not happen)'
		return v:false
	endif
	" -- do not delete element from one element ring
	if length == 1
		echomsg 'wheel book delete :' leaves[0].nature.type 'is the last layer in ring'
		return v:false
	endif
	" -- do not delete if child context menu is next
	let next_nature = wheel#book#next('nature')
	let next_class = next_nature.class
	if next_class  ==# 'menu/context'
		let info = 'Please delete child context menu first. '
		let info ..= 'Press <M-j> to access it, backspace to remove.'
		echomsg info
		return v:false
	endif
	" -- delete
	let current = ring.current
	eval ring.leaves->remove(current)
	let length -= 1
	let ring.current = wheel#taijitu#circular_minus (current, length)
	call wheel#book#syncdown ()
	call wheel#cylinder#update_type ()
	return v:true
endfun

" ---- forward & backward

fun! wheel#book#forward ()
	" Go forward in layer ring
	if wheel#mandala#is_empty()
		echomsg 'wheel book forward : deleting empty leaf'
		call wheel#book#delete ()
	endif
	call wheel#book#syncup ()
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel layer forward : empty ring'
		return v:false
	endif
	let current = ring.current
	let ring.current = wheel#taijitu#circular_plus (current, length)
	call wheel#book#syncdown ()
	call wheel#cylinder#update_type ()
endfun

fun! wheel#book#backward ()
	" Go backward in layer ring
	if wheel#mandala#is_empty()
		echomsg 'wheel book backward : deleting empty leaf'
		call wheel#book#delete ()
	endif
	call wheel#book#syncup ()
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel layer backward : empty ring'
		return v:false
	endif
	let current = ring.current
	let ring.current = wheel#taijitu#circular_minus (current, length)
	call wheel#book#syncdown ()
	call wheel#cylinder#update_type ()
endfun

" ---- switch

fun! wheel#book#switch (...)
	" Switch to leaf with completion
	if wheel#mandala#is_empty()
		echomsg 'wheel book switch : deleting empty leaf'
		call wheel#book#delete ()
	endif
	call wheel#book#syncup ()
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel layer switch : empty layer ring'
		return v:false
	endif
	let prompt = 'Switch to leaf : '
	let complete = 'customlist,wheel#complete#leaf'
	if a:0 > 0
		let chosen = a:1
	else
		let chosen = input(prompt, '', complete)
	endif
	if empty(chosen)
		return v:false
	endif
	let current = split(chosen, s:field_separ)[0]
	let current = str2nr(current)
	let ring.current = current
	call wheel#book#syncdown ()
	call wheel#cylinder#update_type ()
endfun
