" vim: set ft=vim fdm=indent iskeyword&:

" Chakra
"
" Signs at locations

" ---- script constants

if ! exists('s:sign_name')
	let s:sign_name = wheel#crystal#fetch('sign/name')
	lockvar s:sign_name
endif

if ! exists('s:sign_native_name')
	let s:sign_native_name = wheel#crystal#fetch('sign/name/native')
	lockvar s:sign_native_name
endif

if ! exists('s:sign_group')
	let s:sign_group = wheel#crystal#fetch('sign/group')
	lockvar s:sign_group
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" ---- booleans

fun! wheel#chakra#same_location ()
	" Whether current location is the same as when the sign has been placed
	let signs = g:wheel_signs
	let subtable = deepcopy(signs.table)
	let coordin = wheel#referen#coordinates ()
	eval subtable->filter({ _, val -> val.coordin == coordin })
	if empty(subtable)
		return v:false
	endif
	let entry = subtable[0]
	let location = wheel#referen#location ()
	return entry.line == location.line
endfun

fun wheel#chakra#same_place (one, two)
	" Whether one & two represent the same buffer & cursor position
	let one = a:one
	let two = a:two
	let same_buffer = one.buffer == two.buffer
	let same_line = one.line == two.line
	return same_buffer && same_line
endfun

" ---- helpers

fun! wheel#chakra#format_text (settings)
	" Format text in settings
	let settings = a:settings
	let text = settings.text
	if empty(text)
		let settings.text = wheel#crystal#fetch('sign/text')
	endif
	let length = strchars(text)
	if length == 1
		let settings.text ..= ' '
	elseif length > 2
		let settings.text = strcharpart(text, 0, 2)
	endif
	return settings
endfun

fun! wheel#chakra#format ()
	" Format sign text to ensure it contains 2 chars
	" sign text must be 2 chars or a space will be added by vim
	let settings = g:wheel_config.display.sign.settings
	call wheel#chakra#format_text (settings)
	let native_settings = g:wheel_config.display.sign.native_settings
	call wheel#chakra#format_text (native_settings)
	return [settings, native_settings]
endfun

fun! wheel#chakra#define_sign (name, settings)
	" Define sign from name & settings
	let name = a:name
	let settings = a:settings
	let defined = sign_getdefined()
	let subdef = defined->filter({ _, val -> val.name == name })
	" -- first definition
	if empty(subdef)
		call wheel#chakra#format ()
		" define
		call sign_define(name, settings)
		return v:true
	endif
	" -- change of settings in g:wheel_config
	let current_sign = subdef[0]
	if settings.text == current_sign.text
		return v:true
	endif
	call wheel#chakra#format ()
	call sign_undefine(name)
	call sign_define(name, settings)
	call wheel#chakra#replace_all ()
	return v:true
endfun

" ---- location & native signs

fun! wheel#chakra#define ()
	" Define wheel sign
	" ---- location sign
	let name = s:sign_name
	let settings = g:wheel_config.display.sign.settings
	call wheel#chakra#define_sign (name, settings)
	" ---- native sign
	let native_name = s:sign_native_name
	let native_settings = g:wheel_config.display.sign.native_settings
	call wheel#chakra#define_sign (native_name, native_settings)
endfun

" ---- location signs

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
	let bufnum = bufnr(file)
	let linum = location.line
	let dict = #{ lnum : linum }
	let coordin = wheel#referen#coordinates ()
	let entry = #{
				\ iden : new_iden,
				\ coordin : coordin,
				\ buffer : bufnum,
				\ line : linum
				\ }
	call sign_place(new_iden, group, name, bufnum, dict)
	eval iden->add(new_iden)
	eval table->filter({ _, val -> val.coordin != coordin })
	eval table->add(entry)
	return new_iden
endfun

fun! wheel#chakra#replace_all ()
	" Replace all signs to adapt to new settings
	let signs = g:wheel_signs
	let group = s:sign_group
	let name = s:sign_name
	let table = signs.table
	for flag in signs.iden
		let subtable = deepcopy(table)
		eval subtable->filter({ _, val -> val.iden == flag })
		if empty(subtable)
			echomsg 'wheel chakra replace all : no entry found for' flag 'iden'
			return v:false
		endif
		let entry = subtable[0]
		let bufnum = entry.buffer
		let linum = entry.line
		let unplace = #{ id : flag }
		let place = #{ lnum : linum }
		call sign_unplace(group, unplace)
		call sign_place(flag, group, name, bufnum, place)
	endfor
endfun

fun! wheel#chakra#unplace ()
	" Unplace old sign at current location
	let signs = g:wheel_signs
	let iden = signs.iden
	let subtable = deepcopy(signs.table)
	let coordin = wheel#referen#coordinates ()
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
	let signs = g:wheel_signs
	if empty(signs.iden)
		return v:false
	endif
	" clear wheel var
	let signs.iden = []
	let signs.table = []
	" unplace
	let group = s:sign_group
	call sign_unplace(group)
endfun

fun! wheel#chakra#update ()
	" Add or update sign at location
	let display_sign = g:wheel_config.display.sign.switch
	if ! display_sign
		call wheel#chakra#clear ()
		return v:false
	endif
	call wheel#chakra#define ()
	if wheel#chakra#same_location ()
		return v:true
	endif
	call wheel#chakra#unplace ()
	call wheel#chakra#place ()
	return v:true
endfun

" ---- native signs

fun! wheel#chakra#place_native ()
	" Place sign for native navigation
	let signs = g:wheel_signs
	let iden = signs.native_iden
	let table = signs.native_table
	let new_iden = wheel#chain#lowest_outside (iden, 1)
	let group = s:sign_group
	let name = s:sign_native_name
	let bufnum = bufnr('%')
	let linum = line('.')
	let dict = #{ lnum : linum }
	let entry = #{
				\ iden : new_iden,
				\ buffer : bufnum,
				\ line : linum
				\ }
	echomsg new_iden group name bufnum dict
	call sign_place(new_iden, group, name, bufnum, dict)
	eval iden->add(new_iden)
	eval table->filter({ _, val -> ! wheel#chakra#same_place(val, entry) })
	eval table->add(entry)
	return new_iden
endfun
