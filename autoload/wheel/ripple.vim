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
	exe 'file ' . '/wheel/ripple/' . bufnr('%')
	call append(0, '')
endfun

" Main

fun! wheel#ripple#start (command, ...)
	" Start a new job
	if a:0 > 0
		let options = a:1
	else
		let options = {'new_buffer' : v:true}
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
	if options.new_buffer
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
