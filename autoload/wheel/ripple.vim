" vim: ft=vim fdm=indent:

" Job control, vim 8

if has('nvim')
	finish
endif

if ! exists('*appendbufline')
	echomsg 'You need appendbufline to handle jobs'
	finish
endif

" Buffer

fun! wheel#ripple#template ()
	" Job buffer template
	call wheel#mandala#template ()
	setlocal bufhidden=
	exe 'file ' . '/wheel/ripple/' . bufnr('%')
	let b:wheel_lines = []
endfun

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
	call wheel#chain#remove_element(self, g:wheel_ripple)
	echomsg text
endfun

let s:callbacks = {
			\ 'on_stdout' : function('s:Out'),
			\ 'on_stderr' : function('s:Err'),
			\ 'on_exit' : function('s:Exit')
			\}

" Main

fun! wheel#ripple#start (command, ...)
	" Start a new job
	if a:0 > 0
		let options = a:1
	else
		let options = {}
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
	if ! has_key(options, 'new_buffer') || options.new_buffer
		call wheel#mandala#open ('wheel-ripple')
	endif
	call wheel#ripple#template ()
	" Expand tilde in filenames
	call map(command, {_, val -> expand(val)})
	" Job
	let job = {}
	let job.name = fnamemodify(command[0], ':t:r')
	let job.bufnum = bufnr('%')
	let job.pty = v:true
	call extend(job, s:callbacks)
	call extend(job, options)
	let jobid = jobstart(command, job)
	if jobid < 0
		echomsg 'Wheel ripple start : failed to start' command[0]
		return
	endif
	let job.ident = jobid
	call add(g:wheel_ripple, job)
	return job
endfun

fun! wheel#ripple#send (job, text)
	" Send text to job
	let job = a:job
	let text = a:text
	return chansend(job.ident, text)
endfun

fun! wheel#ripple#stop (job)
	" Stop job
	let job = a:job
	call jobstop(job.ident)
	call wheel#chain#remove_element(job, g:wheel_ripple)
endfun
