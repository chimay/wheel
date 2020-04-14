" vim: ft=vim fdm=indent:

" Command, Mappings

fun! wheel#centre#commands ()
	" Define commands
	" Status
	command! WheelDashboard call wheel#status#dashboard()
	command! -nargs=+ WheelBatch call wheel#vector#argdo(<q-args>)
	command! -nargs=+ WheelGrep call wheel#vector#grep(<q-args>)
endfun

fun! wheel#centre#mappings ()
	" Define mappings
	let prefix = g:wheel_config.prefix
	" Basic
	if g:wheel_config.mappings >= 0
		" Hub : menus
		exe 'nnoremap ' . prefix . '= :call wheel#hub#meta()<cr>'
		exe 'nnoremap ' . prefix . 'm :call wheel#hub#main()<cr>'
		" Tree : add
		exe 'nnoremap ' . prefix . 'a :call wheel#tree#add_here()<cr>'
		exe 'nnoremap ' . prefix . '<c-a> :call wheel#tree#add_circle()<cr>'
		exe 'nnoremap ' . prefix . 'A :call wheel#tree#add_torus()<cr>'
		exe 'nnoremap ' . prefix . 'f :call wheel#tree#add_file()<cr>'
		exe 'nnoremap ' . prefix . 'b :call wheel#tree#add_buffer()<cr>'
		" Vortex : move to elements
		exe 'nnoremap ' . prefix . "<left> :call wheel#vortex#previous('location')<cr>"
		exe 'nnoremap ' . prefix . "<right> :call wheel#vortex#next('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-left> :call wheel#vortex#previous('circle')<cr>"
		exe 'nnoremap ' . prefix . "<c-right> :call wheel#vortex#next('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-left> :call wheel#vortex#previous('torus')<cr>"
		exe 'nnoremap ' . prefix . "<s-right> :call wheel#vortex#next('torus')<cr>"
		" Disc : load / save wheel
		exe 'nnoremap ' . prefix . 'r :call wheel#disc#read_all()<cr>'
		exe 'nnoremap ' . prefix . 'w :call wheel#disc#write_all()<cr>'
	endif
	" Common
	if g:wheel_config.mappings >= 1
		" Mandala : buffer menus
		exe 'nnoremap ' . prefix . "<space> :call wheel#mandala#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-space> :call wheel#mandala#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-space> :call wheel#mandala#switch('torus')<cr>"
		exe 'nnoremap ' . prefix . 'x :call wheel#mandala#helix()<cr>'
		exe 'nnoremap ' . prefix . '<c-x> :call wheel#mandala#grid()<cr>'
		exe 'nnoremap ' . prefix . '<m-x> :call wheel#mandala#tree()<cr>'
		exe 'nnoremap ' . prefix . 'h :call wheel#mandala#history()<cr>'
		exe 'nnoremap ' . prefix . "o :call wheel#mandala#reorder('location')<cr>"
		exe 'nnoremap ' . prefix . "<C-o> :call wheel#mandala#reorder('circle')<cr>"
		exe 'nnoremap ' . prefix . "O :call wheel#mandala#reorder('torus')<cr>"
		" Tree : rename, delete
		exe 'nnoremap ' . prefix . "n :call wheel#tree#rename('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-n> :call wheel#tree#rename('circle')<cr>"
		exe 'nnoremap ' . prefix . "N :call wheel#tree#rename('torus')<cr>"
		exe 'nnoremap ' . prefix . '<m-n> :call wheel#tree#rename_file()<cr>'
		exe 'nnoremap ' . prefix . "d :call wheel#tree#delete('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-d> :call wheel#tree#delete('circle')<cr>"
		exe 'nnoremap ' . prefix . "D :call wheel#tree#delete('torus')<cr>"
		" Vortex : move to elements
		exe 'nnoremap ' . prefix . "<cr> :call wheel#vortex#switch('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-cr> :call wheel#vortex#switch('circle')<cr>"
		exe 'nnoremap ' . prefix . "<s-cr> :call wheel#vortex#switch('torus')<cr>"
		" Pendulum : history
		exe 'nnoremap ' . prefix . '<tab> :call wheel#pendulum#newer()<cr>'
		exe 'nnoremap ' . prefix . '<backspace> :call wheel#pendulum#older()<cr>'
		exe 'nnoremap ' . prefix . '^ :call wheel#pendulum#alternate()<cr>'
	endif
	" Advanced
	if g:wheel_config.mappings >= 2
		" Tabs & Windows
		exe 'nnoremap ' . prefix . 'z :call wheel#mosaic#zoom()<cr>'
		exe 'nnoremap ' . prefix . "t :call wheel#mosaic#tabs('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-t> :call wheel#mosaic#tabs('circle')<cr>"
		exe 'nnoremap ' . prefix . "T :call wheel#mosaic#tabs('torus')<cr>"
		exe 'nnoremap ' . prefix . "s :call wheel#mosaic#split('location')<cr>"
		exe 'nnoremap ' . prefix . "<c-s> :call wheel#mosaic#split('circle')<cr>"
		exe 'nnoremap ' . prefix . "S :call wheel#mosaic#split('torus')<cr>"
		exe 'nnoremap ' . prefix . "v :call wheel#mosaic#split('location', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "<c-v> :call wheel#mosaic#split('circle', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "V :call wheel#mosaic#split('torus', 'vertical')<cr>"
		exe 'nnoremap ' . prefix . "P :call wheel#pyramid#steps('torus')<cr>"
		exe 'nnoremap ' . prefix . "<c-p> :call wheel#pyramid#steps('circle')<cr>"
		" Yank wheel
		exe 'nnoremap ' . prefix . "y :call wheel#mandala#yank('list')<cr>"
		exe 'nnoremap ' . prefix . "<m-y> :call wheel#mandala#yank('plain')<cr>"
		" Reorganize
		exe 'nnoremap ' . prefix . '<m-o> :call wheel#mandala#reorganize()<cr>'
	endif
	" Without prefix
	if g:wheel_config.mappings >= 10
		" Hub : Menus
		nnoremap <D-=>        :call wheel#hub#meta()<cr>
		nnoremap <D-m>        :call wheel#hub#main()<cr>
		" Mandala : special buffers
		nnoremap <Space>      :call wheel#mandala#switch('location')<cr>
		nnoremap <C-Space>    :call wheel#mandala#switch('circle')<cr>
		nnoremap <S-Space>    :call wheel#mandala#switch('torus')<cr>
		nnoremap <D-Space>    :call wheel#mandala#tree()<cr>
		nnoremap <M-Space>    :call wheel#mandala#reorganize()<cr>
		" Tree : add, rename, delete
		nnoremap <D-Insert>   :call wheel#tree#add_here()<cr>
		nnoremap <D-Del>      :call wheel#tree#delete('location')<cr>
		" Vortex : switch
		nnoremap <C-PageUp>   :call wheel#vortex#previous('location')<cr>
		nnoremap <C-PageDown> :call wheel#vortex#next('location')<cr>
		nnoremap <C-Home>     :call wheel#vortex#previous('circle')<cr>
		nnoremap <C-End>      :call wheel#vortex#next('circle')<cr>
		nnoremap <S-Home>     :call wheel#vortex#previous('torus')<cr>
		nnoremap <S-End>      :call wheel#vortex#next('torus')<cr>
		" Pendulum : history
		nnoremap <S-PageUp>     :call wheel#pendulum#newer()<cr>
		nnoremap <S-PageDown>   :call wheel#pendulum#older()<cr>
		nnoremap <C-^>          :call wheel#pendulum#alternate()<cr>
		nnoremap <D-^>          :call wheel#pendulum#alternate_same_torus_other_circle()<cr>
		nnoremap <C-S-PageUp>   :call wheel#pendulum#alternate_same_torus()<cr>
		nnoremap <C-S-PageDown> :call wheel#pendulum#alternate_same_circle()<cr>
		nnoremap <C-S-Home>     :call wheel#pendulum#alternate_other_torus()<cr>
		nnoremap <C-S-End>      :call wheel#pendulum#alternate_other_circle()<cr>
		" Yank
		nnoremap <D-y>          :call wheel#mandala#yank('list')<cr>
		nnoremap <D-p>          :call wheel#mandala#yank('plain')<cr>
		" Batch
		nnoremap <D-b>          :WheelBatch<space>
		nnoremap <D-g>          :WheelGrep<space>
	endif
	" Debug
	if g:wheel_config.mappings >= 20
		exe 'nnoremap ' . prefix . "0 :call wheel#checknfix#fresh_wheel()<cr>"
	endif
endfun
