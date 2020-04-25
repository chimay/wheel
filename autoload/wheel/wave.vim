" vim: ft=vim fdm=indent:

" Job control, neovim

if ! has('nvim')
	finish
endif

if ! exists('*appendbufline')
	echomsg 'You need appendbufline to handle jobs'
	finish
endif

" Buffer

fun! wheel#wave#template ()
	" Job buffer template
	call wheel#mandala#template ()
	setlocal bufhidden=
	exe 'file ' . '/wheel/wave/' . bufnr('%')
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
	let last = line('$')
	call appendbufline(bufnum, last, text)
	call wheel#chain#remove_element(self, g:wheel_wave)
	call add(b:wheel_lines, text)
endfun

let s:callbacks = {
			\ 'on_stdout' : function('s:Out'),
			\ 'on_stderr' : function('s:Err'),
			\ 'on_exit' : function('s:Exit')
			\}

" Main

fun! wheel#wave#start (command, ...)
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
		echomsg 'Wheel wave new : bad command format'
		return
	endif
	" Buffer
	call wheel#mandala#open ('wheel-wave')
	call wheel#wave#template ()
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
		echomsg 'Wheel wave start : failed to start' command[0]
		return
	endif
	let job.ident = jobid
	call add(g:wheel_wave, job)
	return job
endfun

fun! wheel#wave#send (job, text)
	" Send text to job
	let job = a:job
	let text = a:text
	return chansend(job.ident, text)
endfun

fun! wheel#wave#stop (job)
	" Stop job
	let job = a:job
	call jobstop(job.ident)
	call wheel#chain#remove_element(job, g:wheel_wave)
endfun
