" vim: set ft=vim fdm=indent iskeyword&:

" Initialization of variables
"
" Enter the void, and ride the wheel

" ---- script constants

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

" ---- helpers

fun! wheel#void#template(init)
	" Generate template to add to g:wheel lists
	" Name = name in argument
	" Optional arguments : keys initialized as empty list
	let template = a:init
	let template.glossary = []
	let template.current = -1
	return template
endfun

" ---- initialize individual variables

" -- persistent variables

fun! wheel#void#wheel ()
	" Initialize wheel
	if ! exists('g:wheel')
		let g:wheel = {}
	endif
	if ! has_key(g:wheel, 'toruses')
		let g:wheel.toruses = []
	endif
	if ! has_key(g:wheel, 'glossary')
		let g:wheel.glossary = []
	endif
	if ! has_key(g:wheel, 'current')
		let g:wheel.current = -1
	endif
	if ! has_key(g:wheel, 'timestamp')
		let g:wheel.timestamp = -1
	endif
endfun

fun! wheel#void#helix ()
	" Initialize helix : index of locations
	if ! exists('g:wheel_helix')
		let g:wheel_helix = {}
	endif
	if ! has_key(g:wheel_helix, 'table')
		let g:wheel_helix.table = []
	endif
	if ! has_key(g:wheel_helix, 'timestamp')
		let g:wheel_helix.timestamp = -1
	endif
endfun

fun! wheel#void#grid ()
	" Initialize grid : index of circles
	if ! exists('g:wheel_grid')
		let g:wheel_grid = {}
	endif
	if ! has_key(g:wheel_grid, 'table')
		let g:wheel_grid.table = []
	endif
	if ! has_key(g:wheel_grid, 'timestamp')
		let g:wheel_grid.timestamp = -1
	endif
endfun

fun! wheel#void#files ()
	" Initialize index of files
	if ! exists('g:wheel_files')
		let g:wheel_files = {}
	endif
	if ! has_key(g:wheel_files, 'table')
		let g:wheel_files.table = []
	endif
	if ! has_key(g:wheel_files, 'timestamp')
		let g:wheel_files.timestamp = -1
	endif
endfun

fun! wheel#void#history ()
	" Initialize history
	if ! exists('g:wheel_history')
		let g:wheel_history = {}
	endif
	if ! has_key(g:wheel_history, 'line')
		" naturally sorted time line
		let g:wheel_history.line = []
	endif
	if ! has_key(g:wheel_history, 'circuit')
		" rolled time loop
		let g:wheel_history.circuit = []
	endif
	if ! has_key(g:wheel_history, 'alternate')
		let g:wheel_history.alternate = {}
	endif
endfun

fun! wheel#void#input ()
	" Initialize input history
	if ! exists('g:wheel_input')
		let g:wheel_input = []
	endif
endfun

fun! wheel#void#attic ()
	" Initialize most recently used files
	if ! exists('g:wheel_attic')
		let g:wheel_attic = []
	endif
endfun

fun! wheel#void#yank ()
	" Initialize yank history
	if ! exists('g:wheel_yank')
		let g:wheel_yank = []
	endif
endfun

fun! wheel#void#shelve ()
	" Initialize shelve : misc status variables
	if ! exists('g:wheel_shelve')
		let g:wheel_shelve = {}
	endif
	" For tabs and windows layouts
	if ! has_key(g:wheel_shelve, 'layout')
		let g:wheel_shelve.layout = {}
	endif
	" Backup some vars if needed
	if ! has_key(g:wheel_shelve, 'backup')
		let g:wheel_shelve.backup = {}
	endif
endfun

" -- config

fun! wheel#void#config ()
	" Initialize config
	if ! exists('g:wheel_config')
		let g:wheel_config = {}
	endif
	if ! has_key(g:wheel_config, 'autowrite')
		let g:wheel_config.autowrite = 0
	endif
	if ! has_key(g:wheel_config, 'autoread')
		let g:wheel_config.autoread = 0
	endif
	if ! has_key(g:wheel_config, 'autowrite_session')
		let g:wheel_config.autowrite_session = 0
	endif
	if ! has_key(g:wheel_config, 'autoread_session')
		let g:wheel_config.autoread_session = 0
	endif
	if ! has_key(g:wheel_config, 'mappings')
		let g:wheel_config.mappings = 0
	endif
	if ! has_key(g:wheel_config, 'prefix')
		let g:wheel_config.prefix = '<M-w>'
	endif
	if ! has_key(g:wheel_config, 'backups')
		let g:wheel_config.backups = 3
	endif
	if ! has_key(g:wheel_config, 'cd_project')
		let g:wheel_config.cd_project = 1
	endif
	if ! has_key(g:wheel_config, 'project_markers')
		let g:wheel_config.project_markers = '.git'
	endif
	if ! has_key(g:wheel_config, 'locate_db')
		let g:wheel_config.locate_db = ''
	endif
	if ! has_key(g:wheel_config, 'grep')
		" defaults to internal vimgrep,
		" in case external grep is not available
		let g:wheel_config.grep = 'vimgrep'
	endif
	" ---- maxim
	if ! has_key(g:wheel_config, 'maxim')
		let g:wheel_config.maxim = {}
	endif
	if ! has_key(g:wheel_config.maxim, 'history')
		let g:wheel_config.maxim.history = 50
	endif
	if ! has_key(g:wheel_config.maxim, 'input')
		let g:wheel_config.maxim.input = 50
	endif
	if ! has_key(g:wheel_config.maxim, 'yanks')
		let g:wheel_config.maxim.yanks = 50
	endif
	if ! has_key(g:wheel_config.maxim, 'yank_size')
		let g:wheel_config.maxim.yank_size = 500
	endif
	if ! has_key(g:wheel_config.maxim, 'mru')
		let g:wheel_config.maxim.mru = 50
	endif
	if ! has_key(g:wheel_config.maxim, 'layers')
		let g:wheel_config.maxim.layers = 5
	endif
	" ---- display
	if ! has_key(g:wheel_config, 'display')
		let g:wheel_config.display = {}
	endif
	if ! has_key(g:wheel_config.display, 'message')
		let g:wheel_config.display.message = 'one-line'
	endif
	if ! has_key(g:wheel_config.display, 'prompt')
		let g:wheel_config.display.prompt = wheel#crystal#fetch ('mandala/prompt')
	endif
	if ! has_key(g:wheel_config.display, 'selection')
		let g:wheel_config.display.selection = wheel#crystal#fetch ('selection/mark')
	endif
	" -- display sign
	if ! has_key(g:wheel_config.display, 'sign')
		let g:wheel_config.display.sign = {}
	endif
	if ! has_key(g:wheel_config.display.sign, 'switch')
		let g:wheel_config.display.sign.switch = 1
	endif
	if ! has_key(g:wheel_config.display.sign, 'settings')
		let settings = deepcopy(wheel#crystal#fetch ('sign/settings'))
		let g:wheel_config.display.sign.settings = settings
	endif
	" ---- debug
	if ! has_key(g:wheel_config, 'debug')
		let g:wheel_config.debug = 0
	endif
endfun

" -- non persistent variables

fun! wheel#void#mandalas ()
	" Initialize mandala buffers list
	if ! exists('g:wheel_mandalas')
		let g:wheel_mandalas = {}
	endif
	if ! has_key(g:wheel_mandalas, 'ring')
		let g:wheel_mandalas.ring = []
	endif
	if ! has_key(g:wheel_mandalas, 'current')
		let g:wheel_mandalas.current = -1
	endif
	if ! has_key(g:wheel_mandalas, 'iden')
		let g:wheel_mandalas.iden = []
	endif
	if ! has_key(g:wheel_mandalas, 'names')
		let g:wheel_mandalas.names = []
	endif
endfun

fun! wheel#void#autogroup ()
	" Define empty wheel-mandala auto command group
	execute 'augroup' s:mandala_autocmds_group
		autocmd!
	augroup END
endfun

fun! wheel#void#signs ()
	" Initialize signs list
	if ! exists('g:wheel_signs')
		let g:wheel_signs = {}
	endif
	if ! has_key(g:wheel_signs, 'iden')
		let g:wheel_signs.iden = []
	endif
	if ! has_key(g:wheel_signs, 'table')
		let g:wheel_signs.table = []
	endif
endfun

fun! wheel#void#wave ()
	" Initialize jobs dictionary
	" for neovim
	if has('nvim') && ! exists('g:wheel_wave')
		let g:wheel_wave = []
	endif
	" same thing for vim
	if ! has('nvim') && ! exists('g:wheel_ripple')
		let g:wheel_ripple = []
	endif
endfun

" ---- initialize all variables & augroup

fun! wheel#void#foundation ()
	" Initialize wheel
	" -- persistent wheel variables
	call wheel#void#wheel ()
	call wheel#void#helix ()
	call wheel#void#grid ()
	call wheel#void#files ()
	call wheel#void#history ()
	call wheel#void#input ()
	call wheel#void#attic ()
	call wheel#void#yank ()
	call wheel#void#shelve ()
	" -- config
	call wheel#void#config ()
	" -- non persistent wheel variables
	call wheel#void#mandalas ()
	call wheel#void#autogroup ()
	call wheel#void#signs ()
	call wheel#void#wave ()
endfun

" ---- wipe mandala buffers

fun! wheel#void#wipe_mandalas ()
	" Wipe mandalas buffers
	let buflist = getbufinfo()
	let mandalas = g:wheel_mandalas.ring
	for buffer in buflist
		let bufnum = buffer.bufnr
		if wheel#chain#is_inside(bufnum, mandalas)
			execute 'silent bwipe!' bufnum
		endif
	endfor
endfun

" ---- unlet variables

fun! wheel#void#clean ()
	" Clean variables before writing wheel to file
	" -- wheel shelve
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
	let g:wheel_shelve.layout.tab = 'none'
	let g:wheel_shelve.layout.tabnames = []
endfun

fun! wheel#void#lighten ()
	" Unlet wheel variables
	" No need to save them in viminfo or shada file
	" since you can save them in g:wheel_config.file
	let varlist = [
				\ 'g:wheel',
				\ 'g:wheel_helix',
				\ 'g:wheel_grid',
				\ 'g:wheel_files',
				\ 'g:wheel_history',
				\ 'g:wheel_input',
				\ 'g:wheel_attic',
				\ 'g:wheel_wave',
				\ 'g:wheel_ripple',
				\ 'g:wheel_yank',
				\ 'g:wheel_mandalas',
				\ 'g:wheel_shelve',
				\ 'g:wheel_config',
				\]
	call wheel#gear#unlet (varlist)
endfun

" ---- init & exit

fun! wheel#void#init ()
	" Main init function
	if argc() == 0 && has('nvim')
		echomsg 'wheel hello !'
	endif
	" -- read wheel
	if g:wheel_config.autoread > 0
		call wheel#disc#read_all ()
	endif
	" -- read session
	if g:wheel_config.autoread_session > 0
		call wheel#disc#read_session ()
	endif
endfun

fun! wheel#void#exit ()
	" Main exit function
	if argc() == 0 && has('nvim')
		echomsg 'wheel bye !'
	endif
	" -- clean vars before writing
	call wheel#void#clean ()
	" -- save session
	if g:wheel_config.autowrite_session > 0
		call wheel#disc#write_session ()
	endif
	" -- save wheel, and unlet
	if g:wheel_config.autowrite > 0
		call wheel#disc#write_all()
	endif
	call wheel#void#wipe_mandalas ()
	call wheel#void#lighten ()
endfun

" ---- fresh empty wheel, for testing

fun! wheel#void#fresh_wheel ()
	" Fresh empty wheel variables
	let prompt = 'Write old wheel to file before emptying wheel ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_all ()
	endif
	let varlist = [
				\ 'g:wheel',
				\ 'g:wheel_helix',
				\ 'g:wheel_grid',
				\ 'g:wheel_files',
				\ 'g:wheel_history',
				\ 'g:wheel_input',
				\ 'g:wheel_attic',
				\ 'g:wheel_wave',
				\ 'g:wheel_ripple',
				\ 'g:wheel_yank',
				\ 'g:wheel_mandalas',
				\ 'g:wheel_signs',
				\ 'g:wheel_shelve',
				\]
	call wheel#gear#unlet (varlist)
	call wheel#void#foundation ()
endfun
