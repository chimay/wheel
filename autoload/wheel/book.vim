" vim: set ft=vim fdm=indent iskeyword&:

" Leaf (layer) ring in each mandala buffer
"
" A book contains leaves, sheets, layers

" second implementation
"
" the ring contain the current mandala lines & settings

" Script constants

if ! exists('s:mandala_prompt')
	let s:mandala_prompt = wheel#crystal#fetch('mandala/prompt')
	lockvar s:mandala_prompt
endif

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

" Helpers

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
	let leaf.nature.type = 'empty'
	let leaf.nature.has_filter = v:false
	let leaf.nature.has_selection = v:false
	let leaf.nature.menu = v:false
	let leaf.nature.context_menu = v:false
	" -- related buffer
	let leaf.related_buffer = 'undefined'
	" -- all original lines
	let leaf.lines = []
	" -- filter
	let leaf.filter = {}
	let leaf.filter.words = []
	let leaf.filter.indexes = []
	let leaf.filter.lines = []
	" -- selection
	let leaf.selection = {}
	let leaf.selection.indexes = []
	let leaf.selection.addresses = []
	" -- preview
	let leaf.preview = {}
	let leaf.preview.switch = v:false
	let leaf.preview.follow = v:false
	" -- cursor
	let leaf.cursor = {}
	let leaf.cursor.position = []
	let leaf.cursor.address = ''
	" -- settings for loop & line functions
	let leaf.settings = {}
	" -- reload function string
	let leaf.reload = ''
	" coda
	return leaf
endfun

" Init ring

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

" Access elements

fun! wheel#book#ring (...)
	" Return ring of field given by optional argument
	" Return all book (leaves ring) if no argument is given
	" Useful for debugging
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
	let previous = wheel#gear#circular_minus (ring.current, length)
	if a:0 == 0
		return ring.leaves[previous]
	endif
	let fieldname = a:1
	return ring.leaves[previous][fieldname]
endfun

fun! wheel#book#previous_selected ()
	" Return selected addresses of previous leaf in ring
	" If empty, return previous address of current line
	let addresses = wheel#book#previous('selection').addresses
	if empty(addresses)
		return [ wheel#book#previous('cursor').address ]
	elseif type(addresses) == v:t_list
		return addresses
	else
		echomsg 'wheel book previous_selected : bad previous selection addresses'
		return []
	endif
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
	" ---- empty mandala ?
	if wheel#mandala#is_empty()
		return v:false
	endif
	" ---- sync up
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
	" -- related buffer
	let leaf.related_buffer = b:wheel_related_buffer
	" -- all original lines
	let leaf.lines = copy(b:wheel_lines)
	" -- filter
	let leaf.filter = deepcopy(b:wheel_filter)
	" -- selection
	let leaf.selection = deepcopy(b:wheel_selection)
	" -- preview
	let leaf.preview = copy(b:wheel_preview)
	" -- cursor
	" position
	call wheel#line#default ()
	let cursor = leaf.cursor
	let cursor.position = getcurpos()
	" address of cursor line : useful for context menus
	let cursor.address = wheel#line#address()
	" -- settings
	let leaf.settings = deepcopy(b:wheel_settings)
	" -- reload
	let leaf.reload = b:wheel_reload
	return v:true
endfun

fun! wheel#book#syncdown ()
	" Sync current leaf in ring to mandala state
	" state = vars, options, maps, autocmds
	" -- leaf to activate
	let ring = b:wheel_ring
	let current = ring.current
	let leaf = ring.leaves[current]
	" -- pseudo filename
	let pseudo_file = leaf.filename
	execute 'silent file' pseudo_file
	" -- options
	call wheel#gear#restore_options (leaf.options)
	" -- mappings
	let mappings = deepcopy(leaf.mappings)
	call wheel#gear#restore_maps (mappings)
	" -- autocommands
	let autodict = copy(leaf.autocmds)
	call wheel#book#restore_autocmds (autodict)
	" -- general qualities
	let b:wheel_nature = copy(leaf.nature)
	" -- related buffer
	let b:wheel_related_buffer = leaf.related_buffer
	" -- all original lines
	let b:wheel_lines = copy(leaf.lines)
	" -- filter
	let filter = deepcopy(leaf.filter)
	let b:wheel_filter = filter
	if wheel#teapot#has_filter ()
		" filter available
		if wheel#teapot#is_filtered ()
			" filtered
			let visible_lines = filter.lines
			call wheel#teapot#prompt (filter.words)
		else
			" not filtered
			let visible_lines = b:wheel_lines
			call wheel#teapot#prompt ('')
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

" Add & delete

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
	call insert(ring.leaves, leaf, next)
	let ring.current = next
	call wheel#book#limit ()
	" -- clear mandala
	if clear_mandala == 'clear'
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
		echomsg 'wheel leaf delete : empty leaf ring (should not happen)'
		return v:false
	endif
	" -- do not delete element from one element ring
	if length == 1
		echomsg 'wheel leaf delete :' leaves[0].filename 'is the last layer in ring'
		return v:false
	endif
	" -- delete
	let current = ring.current
	call remove(ring.leaves, current)
	let length -= 1
	let ring.current = wheel#gear#circular_minus (current, length)
	call wheel#book#syncdown ()
	return v:true
endfun

" Forward & backward

fun! wheel#book#forward ()
	" Go forward in layer ring
	if wheel#mandala#is_empty()
		echomsg 'wheel leaf forward : deleting empty leaf'
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
	let ring.current = wheel#gear#circular_plus (current, length)
	call wheel#book#syncdown ()
endfun

fun! wheel#book#backward ()
	" Go backward in layer ring
	if wheel#mandala#is_empty()
		echomsg 'wheel leaf backward : deleting empty leaf'
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
	let ring.current = wheel#gear#circular_minus (current, length)
	call wheel#book#syncdown ()
endfun

" Switch

fun! wheel#book#switch (...)
	" Switch to layer with completion
	if wheel#mandala#is_empty()
		echomsg 'wheel leaf switch : deleting empty leaf'
		call wheel#book#delete ()
	endif
	call wheel#book#syncup ()
	let ring = b:wheel_ring
	let length = len(ring.leaves)
	if length == 0
		echomsg 'wheel layer switch : empty layer ring'
		return v:false
	endif
	let prompt = 'Switch to layer : '
	let complete = 'customlist,wheel#complete#leaf'
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
	endif
	let name = wheel#mandala#pseudo (name)
	let filenames = wheel#book#ring ('filename')
	let ring = b:wheel_ring
	let current = index(filenames, name)
	if current < 0
		echomsg 'wheel book switch : mandala leaf' name ' not found in ring'
		return v:false
	endif
	let ring.current = current
	call wheel#book#syncdown ()
endfun
