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
	call s:check_jump()
	call s:check_toggle()
	call s:check_words()
	call s:check_correct()

	echo v:errors
endfunction


function! s:check_jump()
	" cursor pos reset "{{{
	call spelunker#test#open_unit_test_buffer('case9')
	call cursor(1,1)
	call s:assert_cursor_pos(1, 1)
	" }}}

	" spelunker#jump#jump_matched(1) "{{{
	call spelunker#jump#jump_matched(1)
	call s:assert_cursor_pos(2, 8)

	call spelunker#jump#jump_matched(1)
	call s:assert_cursor_pos(2, 13)

	call spelunker#jump#jump_matched(1)
	call s:assert_cursor_pos(3, 1)

	call spelunker#jump#jump_matched(1)
	call s:assert_cursor_pos(1, 1)
	" }}}

	" spelunker#jump#jump_matched(0) "{{{
	call spelunker#jump#jump_matched(0)
	call s:assert_cursor_pos(3, 1)

	call spelunker#jump#jump_matched(0)
	call s:assert_cursor_pos(2, 13)

	call spelunker#jump#jump_matched(0)
	call s:assert_cursor_pos(2, 8)

	call spelunker#jump#jump_matched(0)
	call s:assert_cursor_pos(1, 1)
	" }}}
endfunction

function! s:check_toggle()
	" [case10-0] =====================================
	call spelunker#test#open_unit_test_buffer('case10')
	call s:init()
	call spelunker#toggle#toggle()

	" spelunker#check_displayed_words spelunker#check "{{{
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
	call assert_equal(0, spelunker#check_displayed_words())

	let g:spelunker_check_type = g:spelunker_check_type_cursor_hold
	call assert_equal(0, spelunker#check())

	" call assert_equal(0, spelunker#check_and_echo_list())
	" }}}

	" spelunker#jump_next spelunker#jump_prev "{{{
	call cursor(1,1)
	call assert_equal(0, spelunker#jump_next())
	call s:assert_cursor_pos(1, 1)
	call assert_equal(0, spelunker#jump_prev())
	call s:assert_cursor_pos(1, 1)
	" }}}

	" "{{{
	call assert_equal(0, spelunker#add_all_spellgood())

	" register word dict test
	call assert_equal(0, spelunker#execute_with_target_word(''))
	" }}}

	" [case10-1] =====================================
	call spelunker#toggle#toggle()

	" spelunker#check_displayed_words spelunker#check "{{{
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
	call assert_equal(1, spelunker#check())

	let g:spelunker_check_type = g:spelunker_check_type_cursor_hold
	call assert_equal(1, spelunker#check_displayed_words())

	" call assert_equal(1, spelunker#check_and_echo_list())
	" }}}

	" spelunker#jump_next spelunker#jump_prev "{{{
	call cursor(1,1)
	call assert_equal(1, spelunker#jump_next())
	call s:assert_cursor_pos(2, 1)
	call assert_equal(1, spelunker#jump_prev())
	call s:assert_cursor_pos(1, 1)
	" }}}

	" spelunker#spellbad#get_spell_bad_list "{{{
	" call assert_equal(1, spelunker#add_all_spellgood())

	" register word dict test
	call spelunker#test#open_unit_test_buffer('case12')
	call s:init()
	call cursor(1,1)
	let l:line = spelunker#spellbad#get_spell_bad_list(1, -1)
	call assert_equal(['addgoodword'], l:line)

	call assert_equal(1, spelunker#execute_with_target_word('spellgood!'))
	let l:line = spelunker#spellbad#get_spell_bad_list(1, -1)
	call assert_equal([], l:line)

	call s:reload_buffer()
	call cursor(2,1)
	let l:line = spelunker#spellbad#get_spell_bad_list(2, -1)
	call assert_equal([], l:line)

	call assert_equal(1, spelunker#execute_with_target_word('spellwrong!'))
	let l:line = spelunker#spellbad#get_spell_bad_list(2, -1)
	call assert_equal(['wrong'], l:line)
	" }}}

	" [case11-0] =====================================
	call spelunker#toggle#toggle()

	" spelunker#correct "{{{
	call spelunker#test#open_unit_test_buffer('case11')
	call s:init()
	call cursor(1, 2)
	call assert_equal(0, spelunker#correct())
	call assert_equal(0, spelunker#correct_all())
	call assert_equal(0, spelunker#correct_from_list())
	call assert_equal(0, spelunker#correct_all_from_list())
	call assert_equal(0, spelunker#correct_feeling_lucky())
	call assert_equal(0, spelunker#correct_all_feeling_lucky())
	call assert_equal('aple', expand("<cword>"))
	" }}}

	" [case11-1] =====================================
	call spelunker#toggle#toggle()

	" spelunker#correct "{{{
	call s:reload_buffer()
	call s:init()
	call cursor(1, 2)
	" call assert_equal(0, spelunker#correct())
	" call assert_equal(0, spelunker#correct_all())
	" call assert_equal(0, spelunker#correct_from_list())
	" call assert_equal(0, spelunker#correct_all_from_list())
	call assert_equal(1, spelunker#correct_feeling_lucky())
	call assert_equal('apple', expand("<cword>"))

	call s:reload_buffer()
	call s:init()
	call cursor(1, 2)
	call assert_equal(1, spelunker#correct_all_feeling_lucky())
	call assert_equal('apple', expand("<cword>"))
	call cursor(3, 8)
	call assert_equal('apple', expand("<cword>"))
	call cursor(4, 1)
	call assert_equal('apple', expand("<cword>"))

	" 編集中の変更を破棄
	call s:reload_buffer()
	" }}}
endfunction

function! s:check_words()
	call spelunker#test#open_unit_test_buffer('case13')

	" spelunker#words#search_target_word "{{{
	call cursor(1, 1)
	call assert_equal('aple', spelunker#words#search_target_word())

	call cursor(1, 6)
	call assert_equal('banan', spelunker#words#search_target_word())

	call cursor(1, 10)
	call assert_equal('banan', spelunker#words#search_target_word())
	" }}}

	" spelunker#words#format_spell_suggest_list "{{{
	let l:result = spelunker#words#format_spell_suggest_list(['apple', 'banana', "It's", 'Pièces', 'a.b.c'], 'Apple')
	call assert_equal([['1: "Apple"', '2: "Banana"', '3: "A_b_c"'], ['Apple', 'Banana', 'A_b_c']], l:result)

	" #10 Documention -> Document Ion -> Documention
	" https://github.com/kamykn/spelunker.vim/issues/10
 	let b:camel_case_count = 100
	let l:result = spelunker#words#format_spell_suggest_list(['Document Ion'], 'Document Ion')
	call assert_equal([['1: "DocumentIon"'], ['DocumentIon']], l:result)
	" }}}

	" spelunker#words#cut_text_word_before "{{{
	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'banana')
	call assert_equal('orange', l:result)

	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'melon')
	call assert_equal('applebananaorange', l:result)
	" }}}

	" spelunker#words#replace_word "{{{
	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call cursor(4, 15)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))

	call s:reload_buffer()

	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 1)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(4, 6)

	call s:reload_buffer()

	" 単語の先頭
	call cursor(3, 1)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(3, 1)

	" 単語の最後
	call cursor(4, 11)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(4, 11)
	" }}}

	" spelunker#words#check " {{{
	call spelunker#test#open_unit_test_buffer('case14')
	call s:clear_matches()
	call spelunker#words#check()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 22},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 23},
		\ l:result[1])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!graape[a-z]@!\C', 'priority': 0, 'id': 24},
		\ l:result[2])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!lemone[a-z]@!\C', 'priority': 0, 'id': 25},
		\ l:result[3])

	call s:clear_matches()
	call spelunker#words#check_display_area()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 26},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 27},
		\ l:result[1])
	"}}}

	" spelunker#words#highlight " {{{
	call spelunker#test#open_unit_test_buffer('case15')
	call spelunker#words#highlight(['banana', 'apple', 'lemon', 'Banana', 'Apple', 'Lemon'])
	let l:result = getmatches()
	call assert_equal(
				\ [{'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 26}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 27}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banana[a-z]@!\C', 'priority': 0, 'id': 31}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!apple[a-z]@!\C', 'priority': 0, 'id': 32}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!lemon[a-z]@!\C', 'priority': 0, 'id': 33}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Banana[a-z]@!\C', 'priority': 0, 'id': 34}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Apple[a-z]@!\C', 'priority': 0, 'id': 35}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Lemon[a-z]@!\C', 'priority': 0, 'id': 36}],
				\ l:result)
	"}}}
endfunction

function! s:check_correct()
	call spelunker#test#open_unit_test_buffer('case16')

	" spelunker#correct#correct " {{{
	call cursor(1, 1)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(0)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	" correct all
	call s:reload_buffer()
	call cursor(1, 1)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('apple', expand("<cword>"))

	" cursor pos test
	call s:reload_buffer()
	call cursor(1, 3)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 3)

	" cursor pos test
	call s:reload_buffer()
	call cursor(1, 4)
	call test_feedinput("apple\<CR>")
	call spelunker#correct#correct(1)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 4)
	"}}}

	" spelunker#correct#correct_from_list " {{{
	call s:reload_buffer()
	call cursor(1, 1)
	call test_feedinput("1\<CR>")
	call spelunker#correct#correct_from_list(0, 0)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	call s:reload_buffer()
	call cursor(1, 1)
	call test_feedinput("2\<CR>")
	call spelunker#correct#correct_from_list(0, 0)
	call assert_equal('pale', expand("<cword>"))

	call s:reload_buffer()
	call cursor(1, 1)
	call test_feedinput("1\<CR>")
	call spelunker#correct#correct_from_list(0, 1)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('aple', expand("<cword>"))

	call s:reload_buffer()
	call cursor(1, 1)
	call spelunker#correct#correct_from_list(1, 1)
	call assert_equal('apple', expand("<cword>"))
	call s:assert_cursor_pos(1, 1)
	call cursor(2, 1)
	call assert_equal('apple', expand("<cword>"))
	" }}}

	call s:reload_buffer()
	call test_feedinput('')
endfunction

function! spelunker#test#open_unit_test_buffer(filename)
	execute ':edit! ' . escape(g:spelunker_plugin_path, ' ') . '/test/unit_test/' . a:filename . '.md'
endfunction

function! s:reload_buffer()
	execute ':edit! %'
endfunction

function! s:clear_matches()
	call clearmatches()
	let b:match_id_dict = {}
endfunction

function! s:assert_cursor_pos(lnum, col)
	let l:pos = getpos('.')
	call assert_equal(a:lnum, l:pos[1])
	call assert_equal(a:col, l:pos[2])
endfunction

function! s:init()
	call s:clear_matches()
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
