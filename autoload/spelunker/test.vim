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

	call s:check_utils()
	call s:check_cases()
	call s:check_white_list()
	call s:check_spellbad()
	call s:check_jump()
	call s:check_toggle()

	" 最後にhighlight系のチェックをする
	call s:check_match()

	" not yet
	call s:check_words()
	call s:check_correct()

	echo v:errors
endfunction

function! s:check_utils()
	" spelunker#utils#filter_list_char_length"{{{ 
	let l:word_list = ['a', 'ab', 'abc', 'abcd', 'abcde']

	" デフォルト設定
	let l:result = spelunker#utils#filter_list_char_length(l:word_list)
	call assert_equal(2, len(l:result))

	" 設定変更が反映されるか
	let l:default_setting = g:spelunker_target_min_char_len
	let g:spelunker_target_min_char_len = 2
	let l:result = spelunker#utils#filter_list_char_length(l:word_list)
	call assert_equal(4, len(l:result))

	" 設定戻し
	let g:spelunker_target_min_char_len = l:default_setting
	" }}}

	" spelunker#utils#code_to_words"{{{ 
	call assert_equal(['abcde'], spelunker#utils#code_to_words('abcde'))
	call assert_equal(['a', 'b', 'cde'], spelunker#utils#code_to_words('a b cde'))
	call assert_equal(['ab', 'Cd', 'E'], spelunker#utils#code_to_words('abCdE'))
	call assert_equal(['ab', 'cd', 'e'], spelunker#utils#code_to_words('_ab_cd_e'))
	call assert_equal(['Ab', 'Cd', 'E'], spelunker#utils#code_to_words('AbCdE'))

	" 過去に不具合があった系
	call assert_equal(['AB', 'Cdef'], spelunker#utils#code_to_words('ABCdef'))
	call assert_equal(['abc', 'API'], spelunker#utils#code_to_words('abcAPI'))
	call assert_equal(['AB', 'CD'], spelunker#utils#code_to_words('AB__CD'))

	" # ISSUE/PR
	" #6 https://github.com/kamykn/spelunker.vim/pull/6
	call assert_equal(['this', 'T'], spelunker#utils#code_to_words('thisT'))
	"}}}

	" spelunker#utils#convert_control_character_to_space"{{{
	let l:result = spelunker#utils#convert_control_character_to_space('abc\tdef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\ndef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\rdef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\r\t\ndef')
	call assert_equal('abc      def', l:result)
	"}}}
endfunction

function! s:check_cases()
	" spelunker#utils#convert_control_character_to_space"{{{
	let b:camel_case_count = 1
	let b:snake_case_count = 2

	call spelunker#cases#reset_case_counter()

	call assert_equal(0, b:camel_case_count)
	call assert_equal(0, b:snake_case_count)
	"}}}

	" spelunker#cases#case_counter"{{{
	call spelunker#cases#case_counter('_abc_def')
	call assert_equal(0, b:camel_case_count)
	call assert_equal(1, b:snake_case_count)

	call spelunker#cases#case_counter('abcDef')
	call assert_equal(1, b:camel_case_count)
	call assert_equal(1, b:snake_case_count)

	call spelunker#cases#case_counter('AbcDef')
	call assert_equal(2, b:camel_case_count)
	call assert_equal(1, b:snake_case_count)

	call spelunker#cases#case_counter('ABCDEF')
	call assert_equal(2, b:camel_case_count)
	call assert_equal(1, b:snake_case_count)
	" }}}

	" spelunker#cases#reset_case_counter()"{{{
	call spelunker#cases#reset_case_counter()
	let b:camel_case_count = 1
	let b:snake_case_count = 2
	call assert_equal(1, spelunker#cases#is_snake_case_file())

	call spelunker#cases#reset_case_counter()
	let b:camel_case_count = 2
	let b:snake_case_count = 1
	call assert_equal(0, spelunker#cases#is_snake_case_file())
	" }}}

	" spelunker#cases#get_first_word_in_line()"{{{
	call assert_equal('camelCase', spelunker#cases#get_first_word_in_line('camelCase, PascalCase'))
	call assert_equal('PascalCase', spelunker#cases#get_first_word_in_line('PascalCase, snake_case'))
	call assert_equal('snake_case', spelunker#cases#get_first_word_in_line('snake_case, lowercase'))
	call assert_equal('lowercase', spelunker#cases#get_first_word_in_line('lowercase camelCase'))
	call assert_equal('camelCase', spelunker#cases#get_first_word_in_line('a camelCase'))
	" call assert_equal('kebab-case', spelunker#cases#get_first_word_in_line('a kebab-case'))
	" }}}

	" spelunker#cases#to_first_char_upper()"{{{
	call assert_equal('Lowercase', spelunker#cases#to_first_char_upper('lowercase'))
	call assert_equal('Uppercase', spelunker#cases#to_first_char_upper('Uppercase'))
	" }}}

	" spelunker#cases#words_to_camel_case()"{{{
	call assert_equal('camelCaseAbc', spelunker#cases#words_to_camel_case(['camel', 'case', 'abc']))
	call assert_equal('camelcase', spelunker#cases#words_to_camel_case(['camelcase']))
	" }}}
endfunction

function! s:check_white_list()
	" spelunker#white_list#init_white_list"{{{
	try
		unlet g:spelunker_white_list
	catch
		" エラー読み捨て
	endtry
	call spelunker#white_list#init_white_list()
	call assert_equal(1, exists('g:spelunker_white_list'))
	call assert_notequal(0, len(g:spelunker_white_list))
	" }}}

	" spelunker#white_list#is_complex_or_compound_word"{{{
	call assert_equal(0, spelunker#white_list#is_complex_or_compound_word('build'))
	" prefix
	call assert_equal(1, spelunker#white_list#is_complex_or_compound_word('rebuild'))
	" suffix
	call assert_equal(1, spelunker#white_list#is_complex_or_compound_word('nullable'))
	" }}}
endfunction

function! s:check_spellbad()
	" spelunker#spellbad#get_word_list_in_line"{{{
	call assert_equal(['this', 'car', 'func'], spelunker#spellbad#get_word_list_in_line('    $this->car->func()', []))
	call assert_equal(['apple'], spelunker#spellbad#get_word_list_in_line('    \tapple', []))
	call assert_equal(['apple', 'this'], spelunker#spellbad#get_word_list_in_line('apple\rthis', []))
	" }}}

	" 通常の引っかかるケース"{{{
	call s:open_unit_test_buffer('case1')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(['appl', 'Banan', 'Oran'], l:result)

	let l:result = spelunker#spellbad#get_spell_bad_list(6, -1)
	call assert_equal(['appl', 'banan', 'oran'], l:result)

	" First Upper Case and lower case
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 6)
	call assert_equal(['appl', 'Banan', 'Oran', 'banan', 'oran'], l:result)
	" }}}

	" Upper Case"{{{
	call s:open_unit_test_buffer('case2')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['HTMLF', 'FFFCC'], l:result)
	" }}}

	" control character "{{{
	call s:open_unit_test_buffer('case3')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal([], l:result)

	let l:result = spelunker#spellbad#get_spell_bad_list(9, -1)
	call assert_equal(['Banan', 'Oage', 'Pach'], l:result)
	" }}}

	" char count "{{{
	call s:open_unit_test_buffer('case4')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(['purp', 'purpl'], l:result)
	" }}}

	" First upper case word "{{{
	call s:open_unit_test_buffer('case5')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal([], l:result)
	" }}}

	" Edge cases "{{{
	call s:open_unit_test_buffer('case6')
	let l:result = spelunker#spellbad#get_spell_bad_list(7, -1)
	call assert_equal([], l:result)
	" }}}

	" set spelllang "{{{
	call s:open_unit_test_buffer('case8')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal([], l:result)

	setlocal spelllang=en_us
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['colour'], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_spell_bad
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal([], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_all
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['colour'], l:result)
	" 設定戻す
	setlocal spelllang=en
	" }}}
endfunction

function! s:check_match()
	" get_match_pattern "{{{
	let l:word = 'banana'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'orange_banana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orangebanana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orange_bananaapple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'Abanana')
	" }}}

	" get_match_pattern "{{{
	let l:word = 'Banana'
	call assert_equal('\v[A-Z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaApple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaapple' )

	" HTTP or HTTPS??
	let l:word = 'Spanner'
	call assert_equal('\v[A-Z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'HTTPSpanner')

	" # ISSUE/PR
	" #10 https://github.com/kamykn/spelunker.vim/pull/10
	let l:word = 'ormat' " <= typo 'format'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'doormat')
	" }}}

	" get_match_pattern "{{{
	call s:open_unit_test_buffer('case7')
	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'melon', 'lemon'], {})
	call assert_equal([], l:match_id_list[0])
	call assert_equal({'orange': 6, 'apple': 5, 'melon': 7, 'lemon': 8}, l:match_id_list[1])

	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'peach', 'grape'], l:match_id_list[1])
	call assert_equal(['melon', 'lemon'], l:match_id_list[0])
	call assert_equal({'orange': 6, 'peach': 9, 'apple': 5, 'melon': 7, 'lemon': 8, 'grape': 10}, l:match_id_list[1])

	let l:match_id_list_after_delete = spelunker#matches#delete_matches(l:match_id_list[0], l:match_id_list[1])
	call assert_equal({'orange': 6, 'peach': 9, 'apple': 5, 'grape': 10}, l:match_id_list_after_delete)

	let l:all_ids = keys(l:match_id_list_after_delete)
	let l:match_id_list_after_delete = spelunker#matches#delete_matches(l:all_ids, l:match_id_list_after_delete)
	call assert_equal({}, l:match_id_list_after_delete)
	" }}}
endfunction

function! s:check_jump()
	" cursor pos reset "{{{
	call s:open_unit_test_buffer('case9')
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
	call s:open_unit_test_buffer('case10')
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
	call s:open_unit_test_buffer('case12')
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
	call s:open_unit_test_buffer('case11')
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

	" toggle戻し
	call assert_equal(1, spelunker#toggle())
endfunction

function! s:check_words()
	call s:open_unit_test_buffer('case13')

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

	call s:reload_buffer()

	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 1)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documentation', expand("<cword>"))
	call s:assert_cursor_pos(4, 6)

	call s:reload_buffer()
	" }}}

	" spelunker#words#check " {{{
	call s:open_unit_test_buffer('case14')
	call s:clear_matches()
	call spelunker#words#check()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 11},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 12},
		\ l:result[1])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!graape[a-z]@!\C', 'priority': 0, 'id': 13},
		\ l:result[2])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!lemone[a-z]@!\C', 'priority': 0, 'id': 14},
		\ l:result[3])

	call s:clear_matches()
	call spelunker#words#check_display_area()
	let l:result = getmatches()
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!appl[a-z]@!\C', 'priority': 0, 'id': 15},
		\ l:result[0])
	call assert_equal(
		\ {'group': 'SpelunkerSpellBad', 'pattern': '\v[A-Za-z]@<!banan[a-z]@!\C', 'priority': 0, 'id': 16},
		\ l:result[1])
	"}}}
endfunction

function! s:check_correct()
endfunction

function! s:open_unit_test_buffer(filename)
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
