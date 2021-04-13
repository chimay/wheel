" vim: ft=vim fdm=indent:

" Job control, vim 8

if has('nvim')
	echomsg 'Wheel ripple is for vim : see wave for neovim'
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
	call wheel#chain#pop (g:wheel_ripple)
	echomsg text
endfun

" Buffer

fun! wheel#ripple#template ()
	" Job buffer template
	call wheel#mandala#template ()
	setlocal bufhidden=hide
	let current = g:wheel_buffers.current
	let iden = g:wheel_buffers.iden[current]
	let pseudo_folders = '/wheel/' . iden . '/ripple'
	exe 'silent file' pseudo_folders
	call append(0, '')
endfun

" Main

fun! wheel#ripple#start (command, ...)
	" Start a new job
	if a:0 > 0
		let options = a:1
	else
		let options = {'mandala_open' : v:true}
	endif
	if type(a:command) == v:t_list
		let command = a:command
	elseif type(a:command) == v:t_string
		let command = split(a:command)
	else
		echomsg 'Wheel ripple new : bad command format'
		return
	endif
	" Buffer
	if options.mandala_open
		call wheel#mandala#open ('ripple')
	endif
	call wheel#ripple#template ()
	" Expand tilde in filenames
	call map(command, {_, val -> expand(val)})
	" Job
	let jobopts = {}
	let jobopts.out_io = 'buffer'
	let bufname = bufname(bufnr('%'))
	let jobopts.out_name = bufname
	let jobopts.exit_cb = 'wheel#ripple#callback_exit'
	let job = job_start(command, jobopts)
	call add(g:wheel_ripple, job)
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
			echomsg 'wheel ripple stop : no more job left.'
			return v:false
		endif
	endif
	call job_stop(job)
	call wheel#chain#remove_element(job, g:wheel_ripple)
endfun
