" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for maps in mandalas

" ---- subprefixes

if ! exists('s:batch')
	let s:batch = '@'
	lockvar! s:batch
endif

if ! exists('s:async')
	let s:async = '&'
	lockvar! s:async
endif

if ! exists('s:layout')
	let s:layout = 'z'
	lockvar! s:layout
endif

if ! exists('s:debug')
	let s:debug = 'Z'
	lockvar! s:debug
endif

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ [ 'wheel-menu-main',                         'wheel#helm#main()'                                    ] ,
		\ [ 'wheel-menu-meta',                         'wheel#helm#meta()'                                    ] ,
		\ [ 'wheel-info',                              'wheel#status#dashboard()'                             ] ,
		\ [ 'wheel-sync-up',                           'wheel#projection#follow()'                            ] ,
		\ [ 'wheel-sync-down',                         'wheel#vortex#jump()'                                  ] ,
		\ [ 'wheel-read-wheel',                        'wheel#disc#read_wheel()'                              ] ,
		\ [ 'wheel-write-wheel',                       'wheel#disc#write_wheel()'                             ] ,
		\ [ 'wheel-read-session',                      'wheel#disc#read_session()'                            ] ,
		\ [ 'wheel-write-layout',                      'wheel#disc#write_layout()'                            ] ,
		\ [ 'wheel-write-session',                     'wheel#disc#write_session()'                           ] ,
		\ [ 'wheel-previous-location',                 "wheel#vortex#previous('location')"                    ] ,
		\ [ 'wheel-next-location',                     "wheel#vortex#next('location')"                        ] ,
		\ [ 'wheel-previous-circle',                   "wheel#vortex#previous('circle')"                      ] ,
		\ [ 'wheel-next-circle',                       "wheel#vortex#next('circle')"                          ] ,
		\ [ 'wheel-previous-torus',                    "wheel#vortex#previous('torus')"                       ] ,
		\ [ 'wheel-next-torus',                        "wheel#vortex#next('torus')"                           ] ,
		\ [ 'wheel-prompt-location',                   "wheel#vortex#switch('location')"                      ] ,
		\ [ 'wheel-prompt-circle',                     "wheel#vortex#switch('circle')"                        ] ,
		\ [ 'wheel-prompt-torus',                      "wheel#vortex#switch('torus')"                         ] ,
		\ [ 'wheel-prompt-multi-switch',               'wheel#vortex#multi_switch()'                          ] ,
		\ [ 'wheel-dedibuf-location',                  "wheel#whirl#switch('location')"                       ] ,
		\ [ 'wheel-dedibuf-circle',                    "wheel#whirl#switch('circle')"                         ] ,
		\ [ 'wheel-dedibuf-torus',                     "wheel#whirl#switch('torus')"                          ] ,
		\ [ 'wheel-prompt-index',                      'wheel#vortex#helix()'                                 ] ,
		\ [ 'wheel-prompt-index-circles',              'wheel#vortex#grid()'                                  ] ,
		\ [ 'wheel-dedibuf-index',                     'wheel#whirl#helix()'                                  ] ,
		\ [ 'wheel-dedibuf-index-circles',             'wheel#whirl#grid()'                                   ] ,
		\ [ 'wheel-dedibuf-index-tree',                'wheel#whirl#tree()'                                   ] ,
		\ [ 'wheel-history-newer',                     'wheel#pendulum#newer()'                               ] ,
		\ [ 'wheel-history-older',                     'wheel#pendulum#older()'                               ] ,
		\ [ 'wheel-history-newer-in-circle',           "wheel#pendulum#newer('circle')"                       ] ,
		\ [ 'wheel-history-older-in-circle',           "wheel#pendulum#older('circle')"                       ] ,
		\ [ 'wheel-history-newer-in-torus',            "wheel#pendulum#newer('torus')"                        ] ,
		\ [ 'wheel-history-older-in-torus',            "wheel#pendulum#older('torus')"                        ] ,
		\ [ 'wheel-prompt-history',                    'wheel#vortex#history()'                               ] ,
		\ [ 'wheel-dedibuf-history',                   'wheel#whirl#history()'                                ] ,
		\ [ 'wheel-alternate-anywhere',                "wheel#pendulum#alternate('anywhere')"                 ] ,
		\ [ 'wheel-alternate-same-torus',              "wheel#pendulum#alternate('same_torus')"               ] ,
		\ [ 'wheel-alternate-same-circle',             "wheel#pendulum#alternate('same_circle')"              ] ,
		\ [ 'wheel-alternate-other-torus',             "wheel#pendulum#alternate('other_torus')"              ] ,
		\ [ 'wheel-alternate-other-circle',            "wheel#pendulum#alternate('other_circle')"             ] ,
		\ [ 'wheel-alternate-same-torus-other-circle', "wheel#pendulum#alternate('same_torus_other_circle')"  ] ,
		\ [ 'wheel-alternate-menu',                    'wheel#pendulum#alternate_menu()'                      ] ,
		\ [ 'wheel-prompt-frecency',                   'wheel#vortex#frecency()'                              ] ,
		\ [ 'wheel-dedibuf-frecency',                  'wheel#whirl#frecency()'                               ] ,
		\ [ 'wheel-prompt-buffer',                     'wheel#sailing#buffer()'                               ] ,
		\ [ 'wheel-dedibuf-buffer',                    'wheel#frigate#buffer()'                               ] ,
		\ [ 'wheel-dedibuf-buffer-all',                "wheel#frigate#buffer('all')"                          ] ,
		\ [ 'wheel-prompt-tabwin',                     'wheel#sailing#tabwin()'                               ] ,
		\ [ 'wheel-dedibuf-tabwin',                    'wheel#frigate#tabwin()'                               ] ,
		\ [ 'wheel-dedibuf-tabwin-tree',               'wheel#frigate#tabwin_tree()'                          ] ,
		\ [ 'wheel-prompt-marker',                     'wheel#sailing#marker()'                               ] ,
		\ [ 'wheel-prompt-jump',                       'wheel#sailing#jump()'                                 ] ,
		\ [ 'wheel-prompt-change',                     'wheel#sailing#change()'                               ] ,
		\ [ 'wheel-prompt-tag',                        'wheel#sailing#tag()'                                  ] ,
		\ [ 'wheel-dedibuf-marker',                    'wheel#frigate#marker()'                               ] ,
		\ [ 'wheel-dedibuf-jump',                      'wheel#frigate#jump()'                                 ] ,
		\ [ 'wheel-dedibuf-change',                    'wheel#frigate#change()'                               ] ,
		\ [ 'wheel-dedibuf-tag',                       'wheel#frigate#tag()'                                  ] ,
		\ [ 'wheel-prompt-add-here',                   'wheel#tree#add_here()'                                ] ,
		\ [ 'wheel-prompt-add-circle',                 'wheel#tree#add_circle()'                              ] ,
		\ [ 'wheel-prompt-add-torus',                  'wheel#tree#add_torus()'                               ] ,
		\ [ 'wheel-prompt-add-file',                   'wheel#tree#add_file()'                                ] ,
		\ [ 'wheel-prompt-add-buffer',                 'wheel#tree#add_buffer()'                              ] ,
		\ [ 'wheel-prompt-add-glob',                   'wheel#tree#add_glob()'                                ] ,
		\ [ 'wheel-dedibuf-reorder-location',          "wheel#yggdrasil#reorder('location')"                  ] ,
		\ [ 'wheel-dedibuf-reorder-circle',            "wheel#yggdrasil#reorder('circle')"                    ] ,
		\ [ 'wheel-dedibuf-reorder-torus',             "wheel#yggdrasil#reorder('torus')"                     ] ,
		\ [ 'wheel-prompt-rename-location',            "wheel#tree#rename('location')"                        ] ,
		\ [ 'wheel-prompt-rename-circle',              "wheel#tree#rename('circle')"                          ] ,
		\ [ 'wheel-prompt-rename-torus',               "wheel#tree#rename('torus')"                           ] ,
		\ [ 'wheel-prompt-rename-file',                'wheel#tree#rename_file()'                             ] ,
		\ [ 'wheel-dedibuf-rename-location',           "wheel#yggdrasil#rename('location')"                   ] ,
		\ [ 'wheel-dedibuf-rename-circle',             "wheel#yggdrasil#rename('circle')"                     ] ,
		\ [ 'wheel-dedibuf-rename-torus',              "wheel#yggdrasil#rename('torus')"                      ] ,
		\ [ 'wheel-dedibuf-rename-location-filename',  'wheel#yggdrasil#rename_file()'                        ] ,
		\ [ 'wheel-prompt-delete-location',            "wheel#tree#delete('location')"                        ] ,
		\ [ 'wheel-prompt-delete-circle',              "wheel#tree#delete('circle')"                          ] ,
		\ [ 'wheel-prompt-delete-torus',               "wheel#tree#delete('torus')"                           ] ,
		\ [ 'wheel-dedibuf-delete-location',           "wheel#yggdrasil#delete('location')"                   ] ,
		\ [ 'wheel-dedibuf-delete-circle',             "wheel#yggdrasil#delete('circle')"                     ] ,
		\ [ 'wheel-dedibuf-delete-torus',              "wheel#yggdrasil#delete('torus')"                      ] ,
		\ [ 'wheel-prompt-copy-location',              "wheel#tree#copy('location')"                          ] ,
		\ [ 'wheel-prompt-copy-circle',                "wheel#tree#copy('circle')"                            ] ,
		\ [ 'wheel-prompt-copy-torus',                 "wheel#tree#copy('torus')"                             ] ,
		\ [ 'wheel-prompt-move-location',              "wheel#tree#move('location')"                          ] ,
		\ [ 'wheel-prompt-move-circle',                "wheel#tree#move('circle')"                            ] ,
		\ [ 'wheel-dedibuf-copy-move-location',        "wheel#yggdrasil#copy_move('location')"                ] ,
		\ [ 'wheel-dedibuf-copy-move-circle',          "wheel#yggdrasil#copy_move('circle')"                  ] ,
		\ [ 'wheel-dedibuf-copy-move-torus',           "wheel#yggdrasil#copy_move('torus')"                   ] ,
		\ [ 'wheel-dedibuf-reorganize',                'wheel#yggdrasil#reorganize()'                         ] ,
		\ [ 'wheel-dedibuf-reorg-tabwin',              'wheel#mirror#reorg_tabwin()'                          ] ,
		\ [ 'wheel-dedibuf-grep-edit',                 'wheel#shadow#grep_edit()'                             ] ,
		\ [ 'wheel-dedibuf-narrow',                    'wheel#shadow#narrow_file()'                           ] ,
		\ [ 'wheel-dedibuf-narrow-circle',             'wheel#shadow#narrow_circle()'                         ] ,
		\ [ 'wheel-prompt-find',                       'wheel#sailing#find()'                                 ] ,
		\ [ 'wheel-dedibuf-find',                      'wheel#frigate#find()'                                 ] ,
		\ [ 'wheel-dedibuf-async-find',                'wheel#frigate#async_find()'                           ] ,
		\ [ 'wheel-prompt-mru',                        'wheel#sailing#mru()'                                  ] ,
		\ [ 'wheel-dedibuf-mru',                       'wheel#frigate#mru()'                                  ] ,
		\ [ 'wheel-dedibuf-locate',                    'wheel#frigate#locate()'                               ] ,
		\ [ 'wheel-prompt-occur',                      'wheel#sailing#occur()'                                ] ,
		\ [ 'wheel-dedibuf-occur',                     'wheel#frigate#occur()'                                ] ,
		\ [ 'wheel-dedibuf-grep',                      'wheel#frigate#grep()'                                 ] ,
		\ [ 'wheel-dedibuf-outline',                   'wheel#frigate#outline()'                              ] ,
		\ [ 'wheel-prompt-switch-default-register',    'wheel#codex#switch_default_register()'                ] ,
		\ [ 'wheel-prompt-yank-plain-linewise-after',  'wheel#codex#yank_plain()'                             ] ,
		\ [ 'wheel-prompt-yank-plain-charwise-after',  "wheel#codex#yank_plain('charwise-after')"             ] ,
		\ [ 'wheel-prompt-yank-plain-linewise-before', "wheel#codex#yank_plain('linewise-before')"            ] ,
		\ [ 'wheel-prompt-yank-plain-charwise-before', "wheel#codex#yank_plain('charwise-before')"            ] ,
		\ [ 'wheel-prompt-yank-list-linewise-after',   'wheel#codex#yank_list()'                              ] ,
		\ [ 'wheel-prompt-yank-list-charwise-after',   "wheel#codex#yank_list('charwise-after')"              ] ,
		\ [ 'wheel-prompt-yank-list-linewise-before',  "wheel#codex#yank_list('linewise-before')"             ] ,
		\ [ 'wheel-prompt-yank-list-charwise-before',  "wheel#codex#yank_list('charwise-before')"             ] ,
		\ [ 'wheel-dedibuf-yank-plain',                "wheel#clipper#yank('plain')"                          ] ,
		\ [ 'wheel-dedibuf-yank-list',                 "wheel#clipper#yank('list')"                           ] ,
		\ [ 'wheel-dedibuf-undo-list',                 'wheel#triangle#undolist()'                            ] ,
		\ [ 'wheel-dedibuf-command',                   'wheel#mandala#command()'                              ] ,
		\ [ 'wheel-dedibuf-async',                     'wheel#mandala#async()'                                ] ,
		\ [ 'wheel-mandala-add',                       "wheel#cylinder#add('furtive')"                        ] ,
		\ [ 'wheel-mandala-delete',                    'wheel#cylinder#delete()'                              ] ,
		\ [ 'wheel-mandala-forward',                   'wheel#cylinder#forward()'                             ] ,
		\ [ 'wheel-mandala-backward',                  'wheel#cylinder#backward()'                            ] ,
		\ [ 'wheel-mandala-switch',                    'wheel#cylinder#switch()'                              ] ,
		\ [ 'wheel-layout-zoom',                       'wheel#mosaic#zoom()'                                  ] ,
		\ [ 'wheel-layout-tabs-locations',             "wheel#mosaic#tabs('location')"                        ] ,
		\ [ 'wheel-layout-tabs-circles',               "wheel#mosaic#tabs('circle')"                          ] ,
		\ [ 'wheel-layout-tabs-toruses',               "wheel#mosaic#tabs('torus')"                           ] ,
		\ [ 'wheel-layout-split-locations',            "wheel#mosaic#split('location')"                       ] ,
		\ [ 'wheel-layout-split-circles',              "wheel#mosaic#split('circle')"                         ] ,
		\ [ 'wheel-layout-split-toruses',              "wheel#mosaic#split('torus')"                          ] ,
		\ [ 'wheel-layout-vsplit-locations',           "wheel#mosaic#split('location', 'vertical')"           ] ,
		\ [ 'wheel-layout-vsplit-circles',             "wheel#mosaic#split('circle', 'vertical')"             ] ,
		\ [ 'wheel-layout-vsplit-toruses',             "wheel#mosaic#split('torus', 'vertical')"              ] ,
		\ [ 'wheel-layout-main-top-locations',         "wheel#mosaic#split('location', 'main_top')"           ] ,
		\ [ 'wheel-layout-main-top-circles',           "wheel#mosaic#split('circle', 'main_top')"             ] ,
		\ [ 'wheel-layout-main-top-toruses',           "wheel#mosaic#split('torus', 'main_top')"              ] ,
		\ [ 'wheel-layout-main-left-locations',        "wheel#mosaic#split('location', 'main_left')"          ] ,
		\ [ 'wheel-layout-main-left-circles',          "wheel#mosaic#split('circle', 'main_left')"            ] ,
		\ [ 'wheel-layout-main-left-toruses',          "wheel#mosaic#split('torus', 'main_left')"             ] ,
		\ [ 'wheel-layout-grid-locations',             "wheel#mosaic#split_grid('location')"                  ] ,
		\ [ 'wheel-layout-grid-circles',               "wheel#mosaic#split_grid('circle')"                    ] ,
		\ [ 'wheel-layout-grid-toruses',               "wheel#mosaic#split_grid('torus')"                     ] ,
		\ [ 'wheel-layout-tab-win-torus',              "wheel#pyramid#steps('torus')"                         ] ,
		\ [ 'wheel-layout-tab-win-circle',             "wheel#pyramid#steps('circle')"                        ] ,
		\ [ 'wheel-layout-rotate-counter-clockwise',   'wheel#mosaic#rotate_counter_clockwise()'              ] ,
		\ [ 'wheel-layout-rotate-clockwise',           'wheel#mosaic#rotate_clockwise()'                      ] ,
		\ [ 'wheel-spiral-cursor',                     'wheel#spiral#cursor()'                                ] ,
		\ [ 'wheel-debug-fresh-wheel',                 'wheel#void#fresh_wheel()'                             ] ,
		\ [ 'wheel-debug-clear-echo-area',             'wheel#status#clear()'                                 ] ,
		\ [ 'wheel-debug-clear-messages',              'wheel#status#clear_messages()'                        ] ,
		\ [ 'wheel-debug-clear-signs',                 'wheel#chakra#clear()'                                 ] ,
		\ [ 'wheel-debug-prompt-history-circuit',      'wheel#vortex#history_circuit()'                       ] ,
		\ [ 'wheel-debug-dedibuf-history-circuit',     'wheel#whirl#history_circuit()'                        ] ,
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = [
				\ [ 'wheel-dedibuf-narrow', 'wheel#shadow#narrow_file()' ],
				\ ]
	lockvar! s:plugs_visual
endif

if ! exists('s:plugs_expr')
	let s:plugs_expr = [
				\ [ 'wheel-dedibuf-narrow-operator', 'wheel#shadow#narrow_file_operator()' ],
				\ ]
	lockvar! s:plugs_expr
endif

" ---- maps

if ! exists('s:maps_level_0_normal')
	let s:maps_level_0_normal = [
		\ [ '<m-m>',         'wheel-menu-main'                          ] ,
		\ [ '=',             'wheel-menu-meta'                          ] ,
		\ [ 'i',             'wheel-info'                               ] ,
		\ [ '<m-$>',         'wheel-sync-up'                            ] ,
		\ [ '$',             'wheel-sync-down'                          ] ,
		\ [ 'r',             'wheel-read-wheel'                         ] ,
		\ [ 'w',             'wheel-write-wheel'                        ] ,
		\ [ 'R',             'wheel-read-session'                       ] ,
		\ [ 'W',             'wheel-write-layout'                       ] ,
		\ [ '<pageup>',      'wheel-previous-location'                  ] ,
		\ [ '<pagedown>',    'wheel-next-location'                      ] ,
		\ [ '<c-pageup>',    'wheel-previous-circle'                    ] ,
		\ [ '<c-pagedown>',  'wheel-next-circle'                        ] ,
		\ [ '<s-pageup>',    'wheel-previous-torus'                     ] ,
		\ [ '<s-pagedown>',  'wheel-next-torus'                         ] ,
		\ [ '<home>',        'wheel-history-newer'                      ] ,
		\ [ '<end>',         'wheel-history-older'                      ] ,
		\ [ '<c-home>',      'wheel-history-newer-in-circle'            ] ,
		\ [ '<c-end>',       'wheel-history-older-in-circle'            ] ,
		\ [ '<s-home>',      'wheel-history-newer-in-torus'             ] ,
		\ [ '<s-end>',       'wheel-history-older-in-torus'             ] ,
		\ [ '<c-^>',         'wheel-alternate-anywhere'                 ] ,
		\ [ '<m-^>',         'wheel-alternate-same-circle'              ] ,
		\ [ '<m-c-^>',       'wheel-alternate-same-torus-other-circle'  ] ,
		\ [ '^',             'wheel-alternate-menu'                     ] ,
		\ [ 'a',             'wheel-prompt-add-here'                    ] ,
		\ [ '<c-a>',         'wheel-prompt-add-circle'                  ] ,
		\ [ 'A',             'wheel-prompt-add-torus'                   ] ,
		\ [ '+f',            'wheel-prompt-add-file'                    ] ,
		\ [ '+b',            'wheel-prompt-add-buffer'                  ] ,
		\ [ '*',             'wheel-prompt-add-glob'                    ] ,
		\ ]
	lockvar! s:maps_level_0_normal
endif

if ! exists('s:maps_level_1_normal')
	let s:maps_level_1_normal = [
		\ [ '<cr>',              'wheel-prompt-location'                  ],
		\ [ '<c-cr>',            'wheel-prompt-circle'                    ],
		\ [ '<s-cr>',            'wheel-prompt-torus'                     ],
		\ [ '<m-cr>',            'wheel-prompt-multi-switch'              ],
		\ [ '<space>',           'wheel-dedibuf-location'                 ],
		\ [ '<c-space>',         'wheel-dedibuf-circle'                   ],
		\ [ '<s-space>',         'wheel-dedibuf-torus'                    ],
		\ [ 'x',                 'wheel-prompt-index'                     ],
		\ [ '<c-x>',             'wheel-prompt-index-circles'             ],
		\ [ 'X',                 'wheel-dedibuf-index'                    ],
		\ [ '<m-x>',             'wheel-dedibuf-index-tree'               ],
		\ [ '<m-s-x>',           'wheel-dedibuf-index-circles'            ],
		\ [ 'h',                 'wheel-prompt-history'                   ],
		\ [ '<m-h>',             'wheel-dedibuf-history'                  ],
		\ [ 'e',                 'wheel-prompt-frecency'                  ],
		\ [ '<m-e>',             'wheel-dedibuf-frecency'                 ],
		\ [ s:batch .. 'o',      'wheel-dedibuf-reorder-location'         ],
		\ [ s:batch .. '<c-o>',  'wheel-dedibuf-reorder-circle'           ],
		\ [ s:batch .. 'O',      'wheel-dedibuf-reorder-torus'            ],
		\ [ 'n',                 'wheel-prompt-rename-location'           ],
		\ [ '<c-n>',             'wheel-prompt-rename-circle'             ],
		\ [ 'N',                 'wheel-prompt-rename-torus'              ],
		\ [ '<m-n>',             'wheel-prompt-rename-file'               ],
		\ [ s:batch .. 'n',      'wheel-dedibuf-rename-location'          ],
		\ [ s:batch .. '<c-n>',  'wheel-dedibuf-rename-circle'            ],
		\ [ s:batch .. 'N',      'wheel-dedibuf-rename-torus'             ],
		\ [ s:batch .. '<m-n>',  'wheel-dedibuf-rename-location-filename' ],
		\ [ 'd',                 'wheel-prompt-delete-location'           ],
		\ [ '<c-d>',             'wheel-prompt-delete-circle'             ],
		\ [ 'D',                 'wheel-prompt-delete-torus'              ],
		\ [ s:batch .. 'd',      'wheel-dedibuf-delete-location'          ],
		\ [ s:batch .. '<c-d>',  'wheel-dedibuf-delete-circle'            ],
		\ [ s:batch .. 'D',      'wheel-dedibuf-delete-torus'             ],
		\ [ 'c',                 'wheel-prompt-copy-location'             ],
		\ [ '<m-c>',             'wheel-prompt-copy-circle'               ],
		\ [ 'C',                 'wheel-prompt-copy-torus'                ],
		\ [ 'm',                 'wheel-prompt-move-location'             ],
		\ [ 'M',                 'wheel-prompt-move-circle'               ],
		\ [ s:batch .. 'c',      'wheel-dedibuf-copy-move-location'       ],
		\ [ s:batch .. '<m-c>',  'wheel-dedibuf-copy-move-circle'         ],
		\ [ s:batch .. 'C',      'wheel-dedibuf-copy-move-torus'          ],
		\ ]
	lockvar! s:maps_level_1_normal
endif

if ! exists('s:maps_level_2_normal')
	let s:maps_level_2_normal = [
		\ [ 'b',                   'wheel-prompt-buffer'                     ] ,
		\ [ '<m-b>',               'wheel-dedibuf-buffer'                    ] ,
		\ [ '<c-b>',               'wheel-dedibuf-buffer-all'                ] ,
		\ [ 'v',                   'wheel-prompt-tabwin'                     ] ,
		\ [ '<m-v>',               'wheel-dedibuf-tabwin-tree'               ] ,
		\ [ '<c-v>',               'wheel-dedibuf-tabwin'                    ] ,
		\ [ "'",                   'wheel-prompt-marker'                     ] ,
		\ [ 'j',                   'wheel-prompt-jump'                       ] ,
		\ [ ',',                   'wheel-prompt-change'                     ] ,
		\ [ 't',                   'wheel-prompt-tag'                        ] ,
		\ [ "<m-'>",               'wheel-dedibuf-marker'                    ] ,
		\ [ '<m-j>',               'wheel-dedibuf-jump'                      ] ,
		\ [ ';',                   'wheel-dedibuf-change'                    ] ,
		\ [ '<m-t>',               'wheel-dedibuf-tag'                       ] ,
		\ [ '<m-r>',               'wheel-dedibuf-reorganize'                ] ,
		\ [ '<c-r>',               'wheel-dedibuf-reorg-tabwin'              ] ,
		\ [ '<m-g>',               'wheel-dedibuf-grep-edit'                 ] ,
		\ [ '-%',                  'wheel-dedibuf-narrow'                    ] ,
		\ [ '--',                  'wheel-dedibuf-narrow-operator'           ] ,
		\ [ '-c',                  'wheel-dedibuf-narrow-circle'             ] ,
		\ [ 'f',                   'wheel-prompt-find'                       ] ,
		\ [ '<m-f>',               'wheel-dedibuf-find'                      ] ,
		\ [ s:async .. 'f',        'wheel-dedibuf-async-find'                ] ,
		\ [ 'u',                   'wheel-prompt-mru'                        ] ,
		\ [ '<m-u>',               'wheel-dedibuf-mru'                       ] ,
		\ [ 'l',                   'wheel-dedibuf-locate'                    ] ,
		\ [ 'o',                   'wheel-prompt-occur'                      ] ,
		\ [ '<m-o>',               'wheel-dedibuf-occur'                     ] ,
		\ [ 'g',                   'wheel-dedibuf-grep'                      ] ,
		\ [ '<c-o>',               'wheel-dedibuf-outline'                   ] ,
		\ [ '<c-y>',               'wheel-prompt-switch-default-register'    ] ,
		\ [ 'y',                   'wheel-prompt-yank-plain-linewise-after'  ] ,
		\ [ 'p',                   'wheel-prompt-yank-plain-charwise-after'  ] ,
		\ [ 'Y',                   'wheel-prompt-yank-plain-linewise-before' ] ,
		\ [ 'P',                   'wheel-prompt-yank-plain-charwise-before' ] ,
		\ [ '<m-y>',               'wheel-dedibuf-yank-plain'                ] ,
		\ [ '<m-p>',               'wheel-dedibuf-yank-list'                 ] ,
		\ [ '<c-u>',               'wheel-dedibuf-undo-list'                 ] ,
		\ [ ':',                   'wheel-dedibuf-command'                   ] ,
		\ [ s:async .. '&',        'wheel-dedibuf-async'                     ] ,
		\ [ '<tab>',               'wheel-mandala-add'                       ] ,
		\ [ '<backspace>',         'wheel-mandala-delete'                    ] ,
		\ [ '<left>',              'wheel-mandala-backward'                  ] ,
		\ [ '<right>',             'wheel-mandala-forward'                   ] ,
		\ [ '<up>',                'wheel-mandala-switch'                    ] ,
		\ [ s:layout .. 'z',       'wheel-layout-zoom'                       ] ,
		\ [ s:layout .. 't',       'wheel-layout-tabs-locations'             ] ,
		\ [ s:layout .. '<c-t>',   'wheel-layout-tabs-circles'               ] ,
		\ [ s:layout .. 'T',       'wheel-layout-tabs-toruses'               ] ,
		\ [ s:layout .. 's',       'wheel-layout-split-locations'            ] ,
		\ [ s:layout .. '<c-s>',   'wheel-layout-split-circles'              ] ,
		\ [ s:layout .. 'S',       'wheel-layout-split-toruses'              ] ,
		\ [ s:layout .. 'v',       'wheel-layout-vsplit-locations'           ] ,
		\ [ s:layout .. '<c-v>',   'wheel-layout-vsplit-circles'             ] ,
		\ [ s:layout .. 'V',       'wheel-layout-vsplit-toruses'             ] ,
		\ [ s:layout .. 'm',       'wheel-layout-main-top-locations'         ] ,
		\ [ s:layout .. '<c-m>',   'wheel-layout-main-top-circles'           ] ,
		\ [ s:layout .. 'M',       'wheel-layout-main-top-toruses'           ] ,
		\ [ s:layout .. 'l',       'wheel-layout-main-left-locations'        ] ,
		\ [ s:layout .. '<c-l>',   'wheel-layout-main-left-circles'          ] ,
		\ [ s:layout .. 'L',       'wheel-layout-main-left-toruses'          ] ,
		\ [ s:layout .. 'g',       'wheel-layout-grid-locations'             ] ,
		\ [ s:layout .. '<c-g>',   'wheel-layout-grid-circles'               ] ,
		\ [ s:layout .. 'G',       'wheel-layout-grid-toruses'               ] ,
		\ [ s:layout .. '&',       'wheel-layout-tab-win-circle'             ] ,
		\ [ s:layout .. '<M-&>',   'wheel-layout-tab-win-torus'              ] ,
		\ [ s:layout .. '<up>',    'wheel-layout-rotate-counter-clockwise'   ] ,
		\ [ s:layout .. '<down>',  'wheel-layout-rotate-clockwise'           ] ,
		\ ]
	lockvar! s:maps_level_2_normal
endif

if ! exists('s:maps_level_2_visual')
	let s:maps_level_2_visual = [
		\ [ '--', 'wheel-dedibuf-narrow' ]
		\ ]
	lockvar! s:maps_level_2_visual
endif

if ! exists('s:maps_level_20_normal')
	let s:maps_level_20_normal = [
		\ [ s:debug .. 'Z',      'wheel-debug-fresh-wheel'             ] ,
		\ [ s:debug .. 'e',      'wheel-debug-clear-echo-area'         ] ,
		\ [ s:debug .. 'm',      'wheel-debug-clear-messages'          ] ,
		\ [ s:debug .. 's',      'wheel-debug-clear-signs'             ] ,
		\ [ s:debug .. 'h',      'wheel-debug-prompt-history-circuit'  ] ,
		\ [ s:debug .. '<m-h>',  'wheel-debug-dedibuf-history-circuit' ] ,
		\ ]
	lockvar! s:maps_level_20_normal
endif

" ---- public interface

fun! wheel#geode#fetch (varname, conversion = 'no-conversion')
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
