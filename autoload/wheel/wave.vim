" vim: ft=vim fdm=indent:

" Job control

" Callback

fun! s:Out (chan, data, event) dict
	" Callback ou stdout event
	let bufnum = self.bufnum
	let data = join(a:data[:-2])
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
	call remove(g:wheel_wave, self.index)
endfun

let s:callbacks = {
			\ 'on_stdout' : function('s:Out'),
			\ 'on_stderr' : function('s:Err'),
			\ 'on_exit' : function('s:Exit')
			\}

" Main

fun! wheel#wave#new (command)
	" Template of a job
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
	let job.index = len(g:wheel_wave)
	let job.name = command[0]
	new
	let job.bufnum = bufnr('%')
	call extend(job, s:callbacks)
    let jobid = jobstart(command, job)
	let job.ident = jobid
	call add(g:wheel_wave, job)
endfun
