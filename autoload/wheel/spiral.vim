" vim: ft=vim fdm=indent:

" Golden mean

let s:golden = (1 + sqrt(5)) / 2
lockvar s:golden

fun! wheel#spiral#golden_view ()
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
		exe 'normal! ' . delta . ''
	elseif delta < 0
		exe 'normal! ' . -delta . ''
	endif
endfu
