" vim: set ft=vim fdm=indent iskeyword&:

" Quartz
"
" Internal Constants for commands in mandalas

" ---- commands

if ! exists('s:command_meta_actions')
	let s:command_meta_actions = [
				\ [ 'info', 'wheel#status#dashboard' ],
				\ [ 'jump', 'wheel#vortex#jump' ],
				\ [ 'follow', 'wheel#projection#follow' ],
				\ [ 'read', 'wheel#disc#read_wheel' ],
				\ [ 'write', 'wheel#disc#write_wheel' ],
				\ [ 'read-session', 'wheel#disc#read_session' ],
				\ [ 'write-session', 'wheel#disc#write_session' ],
				\ [ 'mkdir', 'wheel#disc#mkdir' ],
				\ [ 'rename', 'wheel#disc#rename' ],
				\ [ 'copy', 'wheel#disc#copy' ],
				\ [ 'delete', 'wheel#disc#delete' ],
				\ [ 'autogroup', 'wheel#group#menu' ],
				\ [ 'batch', 'wheel#vector#argdo' ],
				\ [ 'tree-script', 'wheel#disc#tree_script' ],
				\ [ 'symlink-tree', 'wheel#disc#symlink_tree' ],
				\ [ 'copied-tree', 'wheel#disc#copied_tree' ],
				\ [ 'prompt', 'winnr' ],
				\ [ 'dedibuf', 'winnr' ],
				\ ]
	lockvar! s:command_meta_actions
endif

if ! exists('s:command_meta_prompt_actions')
	let s:command_meta_prompt_actions = [
				\ [ 'switch-location', "wheel#vortex#switch('location')" ],
				\ [ 'switch-circle', "wheel#vortex#switch('circle')" ],
				\ [ 'switch-torus', "wheel#vortex#switch('torus')" ],
				\ [ 'multi-switch', 'wheel#vortex#multi_switch()' ],
				\ [ 'index-locations', 'wheel#vortex#helix()' ],
				\ [ 'index-circles', 'wheel#vortex#grid()' ],
				\ [ 'history', 'wheel#vortex#history()' ],
				\ [ 'frecency', 'wheel#vortex#frecency()' ],
				\ ]
	lockvar! s:command_meta_prompt_actions
endif

if ! exists('s:command_meta_dedibuf_actions')
	let s:command_meta_dedibuf_actions = [
				\ [ 'switch-location', "wheel#whirl#switch('location')" ],
				\ [ 'switch-circle', "wheel#whirl#switch('circle')" ],
				\ [ 'switch-torus', "wheel#whirl#switch('torus')" ],
				\ [ 'index-locations', 'wheel#whirl#helix()' ],
				\ [ 'index-circles', 'wheel#whirl#grid()' ],
				\ [ 'history', 'wheel#whirl#history()' ],
				\ [ 'frecency', 'wheel#whirl#frecency()' ],
				\ ]
	lockvar! s:command_meta_dedibuf_actions
endif

if ! exists('s:command_meta_subcommands_file')
	let s:command_meta_subcommands_file = [
				\ 'mkdir', 'rename', 'copy', 'delete',
				\]
	lockvar! s:command_meta_subcommands_file
endif

" ---- public interface

fun! wheel#pearl#fetch (varname, conversion = 'no-conversion')
	" Return script variable called varname
	" The leading s: can be omitted
	" Optional argument :
	"   - no-conversion : simply returns the asked variable, dont convert anything
	"   - dict : if varname points to an items list, convert it to a dictionary
	let varname = a:varname
	let conversion = a:conversion
	" ---- variable name
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	" ---- raw or conversion
	if conversion ==# 'dict' && wheel#matrix#is_nested_list ({varname})
		return wheel#matrix#items2dict ({varname})
	else
		return {varname}
	endif
endfun
