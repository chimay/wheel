" vim: ft=vim fdm=indent:

" Command, Mappings

fun! wheel#centre#commands ()
	" Define commands
	" Status
	command! WheelDashboard call wheel#status#dashboard()
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
endfun

fun! wheel#centre#mappings ()
	" Define mappings
	" Basic
	if g:wheel_config.mappings >= 0
		" Hub : menus
		exe 'nnoremap ' . g:wheel_config.prefix . '= :call wheel#hub#meta()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'm :call wheel#hub#main()<cr>'
		" Tree : add
		exe 'nnoremap ' . g:wheel_config.prefix . 'a :call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-a> :call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'A :call wheel#tree#add_torus()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'f :call wheel#tree#add_file()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'b :call wheel#tree#add_buffer()<cr>'
		" Vortex : move to elements
		exe 'nnoremap ' . g:wheel_config.prefix . "<left> :call wheel#vortex#previous('location')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<right> :call wheel#vortex#next('location')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<c-left> :call wheel#vortex#previous('circle')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<c-right> :call wheel#vortex#next('circle')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<s-left> :call wheel#vortex#previous('torus')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<s-right> :call wheel#vortex#next('torus')<cr>"
		" Disc : load / save wheel
		exe 'nnoremap ' . g:wheel_config.prefix . 'r :call wheel#disc#read_all()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'w :call wheel#disc#write_all()<cr>'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Tree : rename, delete
		exe 'nnoremap ' . g:wheel_config.prefix . 'n :call wheel#tree#rename_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<m-n> :call wheel#tree#rename_file()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-n> :call wheel#tree#rename_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'N :call wheel#tree#rename_torus()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'd :call wheel#tree#delete_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-d> :call wheel#tree#delete_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'D :call wheel#tree#delete_torus()<cr>'
		" Vortex : move to elements
		exe 'nnoremap ' . g:wheel_config.prefix . '<cr> :call wheel#vortex#switch_location()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-cr> :call wheel#vortex#switch_circle()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<s-cr> :call wheel#vortex#switch_torus()<cr>'
		" Pendulum : history
		exe 'nnoremap ' . g:wheel_config.prefix . '<tab> :call wheel#pendulum#newer()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<backspace> :call wheel#pendulum#older()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '^ :call wheel#pendulum#alternate()<cr>'
		" Mandala : buffer menus
		exe 'nnoremap ' . g:wheel_config.prefix . "<space> :call wheel#mandala#jump('location')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<c-space> :call wheel#mandala#jump('circle')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<s-space> :call wheel#mandala#jump('torus')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . 's :call wheel#mandala#helix()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<c-s> :call wheel#mandala#grid()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . '<m-s> :call wheel#mandala#tree()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . 'h :call wheel#mandala#history()<cr>'
		exe 'nnoremap ' . g:wheel_config.prefix . "o :call wheel#mandala#reorder('location')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "<C-o> :call wheel#mandala#reorder('circle')<cr>"
		exe 'nnoremap ' . g:wheel_config.prefix . "O :call wheel#mandala#reorder('torus')<cr>"
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Hub : Menus
		nnoremap <D-=>        :call wheel#hub#meta()<cr>
		nnoremap <D-m>        :call wheel#hub#main()<cr>
		" Tree
		nnoremap <D-Insert>   :call wheel#tree#add_here()<cr>
		nnoremap <D-Del>      :call wheel#tree#delete_location()<cr>
		" Vortex
		nnoremap <C-PageUp>   :call wheel#vortex#previous('location')<cr>
		nnoremap <C-PageDown> :call wheel#vortex#next('location')<cr>
		nnoremap <C-Home>     :call wheel#vortex#previous('circle')<cr>
		nnoremap <C-End>      :call wheel#vortex#next('circle')<cr>
		nnoremap <S-Home>     :call wheel#vortex#previous('torus')<cr>
		nnoremap <S-End>      :call wheel#vortex#next('torus')<cr>
		" Pendulum
		nnoremap <S-PageUp>     :call wheel#pendulum#newer()<cr>
		nnoremap <S-PageDown>   :call wheel#pendulum#older()<cr>
		nnoremap <C-^>          :call wheel#pendulum#alternate()<cr>
		nnoremap <D-^>          :call wheel#pendulum#alternate_same_torus_other_circle()<cr>
		nnoremap <C-S-PageUp>   :call wheel#pendulum#alternate_same_torus()<cr>
		nnoremap <C-S-PageDown> :call wheel#pendulum#alternate_same_circle()<cr>
		nnoremap <C-S-Home>     :call wheel#pendulum#alternate_other_torus()<cr>
		nnoremap <C-S-End>      :call wheel#pendulum#alternate_other_circle()<cr>
		" Mandala
		nnoremap <Space>      :call wheel#mandala#jump('location')<cr>
		nnoremap <C-Space>    :call wheel#mandala#jump('circle')<cr>
		nnoremap <S-Space>    :call wheel#mandala#jump('torus')<cr>
		nnoremap <D-Space>        :call wheel#mandala#tree()<cr>
	endif
endfun
