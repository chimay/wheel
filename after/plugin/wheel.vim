" vim: set filetype=vim:

if exists("g:wheel_loaded_after")
	finish
endif

let g:wheel_loaded_after = 1

" In after directory, so that we can know the customized value of
" g:wheel_config.mappings level

call wheel#centre#cables ()
