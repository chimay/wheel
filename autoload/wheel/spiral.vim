" vim: ft=vim fdm=indent:

" Golden mean, ratio

if ! exists('s:golden')
	let s:golden = (1 + sqrt(5)) / 2
	lockvar s:golden
endif

fun! wheel#spiral#height ()
	" Window height / (1 + golden ratio)
	" If you open a horizontal split window with this height,
	" the ratio old window / new window height will be s:golden
	return winheight(0) / (1 + s:golden)
endfun

fun! wheel#spiral#width ()
	" Window width / (1 + golden ratio)
	" If you open a vertical split window with this width,
	" the ratio old window / new window width will be s:golden
	return winwidth(0) / (1 + s:golden)
endfun

fun! wheel#spiral#cursor ()
	" Position cursor so that
	" 1.618 x (top - cursor) = cursor - bottom
	" 2.618 x cursor = bottom + 1.618 x top
	" cursor = (1.618 x top + bottom) / 2.618
	let top2cursor = winline() - 1
	let top2bottom = winheight(0)
	let cursor2bottom = top2bottom - top2cursor
	let here = line('.')
	let top = here - top2cursor
	let bottom = here + cursor2bottom
	let target = (s:golden * top + bottom) / (1 + s:golden)
	let target = float2nr(round(target))
	let delta = target - here
	if delta > 0
		exe 'normal! ' . delta . "\<c-y>"
	elseif delta < 0
		exe 'normal! ' . -delta . "\<c-e>"
	endif
endfu
