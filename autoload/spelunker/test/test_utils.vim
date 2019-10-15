" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_utils#test()
	call s:test_filter_list_char_length()
	call s:test_code_to_words()
	call s:test_convert_control_character_to_space()
endfunction

function! s:test_filter_list_char_length()
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
endfunction

function! s:test_code_to_words()
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
endfunction

function! s:test_convert_control_character_to_space()
	let l:result = spelunker#utils#convert_control_character_to_space('abc\tdef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\ndef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\rdef')
	call assert_equal('abc  def', l:result)

	let l:result = spelunker#utils#convert_control_character_to_space('abc\r\t\ndef')
	call assert_equal('abc      def', l:result)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
