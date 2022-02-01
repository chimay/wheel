" vim: set ft=vim fdm=indent iskeyword&:

" Wave
"
" Job control, neovim

if ! has('unix')
	echomsg 'wheel : wave is only supported on Unix systems'
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

" Mandala

fun! wheel#wave#template (mandala_type)
	" Job buffer template
	call wheel#mandala#template ()
	let b:wheel_nature.is_writable = v:true
	setlocal noreadonly
	setlocal modifiable
endfun

fun! wheel#wave#stop_map ()
	" Map to stop the job
	let map = 'nnoremap <silent> <buffer>'
	let callme = '<cmd>call wheel#wave#stop()<cr>'
	execute map '<c-s>' callme
endfun

" Main

fun! wheel#wave#start (command, ...)
	" Start a new job
	let command = a:command
	let kind = type(command)
	if kind == v:t_list
		let command = command
	elseif kind == v:t_string
		let command = split(command)
	else
		echomsg 'wheel wave start : bad command format'
		return
	endif
	if a:0 > 0
		let options = a:1
	else
		let options = {'mandala_type' : 'wave'}
	endif
	" mandala
	let mandala_type = options.mandala_type
	call wheel#mandala#blank (mandala_type)
	call wheel#mandala#fill('')
	call wheel#wave#template (mandala_type)
	" job
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
	eval g:wheel_wave->add(job)
	call wheel#wave#stop_map ()
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
			echomsg 'wheel wave stop : no more job left'
			return v:false
		endif
	endif
	call jobstop(job.iden)
	eval g:wheel_wave->wheel#chain#remove_element(job)
endfun
