" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#white_list#white_list_sass#get_white_list()
	return spelunker#white_list#white_list_css#get_white_list()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

