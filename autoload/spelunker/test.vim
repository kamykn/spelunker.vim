" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0
" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#check()
	let v:errors = []

	call spelunker#test#test_utils#test()
	call spelunker#test#test_cases#test()
	call spelunker#test#test_spellbad#test()
	call spelunker#test#test_white_list#test()
	call spelunker#test#test_match#test()
	call spelunker#test#test_jump#test()
	call spelunker#test#test_toggle#test()
	call spelunker#test#test_words#test()
	call spelunker#test#test_correct#test()

	echo v:errors
endfunction

function! spelunker#test#open_unit_test_buffer(filename)
	execute ':edit! ' . escape(g:spelunker_plugin_path, ' ') . '/test/unit_test/' . a:filename . '.md'
endfunction

function! spelunker#test#reload_buffer()
	execute ':edit! %'
endfunction

function! spelunker#test#assert_cursor_pos(lnum, col)
	let l:pos = getpos('.')
	call assert_equal(a:lnum, l:pos[1])
	call assert_equal(a:col, l:pos[2])
endfunction

function! spelunker#test#init()
	call spelunker#test#clear_matches()
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
endfunction

function! spelunker#test#clear_matches()
	call clearmatches()
	let b:match_id_dict = {}
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
