" vim: set ft=vim fdm=indent iskeyword&:

" Void
"
" Initialization of variables
"
" Enter the void, and ride the wheel

" ---- script constants

if exists('s:mandala_autocmds_group')
	unlockvar s:mandala_autocmds_group
endif
let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
lockvar s:mandala_autocmds_group

" ---- no-op function

fun! wheel#void#nope (...)
	" Does nothing, returns its argument list
	" Application : for meta-command subcommands thas need a third argument
	return a:000
endfun

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
	" ---- naturally sorted time line
	if ! has_key(g:wheel_history, 'line')
		let g:wheel_history.line = []
	endif
	" ---- rolled time loop
	if ! has_key(g:wheel_history, 'circuit')
		let g:wheel_history.circuit = []
	endif
	" ---- alternate locations
	if ! has_key(g:wheel_history, 'alternate')
		let g:wheel_history.alternate = {}
	endif
	" ---- frequent + recent
	if ! has_key(g:wheel_history, 'frecency')
		let g:wheel_history.frecency = []
	endif
endfun

fun! wheel#void#input ()
	" Initialize input history
	if ! exists('g:wheel_input')
		let g:wheel_input = []
	endif
endfun

fun! wheel#void#shelve ()
	" Initialize shelve : misc status variables
	if ! exists('g:wheel_shelve')
		let g:wheel_shelve = {}
	endif
	" ---- current
	if ! has_key(g:wheel_shelve, 'current')
		let g:wheel_shelve.current = {}
	endif
	" -- wheel file
	if ! has_key(g:wheel_shelve.current, 'wheel')
		let g:wheel_shelve.current.wheel = ''
	endif
	" -- session file
	if ! has_key(g:wheel_shelve.current, 'session')
		let g:wheel_shelve.current.session = ''
	endif
	" ---- yank ring
	if ! has_key(g:wheel_shelve, 'yank')
		let g:wheel_shelve.yank = {}
	endif
	if ! has_key(g:wheel_shelve.yank, 'default_register')
		let g:wheel_shelve.yank.default_register = 'unnamed'
	endif
	" ---- tabs and windows layouts
	if ! has_key(g:wheel_shelve, 'layout')
		let g:wheel_shelve.layout = {}
	endif
	" ---- backup some vars if needed
	if ! has_key(g:wheel_shelve, 'backup')
		let g:wheel_shelve.backup = {}
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
		let g:wheel_yank = {}
	endif
	if ! has_key(g:wheel_yank, 'unnamed')
		let g:wheel_yank.unnamed = []
	endif
	if ! has_key(g:wheel_yank, 'clipboard')
		let g:wheel_yank.clipboard = []
	endif
	if ! has_key(g:wheel_yank, 'primary')
		let g:wheel_yank.primary = []
	endif
	if ! has_key(g:wheel_yank, 'small')
		let g:wheel_yank.small = []
	endif
	if ! has_key(g:wheel_yank, 'inserted')
		let g:wheel_yank.inserted = []
	endif
	if ! has_key(g:wheel_yank, 'search')
		let g:wheel_yank.search = []
	endif
	if ! has_key(g:wheel_yank, 'command')
		let g:wheel_yank.command = []
	endif
	if ! has_key(g:wheel_yank, 'expression')
		let g:wheel_yank.expression = []
	endif
	if ! has_key(g:wheel_yank, 'file')
		let g:wheel_yank.file = []
	endif
	if ! has_key(g:wheel_yank, 'alternate')
		let g:wheel_yank.alternate = []
	endif
endfun

" -- config

fun! wheel#void#config ()
	" Initialize config
	if ! exists('g:wheel_config')
		let g:wheel_config = {}
	endif
	if ! has_key(g:wheel_config, 'mappings')
		let g:wheel_config.mappings = 0
	endif
	if ! has_key(g:wheel_config, 'prefix')
		let g:wheel_config.prefix = '<M-w>'
	endif
	if ! has_key(g:wheel_config, 'locate_db')
		let g:wheel_config.locate_db = ''
	endif
	if ! has_key(g:wheel_config, 'grep')
		" defaults to internal vimgrep,
		" in case external grep is not available
		let g:wheel_config.grep = 'vimgrep'
	endif
	" ---- project
	if ! has_key(g:wheel_config, 'project')
		let g:wheel_config.project = {}
	endif
	if ! has_key(g:wheel_config.project, 'markers')
		let g:wheel_config.project.markers = '.git'
	endif
	if ! has_key(g:wheel_config.project, 'auto_chdir')
		let g:wheel_config.project.auto_chdir = 0
	endif
	" ---- storage
	if ! has_key(g:wheel_config, 'storage')
		let g:wheel_config.storage = {}
	endif
	" -- storage wheel
	if ! has_key(g:wheel_config.storage, 'wheel')
		let g:wheel_config.storage.wheel = {}
	endif
	if ! has_key(g:wheel_config.storage.wheel, 'folder')
		if has('nvim')
			let g:wheel_config.storage.wheel.folder = '~/.local/share/nvim/wheel'
		else
			let g:wheel_config.storage.wheel.folder = '~/.vim/wheel'
		endif
	endif
	if ! has_key(g:wheel_config.storage.wheel, 'name')
		let g:wheel_config.storage.wheel.name = 'wheel.vim'
	endif
	if ! has_key(g:wheel_config.storage.wheel, 'autowrite')
		let g:wheel_config.storage.wheel.autowrite = 0
	endif
	if ! has_key(g:wheel_config.storage.wheel, 'autoread')
		let g:wheel_config.storage.wheel.autoread = 0
	endif
	" -- storage session
	if ! has_key(g:wheel_config.storage, 'session')
		let g:wheel_config.storage.session = {}
	endif
	if ! has_key(g:wheel_config.storage.session, 'folder')
		if has('nvim')
			let g:wheel_config.storage.session.folder = '~/.local/share/nvim/wheel/session'
		else
			let g:wheel_config.storage.session.folder = '~/.vim/wheel/session'
		endif
	endif
	if ! has_key(g:wheel_config.storage.session, 'name')
		let g:wheel_config.storage.session.name = 'session.vim'
	endif
	if ! has_key(g:wheel_config.storage.session, 'autowrite')
		let g:wheel_config.storage.session.autowrite = 0
	endif
	if ! has_key(g:wheel_config.storage.session, 'autoread')
		let g:wheel_config.storage.session.autoread = 0
	endif
	" -- backups
	if ! has_key(g:wheel_config.storage, 'backups')
		let g:wheel_config.storage.backups = 3
	endif
	" ---- maxim
	if ! has_key(g:wheel_config, 'maxim')
		let g:wheel_config.maxim = {}
	endif
	if ! has_key(g:wheel_config.maxim, 'history')
		let g:wheel_config.maxim.history = 500
	endif
	if ! has_key(g:wheel_config.maxim, 'input')
		let g:wheel_config.maxim.input = 500
	endif
	if ! has_key(g:wheel_config.maxim, 'mru')
		let g:wheel_config.maxim.mru = 500
	endif
	if ! has_key(g:wheel_config.maxim, 'unnamed_yanks')
		let g:wheel_config.maxim.unnamed_yanks = 500
	endif
	if ! has_key(g:wheel_config.maxim, 'other_yanks')
		let g:wheel_config.maxim.other_yanks = 50
	endif
	if ! has_key(g:wheel_config.maxim, 'yank_lines')
		let g:wheel_config.maxim.yank_lines = 30
	endif
	if ! has_key(g:wheel_config.maxim, 'yank_size')
		let g:wheel_config.maxim.yank_size = 3000
	endif
	if ! has_key(g:wheel_config.maxim, 'layers')
		let g:wheel_config.maxim.layers = 5
	endif
	if ! has_key(g:wheel_config.maxim, 'tabs')
		let g:wheel_config.maxim.tabs = 15
	endif
	if ! has_key(g:wheel_config.maxim, 'horizontal')
		let g:wheel_config.maxim.horizontal = 3
	endif
	if ! has_key(g:wheel_config.maxim, 'vertical')
		let g:wheel_config.maxim.vertical = 4
	endif
	" ---- frecency
	if ! has_key(g:wheel_config, 'frecency')
		let g:wheel_config.frecency = {}
	endif
	if ! has_key(g:wheel_config.frecency, 'reward')
		let g:wheel_config.frecency.reward = 50
	endif
	if ! has_key(g:wheel_config.frecency, 'penalty')
		let g:wheel_config.frecency.penalty = 1
	endif
	" -- completion
	if ! has_key(g:wheel_config, 'completion')
		let g:wheel_config.completion = {}
	endif
	if ! has_key(g:wheel_config.completion, 'vocalize')
		let g:wheel_config.completion.vocalize = 0
	endif
	if ! has_key(g:wheel_config.completion, 'wordize')
		let g:wheel_config.completion.wordize = 0
	endif
	if ! has_key(g:wheel_config.completion, 'fuzzy')
		let g:wheel_config.completion.fuzzy = 0
	endif
	if ! has_key(g:wheel_config.completion, 'scores')
		let g:wheel_config.completion.scores = 0
	endif
	" ---- display
	if ! has_key(g:wheel_config, 'display')
		let g:wheel_config.display = {}
	endif
	if ! has_key(g:wheel_config.display, 'statusline')
		let g:wheel_config.display.statusline = 1
	endif
	if ! has_key(g:wheel_config.display, 'dedibuf_msg')
		let g:wheel_config.display.dedibuf_msg = 'one-line'
	endif
	if ! has_key(g:wheel_config.display, 'prompt')
		let g:wheel_config.display.prompt = wheel#crystal#fetch ('mandala/prompt')
	endif
	if ! has_key(g:wheel_config.display, 'prompt_writable')
		let g:wheel_config.display.prompt_writable = wheel#crystal#fetch ('mandala/prompt/writable')
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
	if ! has_key(g:wheel_config.display.sign, 'native_settings')
		let native_settings = deepcopy(wheel#crystal#fetch ('sign/settings/native'))
		let g:wheel_config.display.sign.native_settings = native_settings
	endif
	" ---- debug
	if ! has_key(g:wheel_config, 'debug')
		let g:wheel_config.debug = 0
	endif
endfun

" -- non persistent variables

fun! wheel#void#mandalas ()
	" Initialize mandala buffers list
	if ! exists('g:wheel_bufring')
		let g:wheel_bufring = {}
	endif
	if ! has_key(g:wheel_bufring, 'mandalas')
		let g:wheel_bufring.mandalas = []
	endif
	if ! has_key(g:wheel_bufring, 'current')
		let g:wheel_bufring.current = -1
	endif
	if ! has_key(g:wheel_bufring, 'iden')
		let g:wheel_bufring.iden = []
	endif
	if ! has_key(g:wheel_bufring, 'names')
		let g:wheel_bufring.names = []
	endif
	if ! has_key(g:wheel_bufring, 'types')
		let g:wheel_bufring.types = []
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
	" ---- locations signs
	if ! has_key(g:wheel_signs, 'iden')
		let g:wheel_signs.iden = []
	endif
	if ! has_key(g:wheel_signs, 'table')
		let g:wheel_signs.table = []
	endif
	" ---- native navigation signs
	if ! has_key(g:wheel_signs, 'native_iden')
		let g:wheel_signs.native_iden = []
	endif
	if ! has_key(g:wheel_signs, 'native_table')
		let g:wheel_signs.native_table = []
	endif
endfun

fun! wheel#void#wave ()
	" Initialize jobs dictionary
	" ---- for neovim
	if has('nvim') && ! exists('g:wheel_wave')
		let g:wheel_wave = []
	endif
	" ---- same thing for vim
	if ! has('nvim') && ! exists('g:wheel_ripple')
		let g:wheel_ripple = []
	endif
endfun

fun! wheel#void#volatile ()
	" Store non persistent state
	if ! exists('g:wheel_volatile')
		let g:wheel_volatile = {}
	endif
	" ---- Remember number of file args at startup
	" ---- before :argadd, :argdel or similar command
	if ! has_key(g:wheel_volatile, 'argc')
		let g:wheel_volatile.argc = argc()
	endif
	if ! has_key(g:wheel_volatile, 'argv')
		let g:wheel_volatile.argv = argv()
	endif
	" ---- First time read / write
	if ! has_key(g:wheel_volatile, 'first')
		let g:wheel_volatile.first = {}
		let g:wheel_volatile.first.write_wheel = v:true
		let g:wheel_volatile.first.read_wheel = v:true
		let g:wheel_volatile.first.write_session = v:true
		let g:wheel_volatile.first.read_session = v:true
	endif
endfun

" ---- initialize all variables & augroup

fun! wheel#void#foundation ()
	" Initialize wheel
	" ---- pre conversion from old keys
	call wheel#kintsugi#pre ()
	" ---- persistent wheel variables
	call wheel#void#wheel ()
	call wheel#void#helix ()
	call wheel#void#grid ()
	call wheel#void#files ()
	call wheel#void#history ()
	call wheel#void#input ()
	call wheel#void#shelve ()
	call wheel#void#attic ()
	call wheel#void#yank ()
	" ---- config
	call wheel#void#config ()
	" ---- non persistent wheel variables
	call wheel#void#mandalas ()
	call wheel#void#autogroup ()
	call wheel#void#signs ()
	call wheel#void#wave ()
	call wheel#void#volatile ()
	" ---- post conversion from old keys
	call wheel#kintsugi#post ()
endfun

" ---- wipe mandala buffers

fun! wheel#void#wipe_mandalas ()
	" Wipe mandalas buffers
	let buflist = getbufinfo()
	let mandalas = g:wheel_bufring.mandalas
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
	" ---- wheel shelve
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
	let g:wheel_shelve.layout.tab = 'none'
	let g:wheel_shelve.layout.tabnames = []
endfun

fun! wheel#void#vanish ()
	" Unlet wheel variables
	" No need to save them in viminfo or shada file
	" since you can save them in g:wheel_config.storage.wheel.name
	" ---- should not be necessary, since only
	" ---- uppercase global vars are stored in viminfo / shada
	return
	let varlist = [
				\ 'g:wheel',
				\ 'g:wheel_helix',
				\ 'g:wheel_grid',
				\ 'g:wheel_files',
				\ 'g:wheel_history',
				\ 'g:wheel_input',
				\ 'g:wheel_attic',
				\ 'g:wheel_yank',
				\ 'g:wheel_shelve',
				\ 'g:wheel_config',
				\ 'g:wheel_bufring',
				\ 'g:wheel_wave',
				\ 'g:wheel_ripple',
				\ 'g:wheel_volatile',
				\ 'g:wheel_signs',
				\ ]
	call wheel#ouroboros#unlet (varlist)
endfun

" ---- init & exit

fun! wheel#void#init ()
	" Main init function
	"if g:wheel_volatile.argc == 0 && has('nvim')
		"echomsg 'wheel hello !'
	"endif
	" ---- keep tabs & wins ?
	if g:wheel_volatile.argc == 0
		let keep_tabwins = 'dont-keep'
	else
		let keep_tabwins = 'keep'
	endif
	" ---- no message at vim enter
	let verbose = v:false
	" ---- read wheel
	if g:wheel_config.storage.wheel.autoread > 0
		call wheel#disc#read_wheel ('', keep_tabwins, verbose)
	endif
	" ---- read session
	if g:wheel_config.storage.session.autoread > 0
		call wheel#disc#read_session ('', keep_tabwins, verbose)
	endif
endfun

fun! wheel#void#exit ()
	" Main exit function
	"if g:wheel_volatile.argc == 0 && has('nvim')
		"echomsg 'wheel bye !'
	"endif
	" ---- clean vars before writing
	call wheel#void#clean ()
	" ---- no message at vim leave
	let verbose = v:false
	" ---- save session
	if g:wheel_config.storage.session.autowrite > 0
		call wheel#disc#write_session ('', verbose)
	endif
	" ---- save wheel, and unlet
	if g:wheel_config.storage.wheel.autowrite > 0
		call wheel#disc#write_wheel('', verbose)
	endif
	call wheel#void#wipe_mandalas ()
	call wheel#void#vanish ()
endfun

" ---- fresh empty wheel, for testing

fun! wheel#void#fresh_wheel ()
	" Fresh empty wheel variables
	let prompt = 'Write old wheel to file before emptying wheel ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_wheel ()
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
				\ 'g:wheel_bufring',
				\ 'g:wheel_signs',
				\ 'g:wheel_shelve',
				\ ]
	call wheel#ouroboros#unlet (varlist)
	call wheel#void#foundation ()
endfun
