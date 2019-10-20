" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_words#test()
	call s:test_search_target_word()
	call s:test_format_spell_suggest_list()
	call s:test_cut_text_word_before()
	call s:test_replace_word()
	call s:test_check()
	call s:test_check_display_area()
	call s:test_highlight()
endfunction

function! s:test_search_target_word()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#search_target_word
	call cursor(1, 1)
	call assert_equal('aple', spelunker#words#search_target_word())

	call cursor(1, 6)
	call assert_equal('banan', spelunker#words#search_target_word())

	call cursor(1, 10)
	call assert_equal('banan', spelunker#words#search_target_word())
endfunction

function! s:test_format_spell_suggest_list()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#format_spell_suggest_list
	let l:result = spelunker#words#format_spell_suggest_list(['apple', 'banana', "It's", 'Pièces', 'a.b.c'], 'Apple')
	call assert_equal([['1: "Apple"', '2: "Banana"', '3: "A_b_c"'], ['Apple', 'Banana', 'A_b_c']], l:result)

	" #10 Documention -> Document Ion -> Documention
	" https://github.com/kamykn/spelunker.vim/issues/10
 	let b:camel_case_count = 100
	let l:result = spelunker#words#format_spell_suggest_list(['Document Ion'], 'Document Ion')
	call assert_equal([['1: "DocumentIon"'], ['DocumentIon']], l:result)
endfunction

function! s:test_cut_text_word_before()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#cut_text_word_before
	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'banana')
	call assert_equal('orange', l:result)

	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'melon')
	call assert_equal('applebananaorange', l:result)
endfunction

function! s:test_replace_word()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#replace_word
	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call cursor(4, 15)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))

	call spelunker#test#reload_buffer()

	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 1)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(4, 6)

	call spelunker#test#reload_buffer()

	" 単語の先頭
	call cursor(3, 1)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 1)

	" 単語の最後
	call cursor(4, 11)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(4, 11)
endfunction

function! s:test_check()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call spelunker#test#clear_matches()

	call spelunker#words#check()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 23},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 24},
		\ l:result[1])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!graape[a-z]@!\C', 'priority': 0, 'id': 25},
		\ l:result[2])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!lemone[a-z]@!\C', 'priority': 0, 'id': 26},
		\ l:result[3])
endfunction

function! s:test_check_display_area()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call spelunker#test#clear_matches()

	call spelunker#words#check_display_area()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 27},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 28},
		\ l:result[1])
endfunction

function! s:test_highlight()
	call spelunker#test#open_unit_test_buffer('words', 'highlight.txt')

	call spelunker#words#highlight(['banana', 'apple', 'lemon', 'Banana', 'Apple', 'Lemon'])
	let l:result = getmatches()
	call assert_equal(
		\ [{'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 27}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 28}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banana[a-z]@!\C', 'priority': 0, 'id': 32}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!apple[a-z]@!\C', 'priority': 0, 'id': 33}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!lemon[a-z]@!\C', 'priority': 0, 'id': 34}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Banana[a-z]@!\C', 'priority': 0, 'id': 35}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Apple[a-z]@!\C', 'priority': 0, 'id': 36}, {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Z]@<!Lemon[a-z]@!\C', 'priority': 0, 'id': 37}],
		\ l:result)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
