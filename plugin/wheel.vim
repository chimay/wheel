" vim: set filetype=vim:
" Wheel - Vim Navigation Framework and Buffer Groups Manager

scriptencoding utf-8

if exists("g:wheel_loaded")
	finish
endif

let g:wheel_loaded = 1

call wheel#void#foundation ()
call wheel#centre#commands ()
call wheel#centre#plugs ()
call wheel#centre#cables ()
