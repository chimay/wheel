" vim: ft=vim fdm=indent:

" Dict function {{{1

" Does not work'

fun! wheel#test#dictfun () dict
	echo self.name
endfun

let d = {'name' : 'joe'}

call d.wheel#test.dictfun ()

" }}}1
