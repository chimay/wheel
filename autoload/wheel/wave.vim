" vim: set ft=vim fdm=indent iskeyword&:

" Job control, neovim

if ! has('unix')
	echomsg 'wheel : wave is only supported on Unix systems.'
	finish
endif

if ! has('nvim')
	echomsg 'wheel wave is for neovim : see ripple for vim'
	finish
endif

if ! exists('*appendbufline')
	echomsg 'You need appendbufline to handle jobs'
	finish
endif

" Callback

fun! s:Out (chan, data, event) dict
	" Callback ou stdout event
	let bufnum = self.bufnum
	let data = join(a:data)
	let text = split(data, "\r")
	let last = line('$')
	let text = text[:-2]
	call appendbufline(bufnum, last, text)
	call extend(b:wheel_lines, text)
endfun

fun! s:Err (chan, data, event) dict
	" Callback ou stderr event
	let bufnum = self.bufnum
	let data = join(a:data)
	let text = split(data, "\r")
	let last = line('$')
	call appendbufline(bufnum, last, text)
	call extend(b:wheel_lines, text)
endfun

fun! s:Exit (chan, data, event) dict
	" Callback ou exit event
	let bufnum = self.bufnum
	let code = a:data
	let text = printf('%s %s : %s', self.name, a:event, code)
	eval g:wheel_wave->wheel#chain#remove_element(self)
	echomsg text
endfun

let s:callbacks = {
			\ 'on_stdout' : function('s:Out'),
			\ 'on_stderr' : function('s:Err'),
			\ 'on_exit' : function('s:Exit')
			\}

" Buffer

fun! wheel#wave#template (mandala_type)
	" Job buffer template
	call wheel#mandala#template ()
	setlocal bufhidden=hide
	call wheel#mandala#filename(a:mandala_type)
	let b:wheel_lines = []
endfun

" Main

fun! wheel#wave#start (command, ...)
	" Start a new job
	if a:0 > 0
		let options = a:1
	else
		let options = {'mandala_open' : v:true, 'mandala_type' : 'wave'}
	endif
	if type(a:command) == v:t_list
		let command = a:command
	elseif type(a:command) == v:t_string
		let command = split(a:command)
	else
		echomsg 'wheel wave new : bad command format'
		return
	endif
	" Buffer
	if options.mandala_open
		call wheel#mandala#open (options.mandala_type)
	endif
	call wheel#wave#template (options.mandala_type)
	" Expand tilde in filenames
	eval command->map({ _, val -> expand(val) })
	" Job
	let job = {}
	let job.name = fnamemodify(command[0], ':t:r')
	let job.bufnum = bufnr('%')
	let job.pty = v:true
	call extend(job, s:callbacks)
	call extend(job, options)
	let jobid = jobstart(command, job)
	if jobid < 0
		echomsg 'wheel wave start : failed to start' command[0]
		return
	endif
	let job.iden = jobid
	call add(g:wheel_wave, job)
	return job
endfun

fun! wheel#wave#send (job, text)
	" Send text to job
	let job = a:job
	let text = a:text
	return chansend(job.iden, text)
endfun

fun! wheel#wave#stop (...)
	" Stop job
	if a:0 > 0
		let job = a:1
	else
		if ! empty(g:wheel_wave)
			let job = g:wheel_wave[-1]
		else
			echomsg 'wheel wave stop : no more job left.'
			return v:false
		endif
	endif
	call jobstop(job.iden)
	eval g:wheel_wave->wheel#chain#remove_element(job)
endfun
