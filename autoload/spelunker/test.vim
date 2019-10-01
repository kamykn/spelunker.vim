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
	call assert_equal(exists('g:spelunker_white_list'), 1)
	call assert_notequal(len(g:spelunker_white_list), 0)
	" }}}

	" spelunker#white_list#is_complex_or_compound_word"{{{
	call assert_equal(spelunker#white_list#is_complex_or_compound_word('build'), 0)
	" prefix
	call assert_equal(spelunker#white_list#is_complex_or_compound_word('rebuild'), 1)
	" suffix
	call assert_equal(spelunker#white_list#is_complex_or_compound_word('nullable'), 1)
	" }}}
endfunction

function! s:check_spellbad()
	" spelunker#spellbad#get_word_list_in_line"{{{
	call assert_equal(spelunker#spellbad#get_word_list_in_line('    $this->car->func()', []), ['this', 'car', 'func'])
	call assert_equal(spelunker#spellbad#get_word_list_in_line('    \tapple', []), ['apple'])
	call assert_equal(spelunker#spellbad#get_word_list_in_line('apple\rthis', []), ['apple', 'this'])
	" }}}

	" 通常の引っかかるケース"{{{
	call s:open_unit_test_buffer('case1')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(l:result, ['appl', 'Banan', 'Oran'])

	let l:result = spelunker#spellbad#get_spell_bad_list(6, -1)
	call assert_equal(l:result, ['appl', 'banan', 'oran'])

	" First Upper Case and lower case
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 6)
	call assert_equal(l:result, ['appl', 'Banan', 'Oran', 'banan', 'oran'])
	" }}}

	" Upper Case"{{{
	call s:open_unit_test_buffer('case2')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(l:result, ['HTMLF', 'FFFCC'])
	" }}}

	" control character "{{{
	call s:open_unit_test_buffer('case3')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(l:result, [])

	let l:result = spelunker#spellbad#get_spell_bad_list(9, -1)
	call assert_equal(l:result, ['Banan', 'Oage', 'Pach'])
	" }}}

	" char count "{{{
	call s:open_unit_test_buffer('case4')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(l:result, ['purp', 'purpl'])
	" }}}

	" First upper case word "{{{
	" TODO: 多分不具合なので直す
	call s:open_unit_test_buffer('case5')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(l:result, ['Wednesday'])
	" }}}

	" Edge cases "{{{
	call s:open_unit_test_buffer('case6')
	let l:result = spelunker#spellbad#get_spell_bad_list(7, -1)
	call assert_equal(l:result, [])
	" }}}

endfunction

function! s:open_unit_test_buffer(filename)
	execute ':edit ' . escape(g:spelunker_plugin_path, ' ') . '/test/unit_test/' . a:filename . '.md'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
