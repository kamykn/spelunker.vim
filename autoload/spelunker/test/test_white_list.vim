" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_white_list#test()
	call s:test_init_white_list()
	call s:test_is_complex_or_compound_word()
endfunction

function! s:test_init_white_list()
	try
		unlet g:spelunker_white_list
	catch
		" エラー読み捨て
	endtry

	call spelunker#white_list#init_white_list()

	call assert_equal(1, exists('g:spelunker_white_list'))
	call assert_notequal(0, len(g:spelunker_white_list))
endfunction

function! s:test_is_complex_or_compound_word()
	call assert_equal(0, spelunker#white_list#is_complex_or_compound_word('build'))

	" prefix
	call assert_equal(1, spelunker#white_list#is_complex_or_compound_word('rebuild'))

	" suffix
	call assert_equal(1, spelunker#white_list#is_complex_or_compound_word('nullable'))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
