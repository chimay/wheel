" vim: set ft=vim fdm=indent iskeyword&:

" Ripple
"
" Job control, vim 8

if ! has('unix')
	echomsg 'wheel : ripple is only supported on Unix systems'
	finish
endif

if has('nvim')
	echomsg 'wheel ripple is for vim : see wave for neovim'
	finish
endif

if ! exists('*appendbufline')
	echomsg 'You need appendbufline to handle jobs'
	finish
endif

" Callback

fun! wheel#ripple#callback_exit (chan, code)
	" Callback ou exit event
	let text = printf('%s %s', a:chan, a:code)
	eval g:wheel_ripple->remove(-1)
	echomsg text
endfun

" Mandala

fun! wheel#ripple#template (mandala_type)
	" Job buffer template
	call wheel#mandala#template ()
	let b:wheel_nature.is_writable = v:true
	setlocal noreadonly
	setlocal modifiable
endfun

fun! wheel#ripple#stop_map ()
	" Map to stop the job
	let map = 'nnoremap <silent> <buffer>'
	let callme = '<cmd>call wheel#ripple#stop()<cr>'
	execute map '<c-s>' callme
endfun

" Main

fun! wheel#ripple#start (command, ...)
	" Start a new job
	let command = a:command
	let kind = type(a:command)
	if kind == v:t_list
		let command = a:command
	elseif kind == v:t_string
		let command = split(a:command)
	else
		echomsg 'wheel ripple start : bad command format'
		return
	endif
	if a:0 > 0
		let options = a:1
	else
		let options = {'mandala_type' : 'ripple'}
	endif
	" mandala
	let mandala_type = options.mandala_type
	call wheel#mandala#blank (mandala_type)
	call wheel#mandala#fill('')
	call wheel#ripple#template (mandala_type)
	" job
	let jobopts = {}
	let jobopts.out_io = 'buffer'
	let bufname = bufname(bufnr('%'))
	let jobopts.out_name = bufname
	let jobopts.exit_cb = 'wheel#ripple#callback_exit'
	let job = job_start(command, jobopts)
	eval g:wheel_ripple->add(job)
	call wheel#ripple#stop_map ()
	return job
endfun

fun! wheel#ripple#stop (...)
	" Stop job
	if a:0 > 0
		let job = a:1
	else
		if ! empty(g:wheel_ripple)
			let job = g:wheel_ripple[-1]
		else
			echomsg 'wheel ripple stop : no more job left'
			return v:false
		endif
	endif
	call job_stop(job)
	" remove of job in g:wheel_ripple is done in callback_exit
endfun
