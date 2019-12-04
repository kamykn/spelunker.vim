" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_correct#test()
	call s:test_correct()
	call s:test_correct_from_list()
endfunction

function! s:test_correct()
	call spelunker#test#open_unit_test_buffer('correct', 'correct.txt')

	" spelunker#correct#correct
	call cursor(1, 1)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(0)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	" correct all
	call spelunker#test#reload_buffer()
	call cursor(1, 1)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('apple', expand("<cword>"))

	" cursor pos test
	call spelunker#test#reload_buffer()
	call cursor(1, 3)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 3)

	" cursor pos test
	call spelunker#test#reload_buffer()
	call cursor(1, 4)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 4)
endfunction

function! s:test_correct_from_list()
	call spelunker#test#open_unit_test_buffer('correct', 'correct.txt')
	call spelunker#test#reload_buffer()

	" [test for popup_menu] ======================================
	" popup_menu()のcallback形式のユニットテストが書けない...
	" コールバックよりも先にassertが実行されてしまう

	" [test for inputlist] ======================================
	let g:enable_inputlist_for_test = 1

	call cursor(1, 1)
	call test_feedinput("1\<CR>")
	call spelunker#correct#correct_from_list(0, 0)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	call spelunker#test#reload_buffer()
	call cursor(1, 1)
	call test_feedinput("2\<CR>")
	call spelunker#correct#correct_from_list(0, 0)
	call assert_equal('pale', expand("<cword>"))

	call spelunker#test#reload_buffer()
	call cursor(1, 1)
	call test_feedinput("1\<CR>")
	call spelunker#correct#correct_from_list(0, 1)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	call spelunker#test#reload_buffer()
	call cursor(1, 1)
	call spelunker#correct#correct_from_list(1, 1)
	call assert_equal('apple', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('apple', expand("<cword>"))

	call spelunker#test#reload_buffer()
	call test_feedinput('')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
