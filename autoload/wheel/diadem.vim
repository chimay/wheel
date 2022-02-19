" vim: set ft=vim fdm=indent iskeyword&:

" Pearl
"
" Internal Constants for commands in mandalas

" ---- commands

if ! exists('s:command_meta_actions')
	let s:command_meta_actions = [
				\ [ 'info'              , 'wheel#status#dashboard'            ] ,
				\ [ 'jump'              , 'wheel#vortex#jump'                 ] ,
				\ [ 'follow'            , 'wheel#projection#follow'           ] ,
				\ [ 'next-location'     , "wheel#vortex#next('location')"     ] ,
				\ [ 'previous-location' , "wheel#vortex#previous('location')" ] ,
				\ [ 'next-circle'       , "wheel#vortex#next('circle')"       ] ,
				\ [ 'previous-circle'   , "wheel#vortex#previous('circle')"   ] ,
				\ [ 'next-torus'        , "wheel#vortex#next('torus')"        ] ,
				\ [ 'previous-torus'    , "wheel#vortex#previous('torus')"    ] ,
				\ [ 'newer'             , 'wheel#waterclock#newer_anywhere'   ] ,
				\ [ 'older'             , 'wheel#waterclock#older_anywhere'   ] ,
				\ [ 'newer-in-circle'   , "wheel#waterclock#newer('circle')"  ] ,
				\ [ 'older-in-circle'   , "wheel#waterclock#older('circle')"  ] ,
				\ [ 'newer-in-torus'    , "wheel#waterclock#newer('torus')"   ] ,
				\ [ 'older-in-torus'    , "wheel#waterclock#older('torus')"   ] ,
				\ [ 'read'              , 'wheel#disc#read_wheel'             ] ,
				\ [ 'write'             , 'wheel#disc#write_wheel'            ] ,
				\ [ 'read-session'      , 'wheel#disc#read_session'           ] ,
				\ [ 'write-session'     , 'wheel#disc#write_session'          ] ,
				\ [ 'mkdir'             , 'wheel#disc#mkdir'                  ] ,
				\ [ 'rename'            , 'wheel#disc#rename'                 ] ,
				\ [ 'copy'              , 'wheel#disc#copy'                   ] ,
				\ [ 'delete'            , 'wheel#disc#delete'                 ] ,
				\ [ 'autogroup'         , 'wheel#group#menu'                  ] ,
				\ [ 'batch'             , 'wheel#vector#argdo'                ] ,
				\ [ 'tree-script'       , 'wheel#disc#tree_script'            ] ,
				\ [ 'symlink-tree'      , 'wheel#disc#symlink_tree'           ] ,
				\ [ 'copied-tree'       , 'wheel#disc#copied_tree'            ] ,
				\ [ 'prompt'            , 'wheel#void#nope'                   ] ,
				\ [ 'dedibuf'           , 'wheel#void#nope'                   ] ,
				\ ]
	lockvar! s:command_meta_actions
endif

if ! exists('s:command_meta_prompt_actions')
	let s:command_meta_prompt_actions = [
				\ [ 'location'             , "wheel#vortex#switch('location')"           ] ,
				\ [ 'circle'               , "wheel#vortex#switch('circle')"             ] ,
				\ [ 'torus'                , "wheel#vortex#switch('torus')"              ] ,
				\ [ 'multi-switch'         , 'wheel#vortex#multi_switch'                 ] ,
				\ [ 'index-locations'      , 'wheel#vortex#helix'                        ] ,
				\ [ 'index-circles'        , 'wheel#vortex#grid'                         ] ,
				\ [ 'history'              , 'wheel#waterclock#history'                  ] ,
				\ [ 'frecency'             , 'wheel#waterclock#frecency'                 ] ,
				\ [ 'buffer'               , 'wheel#sailing#buffer'                      ] ,
				\ [ 'tabwin'               , 'wheel#sailing#tabwin'                      ] ,
				\ [ 'marker'               , 'wheel#sailing#marker'                      ] ,
				\ [ 'jump'                 , 'wheel#sailing#jump'                        ] ,
				\ [ 'change'               , 'wheel#sailing#change'                      ] ,
				\ [ 'tag'                  , 'wheel#sailing#tag'                         ] ,
				\ [ 'add-here'             , 'wheel#tree#add_here'                       ] ,
				\ [ 'add-circle'           , 'wheel#tree#add_circle'                     ] ,
				\ [ 'add-torus'            , 'wheel#tree#add_torus'                      ] ,
				\ [ 'add-file'             , 'wheel#tree#add_file'                       ] ,
				\ [ 'add-glob'             , 'wheel#tree#add_glob'                       ] ,
				\ [ 'rename-location'      , "wheel#tree#rename('location')"             ] ,
				\ [ 'rename-file'          , 'wheel#tree#rename_file'                    ] ,
				\ [ 'rename-circle'        , "wheel#tree#rename('circle')"               ] ,
				\ [ 'rename-torus'         , "wheel#tree#rename('torus')"                ] ,
				\ [ 'delete-location'      , "wheel#tree#delete('location')"             ] ,
				\ [ 'delete-circle'        , "wheel#tree#delete('circle')"               ] ,
				\ [ 'delete-torus'         , "wheel#tree#delete('torus')"                ] ,
				\ [ 'copy-location'        , "wheel#tree#copy('location')"               ] ,
				\ [ 'copy-circle'          , "wheel#tree#copy('circle')"                 ] ,
				\ [ 'copy-torus'           , "wheel#tree#copy('torus')"                  ] ,
				\ [ 'move-location'        , "wheel#tree#move('location')"               ] ,
				\ [ 'move-circle'          , "wheel#tree#move('circle')"                 ] ,
				\ [ 'move-torus'           , "wheel#tree#move('torus')"                  ] ,
				\ [ 'find'                 , 'wheel#sailing#find'                        ] ,
				\ [ 'mru'                  , 'wheel#sailing#mru'                         ] ,
				\ [ 'occur'                , 'wheel#sailing#occur'                       ] ,
				\ [ 'yank-linewise-after'  , 'wheel#codex#yank_plain'                    ] ,
				\ [ 'yank-charwise-after'  , "wheel#codex#yank_plain('charwise-after')"  ] ,
				\ [ 'yank-linewise-before' , "wheel#codex#yank_plain('linewise-before')" ] ,
				\ [ 'yank-charwise-before' , "wheel#codex#yank_plain('charwise-before')" ] ,
				\ [ 'default-register'     , 'wheel#codex#switch_default_register'       ] ,
				\ ]
	lockvar! s:command_meta_prompt_actions
endif

if ! exists('s:command_meta_dedibuf_actions')
	let s:command_meta_dedibuf_actions = [
				\ [ 'menu-main'          , 'wheel#helm#main'                       ] ,
				\ [ 'menu-meta'          , 'wheel#helm#meta'                       ] ,
				\ [ 'location'           , "wheel#whirl#switch('location')"        ] ,
				\ [ 'circle'             , "wheel#whirl#switch('circle')"          ] ,
				\ [ 'torus'              , "wheel#whirl#switch('torus')"           ] ,
				\ [ 'index-locations'    , 'wheel#whirl#helix'                     ] ,
				\ [ 'index-circles'      , 'wheel#whirl#grid'                      ] ,
				\ [ 'history'            , 'wheel#whirl#history'                   ] ,
				\ [ 'frecency'           , 'wheel#whirl#frecency'                  ] ,
				\ [ 'buffer'             , 'wheel#frigate#buffer'                  ] ,
				\ [ 'buffer-all'         , "wheel#frigate#buffer('all')"           ] ,
				\ [ 'tabwin'             , 'wheel#frigate#tabwin'                  ] ,
				\ [ 'tabwin-tree'        , 'wheel#frigate#tabwin_tree'             ] ,
				\ [ 'marker'             , 'wheel#frigate#marker'                  ] ,
				\ [ 'jump'               , 'wheel#frigate#jump'                    ] ,
				\ [ 'change'             , 'wheel#frigate#change'                  ] ,
				\ [ 'tag'                , 'wheel#frigate#tag'                     ] ,
				\ [ 'reorder-locations'  , "wheel#yggdrasil#reorder('location')"   ] ,
				\ [ 'reorder-circles'    , "wheel#yggdrasil#reorder('circle')"     ] ,
				\ [ 'reorder-toruses'    , "wheel#yggdrasil#reorder('torus')"      ] ,
				\ [ 'rename-locations'   , "wheel#yggdrasil#rename('location')"    ] ,
				\ [ 'rename-circles'     , "wheel#yggdrasil#rename('circle')"      ] ,
				\ [ 'rename-toruses'     , "wheel#yggdrasil#rename('torus')"       ] ,
				\ [ 'delete-locations'   , "wheel#yggdrasil#delete('location')"    ] ,
				\ [ 'delete-circles'     , "wheel#yggdrasil#delete('circle')"      ] ,
				\ [ 'delete-toruses'     , "wheel#yggdrasil#delete('torus')"       ] ,
				\ [ 'copy-move-location' , "wheel#yggdrasil#copy_move('location')" ] ,
				\ [ 'copy-move-circle'   , "wheel#yggdrasil#copy_move('circle')"   ] ,
				\ [ 'copy-move-torus'    , "wheel#yggdrasil#copy_move('torus')"    ] ,
				\ [ 'reorganize'         , 'wheel#yggdrasil#reorganize'            ] ,
				\ [ 'reorganize-tabwin'  , 'wheel#yggdrasil#reorg_tabwin'          ] ,
				\ [ 'grep-edit'          , 'wheel#shadow#grep_edit'                ] ,
				\ [ 'narrow-file'        , 'wheel#shadow#narrow_file'              ] ,
				\ [ 'narrow-circle'      , 'wheel#shadow#narrow_circle'            ] ,
				\ [ 'find'               , 'wheel#frigate#find'                    ] ,
				\ [ 'async-find'         , 'wheel#frigate#async_find'              ] ,
				\ [ 'mru'                , 'wheel#frigate#mru'                     ] ,
				\ [ 'locate'             , 'wheel#frigate#locate'                  ] ,
				\ [ 'occur'              , 'wheel#frigate#occur'                   ] ,
				\ [ 'grep'               , 'wheel#frigate#grep'                    ] ,
				\ [ 'outline'            , 'wheel#frigate#outline'                 ] ,
				\ [ 'yank-plain'         , "wheel#clipper#yank('plain')"           ] ,
				\ [ 'yank-list'          , "wheel#clipper#yank('list')"            ] ,
				\ [ 'undo-list'          , 'wheel#triangle#undolist'               ] ,
				\ [ 'command'            , 'wheel#mandala#command'                 ] ,
				\ [ 'async'              , 'wheel#mandala#async'                   ] ,
				\ ]
	lockvar! s:command_meta_dedibuf_actions
endif

if ! exists('s:command_meta_subcommands_file')
	let s:command_meta_subcommands_file = [
				\ 'mkdir', 'rename', 'copy', 'delete',
				\ ]
	lockvar! s:command_meta_subcommands_file
endif

" ---- public interface

fun! wheel#diadem#fetch (varname, conversion = 'no-conversion')
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
