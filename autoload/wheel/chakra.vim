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

" helpers

fun! wheel#chakra#same ()
	" Whether current location is the same as when the sign has been placed
	let signs = g:wheel_signs
	let subtable = deepcopy(signs.table)
	let coordin = wheel#referen#names ()
	eval subtable->filter({ _, val -> val.coordin == coordin })
	if empty(subtable)
		return v:false
	endif
	let entry = subtable[0]
	let location = wheel#referen#location ()
	return entry.line == location.line
endfun

" functions

fun! wheel#chakra#define ()
	" Define wheel sign
	let signs = g:wheel_signs
	let name = s:sign_name
	let settings = g:wheel_config.display.sign.settings
	" -- first definition
	if empty(signs.iden)
		call sign_define(name, settings)
		return v:true
	endif
	" -- change of settings in g:wheel_config
	let defined = sign_getdefined()
	let subdef = defined->filter({ _, val -> val.name == name })
	if empty(subdef)
		echomsg 'wheel : sign define : empty definition'
	endif
	let wheel_sign = subdef[0]
	let text = wheel_sign.text
	if settings.text != text
		call sign_undefine(name)
		call sign_define(name, settings)
	endif
	return v:true
endfun

fun! wheel#chakra#place ()
	" Place sign at current location
	let signs = g:wheel_signs
	let iden = signs.iden
	let table = signs.table
	let new_iden = wheel#chain#lowest_outside (iden, 1)
	let group = s:sign_group
	let name = s:sign_name
	let location = wheel#referen#location ()
	let file = location.file
	let bufnum = bufnr('%')
	let linum = location.line
	let dict = #{ lnum : linum }
	let coordin = wheel#referen#names ()
	let entry = #{ iden : new_iden, coordin : coordin, buffer : bufnum, line : linum }
	call sign_place(new_iden, group, name, bufnum, dict)
	eval iden->add(new_iden)
	eval table->filter({ _, val -> val.coordin != coordin })
	eval table->add(entry)
	return new_iden
endfun

fun! wheel#chakra#unplace ()
	" Unplace old sign at current location
	let signs = g:wheel_signs
	let iden = signs.iden
	let subtable = deepcopy(signs.table)
	let coordin = wheel#referen#names ()
	eval subtable->filter({ _, val -> val.coordin == coordin })
	if empty(subtable)
		return v:true
	endif
	let group = s:sign_group
	let entry = subtable[0]
	let old_iden = entry.iden
	let dict = #{ id : old_iden }
	call sign_unplace(group, dict)
	eval iden->wheel#chain#remove_element(old_iden)
	eval g:wheel_signs.table->filter({ _, val -> val.iden != old_iden })
	return old_iden
endfun

fun! wheel#chakra#clear ()
	" Unplace all wheel signs
	let group = s:sign_group
	call sign_unplace(group)
	call wheel#void#signs ()
endfun

" update sign

fun! wheel#chakra#update ()
	" Add or update sign at location
	let display_sign = g:wheel_config.display.sign.switch
	if ! display_sign
		call wheel#chakra#clear ()
		return v:false
	endif
	let location = wheel#referen#location ()
	"if wheel#chakra#same ()
		"return v:true
	"endif
	call wheel#chakra#define ()
	call wheel#chakra#unplace ()
	call wheel#chakra#place ()
	return v:true
endfun
