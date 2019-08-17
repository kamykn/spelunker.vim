" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#white_list#white_list_css#get_white_list()
	let l:wl = ['accesskey', 'backface', 'bezier', 'cmyk', 'dir', 'dpcm', 'dppx', 'focusring', 'asian', 'fullscreen', 'gd', 'horiz', 'hsl', 'hsla', 'hz', 'rect', 'keyframes', 'lwtheme', 'darktext', 'maemo', 'blockquote', 'columnline', 'firstcolumn', 'firstrow', 'lastcolumn', 'rowline', 'lastrow', 'minmax', 'mso', 'navbutton', 'nbsp', 'oeb', 'bottomleft', 'bottomright', 'topleft', 'topright', 'pagebreak', 'pagecontent', 'panose', 'px', 'rgb', 'rgba', 'rounddown', 'rtl', 'dlight', 'darkshadow', 'dasharray', 'dashoffset', 'linecap', 'linejoin', 'miterlimit', 'autospace', 'kashida', 'callout', 'progressmeter', 'ui', 'bidi', 'vh', 'vmax', 'vmin', 'vw', 'xul', 'nowrap', 'overline', 'moz']

	let l:wl += ['mixin', 'clearfix', 'flexbox']
	return l:wl
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
