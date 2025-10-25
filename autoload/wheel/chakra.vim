" vim: set ft=vim fdm=indent iskeyword&:

" Chakra
"
" Signs at locations

" ---- script constants

if exists('s:sign_name')
	unlockvar s:sign_name
endif
let s:sign_name = wheel#crystal#fetch('sign/name')
lockvar s:sign_name

if exists('s:sign_native_name')
	unlockvar s:sign_native_name
endif
let s:sign_native_name = wheel#crystal#fetch('sign/name/native')
lockvar s:sign_native_name

if exists('s:sign_group')
	unlockvar s:sign_group
endif
let s:sign_group = wheel#crystal#fetch('sign/group')
lockvar s:sign_group

if exists('s:sign_native_group')
	unlockvar s:sign_native_group
endif
let s:sign_native_group = wheel#crystal#fetch('sign/group/native')
lockvar s:sign_native_group

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = wheel#crystal#fetch('separator/level')
lockvar s:level_separ

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

fun wheel#chakra#same_buffer (one, two)
	" Whether one & two represent the same buffer & cursor position
	let one = a:one
	let two = a:two
	let same_buffer = one.buffer == two.buffer
	return same_buffer
endfun

fun wheel#chakra#same_place (one, two)
	" Whether one & two represent the same buffer & cursor position
	let one = a:one
	let two = a:two
	let same_buffer = one.buffer == two.buffer
	let same_line = one.line == two.line
	return same_buffer && same_line
endfun

fun! wheel#chakra#location_sign_is_here ()
	" Whether a location sign is at current line
	let signs = g:wheel_signs
	let bufnum = bufnr('%')
	let linum = line('.')
	let place = #{
				\ buffer : bufnum,
				\ line : linum
				\ }
	let location_table = deepcopy(signs.table)
	eval location_table->filter({ _, val -> wheel#chakra#same_place (val, place) })
	return ! empty(location_table)
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

fun! wheel#chakra#define_sign (name, settings)
	" Define sign from name & settings
	let name = a:name
	let settings = a:settings
	let defined = sign_getdefined()
	let subdef = defined->filter({ _, val -> val.name == name })
	" -- first definition
	if empty(subdef)
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
	return v:true
endfun

" ---- location signs

fun! wheel#chakra#place_location ()
	" Place sign at current location
	let signs = g:wheel_signs
	" ---- fields
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
	" ---- table
	let entry = #{
				\ iden : new_iden,
				\ coordin : coordin,
				\ buffer : bufnum,
				\ line : linum
				\ }
	call sign_place(new_iden, group, name, bufnum, dict)
	eval table->filter({ _, val -> val.coordin != coordin })
	eval table->add(entry)
	" ---- iden list
	let round_table = deepcopy(table)
	let signs.iden = round_table->map({ _, val -> val.iden })
	" ---- coda
	return new_iden
endfun

fun! wheel#chakra#replace_all_locations ()
	" Replace all locations signs to adapt to new settings
	let signs = g:wheel_signs
	let group = s:sign_group
	let name = s:sign_name
	let table = signs.table
	for flag in signs.iden
		let subtable = deepcopy(table)
		eval subtable->filter({ _, val -> val.iden == flag })
		if empty(subtable)
			echomsg 'wheel chakra replace all locations : no entry found for' flag 'iden'
			return v:false
		endif
		let entry = subtable[0]
		let bufnum = entry.buffer
		if ! bufexists(bufnum)
			eval table->filter({ _, val -> val.buffer != bufnum })
			let round_table = deepcopy(table)
			let signs.iden = round_table->map({ _, val -> val.iden })
			continue
		endif
		let linum = entry.line
		let unplace = #{ id : flag }
		let place = #{ lnum : linum }
		call sign_unplace(group, unplace)
		call sign_place(flag, group, name, bufnum, place)
	endfor
endfun

fun! wheel#chakra#unplace_location ()
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

fun! wheel#chakra#clear_locations ()
	" Unplace all locations signs
	let signs = g:wheel_signs
	if empty(signs.iden)
		return v:false
	endif
	" ---- clear wheel var
	let signs.iden = []
	let signs.table = []
	" ---- unplace
	let group = s:sign_group
	call sign_unplace(group)
endfun

fun! wheel#chakra#update_locations ()
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
	call wheel#chakra#unplace_location ()
	call wheel#chakra#unplace_native_at_location ()
	call wheel#chakra#place_location ()
	return v:true
endfun

" ---- native signs

fun! wheel#chakra#unplace_native_in_buffer (bufnum)
	" Unplace native signs in buffer bufnum
	let bufnum = a:bufnum
	let group = s:sign_native_group
	let buffer_dict = #{ buffer : bufnum }
	call sign_unplace(group, buffer_dict)
endfun

fun! wheel#chakra#replace_all_native ()
	" Replace all native signs to adapt to new settings
	let signs = g:wheel_signs
	let group = s:sign_native_group
	let name = s:sign_native_name
	let table = signs.native_table
	for flag in signs.native_iden
		let subtable = deepcopy(table)
		eval subtable->filter({ _, val -> val.iden == flag })
		if empty(subtable)
			echomsg 'wheel chakra replace all native : no entry found for' flag 'iden'
			return v:false
		endif
		let entry = subtable[0]
		let bufnum = entry.buffer
		if ! bufexists(bufnum)
			eval table->filter({ _, val -> val.buffer != bufnum })
			let round_table = deepcopy(table)
			let signs.native_iden = round_table->map({ _, val -> val.iden })
			continue
		endif
		let linum = entry.line
		let unplace = #{ id : flag }
		let place = #{ lnum : linum }
		call sign_unplace(group, unplace)
		call sign_place(flag, group, name, bufnum, place)
	endfor
endfun

fun! wheel#chakra#clear_native ()
	" Unplace all native signs
	let signs = g:wheel_signs
	if empty(signs.native_iden)
		return v:false
	endif
	" ---- clear wheel var
	let signs.native_iden = []
	let signs.native_table = []
	" ---- unplace
	let native_group = s:sign_native_group
	call sign_unplace(native_group)
endfun

fun! wheel#chakra#place_native ()
	" Place sign for native navigation
	let display_sign = g:wheel_config.display.sign.switch
	if ! display_sign
		return -1
	endif
	call wheel#chakra#define ()
	let signs = g:wheel_signs
	" ---- fields
	let iden = signs.native_iden
	let table = signs.native_table
	let new_iden = wheel#chain#lowest_outside (iden, 1)
	let group = s:sign_native_group
	let name = s:sign_native_name
	let bufnum = bufnr('%')
	let linum = line('.')
	" ---- any location sign at the same place ?
	if wheel#chakra#location_sign_is_here ()
		return -1
	endif
	" ---- remove other signs in same buffer
	call wheel#chakra#unplace_native_in_buffer (bufnum)
	" ---- table
	let entry = #{
				\ iden : new_iden,
				\ buffer : bufnum,
				\ line : linum
				\ }
	let line_dict = #{ lnum : linum }
	call sign_place(new_iden, group, name, bufnum, line_dict)
	eval iden->add(new_iden)
	eval table->filter({ _, val -> ! wheel#chakra#same_buffer(val, entry) })
	eval table->add(entry)
	" ---- iden list
	let round_table = deepcopy(table)
	let signs.native_iden = round_table->map({ _, val -> val.iden })
	return new_iden
endfun

" ---- location & native signs

fun! wheel#chakra#format ()
	" Format sign text to ensure it contains 2 chars
	" sign text must be 2 chars or a space will be added by vim
	let settings = g:wheel_config.display.sign.settings
	call wheel#chakra#format_text (settings)
	let native_settings = g:wheel_config.display.sign.native_settings
	call wheel#chakra#format_text (native_settings)
	return [settings, native_settings]
endfun

fun! wheel#chakra#define ()
	" Define wheel and native sign
	" ---- format text
	call wheel#chakra#format ()
	" ---- location sign
	let name = s:sign_name
	let settings = g:wheel_config.display.sign.settings
	call wheel#chakra#define_sign (name, settings)
	call wheel#chakra#replace_all_locations ()
	" ---- native sign
	let native_name = s:sign_native_name
	let native_settings = g:wheel_config.display.sign.native_settings
	call wheel#chakra#define_sign (native_name, native_settings)
	call wheel#chakra#replace_all_native ()
endfun

fun! wheel#chakra#unplace_native_at_location ()
	" Unplace native sign at current location
	let signs = g:wheel_signs
	let iden = signs.native_iden
	let subtable = deepcopy(signs.native_table)
	" ---- fields
	let location = wheel#referen#location ()
	let bufnum = bufnr(location.file)
	let linum = location.line
	" ---- subtable
	let place = #{
				\ buffer : bufnum,
				\ line : linum
				\ }
	eval subtable->filter({ _, val -> wheel#chakra#same_place (val, place) })
	if empty(subtable)
		return v:true
	endif
	" ---- unplace
	let group = s:sign_native_group
	let entry = subtable[0]
	let old_iden = entry.iden
	let dict = #{ id : old_iden }
	call sign_unplace(group, dict)
	eval iden->wheel#chain#remove_element(old_iden)
	eval g:wheel_signs.native_table->filter({ _, val -> val.iden != old_iden })
	return old_iden
endfun

fun! wheel#chakra#clear ()
	" Clear all signs
	call wheel#chakra#clear_locations ()
	call wheel#chakra#clear_native ()
endfun
