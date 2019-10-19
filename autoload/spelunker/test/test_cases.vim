" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_cases#test()
	call s:test_reset_case_counter()
	call s:test_get_camel_case_count()
	call s:test_get_snake_case_count()
	call s:test_case_counter()
	call s:test_is_snake_case_file()
	call s:test_get_first_word_in_line()
	call s:test_to_first_char_upper()
	call s:test_words_to_camel_case()
endfunction

function! s:test_get_camel_case_count()
	call spelunker#cases#reset_case_counter()

	" call before count
	call assert_equal(0, spelunker#cases#get_camel_case_count())

	call spelunker#cases#case_counter('_apple_banana')
	call spelunker#cases#case_counter('appleBanana')
	call spelunker#cases#case_counter('appleBanana')
	call spelunker#cases#case_counter('appleBanana')
	call assert_equal(3, spelunker#cases#get_camel_case_count())

	call spelunker#cases#reset_case_counter()
	call spelunker#cases#case_counter('apple')
	call assert_equal(0, spelunker#cases#get_camel_case_count())

	" pascal case
	call spelunker#cases#reset_case_counter()
	call spelunker#cases#case_counter('AppleBanana')
	call assert_equal(1, spelunker#cases#get_camel_case_count())
endfunction

function! s:test_get_snake_case_count()
	call spelunker#cases#reset_case_counter()

	" call before count
	call assert_equal(0, spelunker#cases#get_snake_case_count())

	call spelunker#cases#case_counter('apple_banana')
	call spelunker#cases#case_counter('apple_banana')
	call spelunker#cases#case_counter('apple_banana')
	call spelunker#cases#case_counter('appleBanana')
	call assert_equal(3, spelunker#cases#get_snake_case_count())

	call spelunker#cases#reset_case_counter()
	call spelunker#cases#case_counter('apple')
	call assert_equal(0, spelunker#cases#get_snake_case_count())
endfunction

function! s:test_reset_case_counter()
	let b:camel_case_count = 1
	let b:snake_case_count = 2

	call spelunker#cases#reset_case_counter()

	call assert_equal(0, b:camel_case_count)
	call assert_equal(0, b:snake_case_count)
endfunction

function! s:test_case_counter()
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
endfunction

function! s:test_is_snake_case_file()
	call spelunker#cases#reset_case_counter()
	let b:camel_case_count = 1
	let b:snake_case_count = 2
	call assert_equal(1, spelunker#cases#is_snake_case_file())

	call spelunker#cases#reset_case_counter()
	let b:camel_case_count = 2
	let b:snake_case_count = 1
	call assert_equal(0, spelunker#cases#is_snake_case_file())

	call spelunker#test#open_unit_test_buffer('cases', 'is_snake_case_file1.txt')
	" 強制的にチェック
	call spelunker#words#check()
	call assert_equal(1, spelunker#cases#is_snake_case_file())

	call spelunker#test#open_unit_test_buffer('cases', 'is_snake_case_file2.txt')
	" 強制的にチェック
	call spelunker#words#check()
	call assert_equal(0, spelunker#cases#is_snake_case_file())
endfunction

function! s:test_get_first_word_in_line()
	call assert_equal('camelCase', spelunker#cases#get_first_word_in_line('camelCase, PascalCase'))
	call assert_equal('PascalCase', spelunker#cases#get_first_word_in_line('PascalCase, snake_case'))
	call assert_equal('snake_case', spelunker#cases#get_first_word_in_line('snake_case, lowercase'))
	call assert_equal('lowercase', spelunker#cases#get_first_word_in_line('lowercase camelCase'))
	call assert_equal('kebab', spelunker#cases#get_first_word_in_line('kebab-case'))
	call assert_equal('camelCase', spelunker#cases#get_first_word_in_line('a camelCase'))
endfunction

function! s:test_to_first_char_upper()
	call assert_equal('Lowercase', spelunker#cases#to_first_char_upper('lowercase'))
	call assert_equal('Uppercase', spelunker#cases#to_first_char_upper('Uppercase'))
endfunction

function! s:test_words_to_camel_case()
	call assert_equal('camelCaseAbc', spelunker#cases#words_to_camel_case(['camel', 'case', 'abc']))
	call assert_equal('camelcase', spelunker#cases#words_to_camel_case(['camelcase']))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
