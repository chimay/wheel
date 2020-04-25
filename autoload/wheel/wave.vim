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

fun! wheel#wave#open (...)
	" Open a wheel buffer
	if a:0 > 0
		let type = a:1
	else
		let type = 'wheel'
	endif
	new
	call wheel#wave#common_options (type)
endfun

fun! wheel#wave#close ()
	" Close the wheel buffer
	" Go to alternate buffer if only one window
	if winnr('$') > 1
		quit
	else
		buffer #
	endif
endfun

fun! wheel#wave#common_options (type)
	" Set local common options
	setlocal cursorline
	setlocal nobuflisted
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=
	file /wheel/wave
	let &filetype = a:type
endfun

fun! wheel#wave#common_maps ()
	" Define local common maps
	nnoremap <buffer> q :call wheel#wave#close()<cr>
	call wheel#mandala#filter_maps ()
	call wheel#mandala#input_history_maps ()
endfu

" Callback

fun! s:Out (chan, data, event) dict
	" Callback ou stdout event
	let bufnum = self.bufnum
	let data = join(a:data[:-2])
	let data = substitute(data, "\<c-m>", ' ', '')
	let text = printf('%s %s : %s', self.name, a:event, data)
	let last = line('$')
	call appendbufline(bufnum, last, text)
endfun

fun! s:Err (chan, data, event) dict
	" Callback ou stderr event
	let bufnum = self.bufnum
	let data = join(a:data[:-2])
	let text = printf('%s %s : %s', self.name, a:event, data)
	let last = line('$')
	call appendbufline(bufnum, last, text)
endfun

fun! s:Exit (chan, data, event) dict
	" Callback ou exit event
	let bufnum = self.bufnum
	let text = printf('%s %s : %s', self.name, a:event, '...')
	let last = line('$')
	call appendbufline(bufnum, last, text)
	call wheel#chain#remove_element(self, g:wheel_wave)
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
	call map(command, {_,val->expand(val)})
	let job = {}
	let job.name = fnamemodify(command[0], ':t:r')
	call wheel#wave#open ('wheel-wave')
	call wheel#wave#common_maps ()
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
