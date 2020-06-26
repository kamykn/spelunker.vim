scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_get_buffer#test()
	" init
	let g:spelunker_disable_backquoted_checking = 1
	let g:spelunker_disable_uri_checking = 1
	let g:spelunker_disable_email_checking = 1
	let g:spelunker_disable_account_name_checking = 1
	let g:spelunker_disable_acronym_checking = 1

	call s:test_all()
	call s:test_displayed()
	call s:test_disable_url_checking()
	call s:test_disable_email_checking()
	call s:test_disable_account_name_checking()
	call s:test_disable_acronym_checking()
	call s:test_disable_backquoted_checking()
	call s:test_folded()
endfunction

function! s:test_all()
	call spelunker#test#open_unit_test_buffer('words', 'highlight.txt')
	call assert_equal(['aple banan lemn', 'apple_banana_lemon', '', 'AppleBananaLemon'], spelunker#get_buffer#all())
endfunction

function! s:test_displayed()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call assert_equal(['appl banan'], spelunker#get_buffer#displayed())
endfunction

function! s:test_disable_url_checking()
	let g:spelunker_disable_uri_checking = 1
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_url.txt')
	call assert_equal(
				\ ['abc  def', '', 'ghi', '', 'jkl'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_uri_checking = 0
	call assert_equal(
				\ ['http://github.com', '', 'abc http://github.com def', '', 'ghi', 'http://github.com', 'jkl'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_uri_checking = 1
endfunction

function! s:test_disable_email_checking()
	" 似ている書式なのでオプションをオフにしてテスト
	let g:spelunker_disable_account_name_checking = 0

	let g:spelunker_disable_email_checking = 1
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_email.txt')
	call assert_equal(
				\ ['abc  def', '', 'ghi', '', 'jkl', '@Annotation'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_email_checking = 0
	call assert_equal(
				\ ['spelunkervim@github.com', '', 'abc spelunkervim@github.com def', '', 'ghi', 'spelunkervim@github.com', 'jkl', '@Annotation'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_account_name_checking = 1
	let g:spelunker_disable_email_checking = 1
endfunction

function! s:test_disable_account_name_checking()
	" 似ている書式なのでオプションをオフにしてテスト
	let g:spelunker_disable_email_checking = 0

	let g:spelunker_disable_account_name_checking = 1
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_account_name.txt')
	call assert_equal(
				\ ['spelunkervim@github.com', '', 'abc spelunkervim@github.com def', '', 'ghi', 'spelunkervim@github.com', 'jkl', '', 'mno  pqr', 'stu  vwx'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_account_name_checking = 0
	call assert_equal(
				\ ['spelunkervim@github.com', '', 'abc spelunkervim@github.com def', '', 'ghi', 'spelunkervim@github.com', 'jkl', '@Annotation', 'mno @mrfoobar pqr', 'stu mrfoobar@ vwx'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_email_checking = 1
	let g:spelunker_disable_account_name_checking = 1
endfunction

function! s:test_disable_acronym_checking()
	let g:spelunker_disable_acronym_checking = 1
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_acronym.txt')
	call assert_equal(
				\ ['abcd', 'Abcd', 'Error', 'Gabrage'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_acronym_checking = 0
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_acronym.txt')
	call assert_equal(
				\ ['ABCD', 'abcd', 'Abcd', 'ABCDError', 'ABCDGabrage'],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_acronym_checking = 0
endfunction

function! s:test_disable_backquoted_checking()
	let g:spelunker_disable_backquoted_checking = 1
	call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_backquote.txt')
	call assert_equal(
				\ ['abc', '', ' def', '', 'ghi ', ' jkl', '', 'mno', '', 'pqr', '', '', '', '', '', '', ''],
				\ spelunker#get_buffer#all()
				\ )

	let g:spelunker_disable_backquoted_checking = 0
	call assert_equal(
				\ [
				\ 	'abc', '', '`aaa` def', '', 'ghi `fff', 'fff` jkl', '', 'mno`', 'aaa', '`pqr', '', '`ccc',
				\ 	'ddd', 'eee`', '', '`c', 'd', 'e`'
				\ ],
				\ spelunker#get_buffer#all()
				\ )
	let g:spelunker_disable_backquoted_checking = 1
endfunction

function! s:test_folded()
	call spelunker#test#open_unit_test_buffer('get_buffer', 'folded.txt')

	set foldmethod=marker
	set foldcolumn=1
	set foldlevel=0

	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', '', '', '', '', '',
				\ 	'', '', '', '', 'aaaaaaa', '', '', '', '', 'grape', '', 'pineappple', '', '', '', '', '', ''
				\ ],
				\ spelunker#get_buffer#all()
				\ )

	call assert_equal(
				\ ['" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', 'grape', 'pineappple'],
				\ spelunker#get_buffer#displayed()
				\ )

	let g:spelunker_disable_backquoted_checking = 0
	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', '', '', '`ccccccccc',
				\ 	'', 'orange peach meron', '" {{{', "\tbanana", "\tbannana", "\t aaa", "\t`aaaaaaa`",
				\ 	'" }}}', '', 'ccc`', '', 'grape', '', 'pineappple', '', '`bbbbbbb`', '', '`a', 'b', 'c', 'd`'
				\ ],
				\ spelunker#get_buffer#all()
				\ )

	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '`ccccccccc',
				\ 	'orange peach meron', 'ccc`', 'grape', 'pineappple', '`bbbbbbb`', '`a',	'b', 'c', 'd`'
				\ ],
				\ spelunker#get_buffer#displayed()
				\ )

	let g:spelunker_disable_backquoted_checking = 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
