" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#white_list#white_list_html#get_white_list()
	let l:wl = ['basefont', 'bdi', 'bdo', 'blockquote', 'br', 'colgroup', 'colspan', 'doctype', 'datalist', 'dfn', 'dir', 'dl', 'dt', 'fieldset', 'figcaption', 'frameset', 'lt', 'kbd', 'keygen', 'li', 'menuitem', 'noframes', 'noscript', 'ol', 'optgroup', 'rowspan', 'rp', 'samp', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'tt', 'ul', 'wbr', 'rb', 'rtc']
	return l:wl
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

