" vim: set ft=vim fdm=indent iskeyword&:

" Signs at locations

" other names :
"
" caduceus

" script constants

if ! exists('s:sign_name')
	let s:sign_name = wheel#crystal#fetch('sign/name')
	lockvar s:sign_name
endif

if ! exists('s:sign_group')
	let s:sign_group = wheel#crystal#fetch('sign/group')
	lockvar s:sign_group
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" functions

fun! wheel#chakra#define ()
	" Define wheel sign
	let signs = g:wheel_signs
	let name = s:sign_name
	let settings = g:wheel_config.display.sign.settings
	" first definition
	if empty(signs.iden)
		call sign_define(name, settings)
		return v:true
	endif
	" change of settings in g:wheel_config
	let defined = sign_getdefined()
	let wheel_sign = defined->filter({ _, val -> val.name == name })[0]
	let text = wheel_sign.text
	if settings.text != text
		call sign_undefine(name)
		call sign_define(name, settings)
	endif
	return v:true
endfun

fun! wheel#chakra#unplace ()
	" Unplace old sign at current location
	let signs = g:wheel_signs
	let iden = signs.iden
	" torus > circle > location -> iden
	let table = signs.table
	let coordin = wheel#referen#names ()
	let chord = join(coordin, s:level_separ)
	if ! has_key(table, chord)
		return v:true
	endif
	let group = s:sign_group
	let old_iden = table[chord]
	let dict = #{ id : old_iden }
	call sign_unplace(group, dict)
	eval iden->wheel#chain#remove_element(old_iden)
	unlet table[chord]
	return old_iden
endfun

fun! wheel#chakra#place ()
	" Place sign at current location
	let signs = g:wheel_signs
	let iden = signs.iden
	" torus > circle > location -> iden
	let table = signs.table
	let new_iden = wheel#chain#lowest_outside (iden, 1)
	let group = s:sign_group
	let name = s:sign_name
	let location = wheel#referen#location ()
	let file = location.file
	let linum = location.line
	let dict = #{ lnum : linum }
	call sign_place(new_iden, group, name, file, dict)
	let coordin = wheel#referen#names ()
	let chord = join(coordin, s:level_separ)
	eval iden->add(new_iden)
	let table[chord] = new_iden
	return new_iden
endfun

fun! wheel#chakra#update ()
	" Add or update sign at location
	let signs = g:wheel_signs
	call wheel#chakra#define ()
	call wheel#chakra#unplace ()
	call wheel#chakra#place ()
endfun
