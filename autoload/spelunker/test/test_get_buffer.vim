scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_get_buffer#test()
	call s:test_all()
	call s:test_displayed()
	call s:test_disable_option()
endfunction

function! s:test_all()
	call spelunker#test#open_unit_test_buffer('words', 'highlight.txt')
	call assert_equal(['aple banan lemn', 'apple_banana_lemon', 'AppleBananaLemon'], spelunker#get_buffer#all())
endfunction

function! s:test_displayed()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call assert_equal(['appl banan'], spelunker#get_buffer#displayed())
endfunction

function! s:test_displayed()
	call spelunker#test#open_unit_test_buffer('words', 'folded.txt')

	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', 'aaaaaaa', '', 'grape',
				\ 	'', 'pineappple', '', '', '', '', ''
				\ ],
				\ spelunker#get_buffer#all()
				\ )

	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', '`ccccccccc', '',
				\ 	'orange peach meron', 'cccbbbbbbba', 'b', 'c', 'd`'
				\ ],
				\ spelunker#get_buffer#displayed()
				\ )

	let g:spelunker_disable_url_check = 0
	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', 'http://sample2.com',
				\ 	'', 'aaaaaaa', '', 'grape', '', 'pineappple', '', '', ''
				\ ],
				\ spelunker#get_buffer#all()
				\ )
	let g:spelunker_disable_url_check = 1

	let g:spelunker_disable_back_quoted_check = 0
	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', '', '', '`ccccccccc',
				\ 	'', 'orange peach meron', '" {{{', '        banana', '      bannana', '     ', '    `aaaaaaa`',
				\ 	'" }}}', '', 'ccc`', '', 'grape', '', 'pineappple', '', '`bbbbbbb`', '', '`a', 'b', 'c', 'd`'
				\ ],
				\ spelunker#get_buffer#all()
				\ )

	call assert_equal(
				\ [
				\ 	'" vim: foldmethod=marker', '" vim: foldcolumn=3', '" vim: foldlevel=0', '', '', '', '`ccccccccc',
				\ 	'', 'orange peach meron', 'ccc`', '', 'grape', '', 'pineappple', '', '`bbbbbbb`', '', '`a', 'b',
				\ 	'c', 'd`'
				\ ],
				\ spelunker#get_buffer#displayed()
				\ )
	let g:spelunker_disable_back_quoted_check = 1
endfunction

function! spelunker#test#test_get_buffer#test_filter_back_quoted_string()
	" call spelunker#test#open_unit_test_buffer('get_buffer', 'disable_back_quote.txt')
	call spelunker#test#open_unit_test_buffer('words', 'folded.txt')
	echo spelunker#get_buffer#all()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
