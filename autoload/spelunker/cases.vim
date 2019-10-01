" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#cases#reset_case_counter()
	let b:camel_case_count = 0
	let b:snake_case_count = 0
endfunction

" Unit Testのときにb:で定義されない時があったので、定義がなくても取れるように
function! spelunker#cases#get_camel_case_count()
	if !exists('b:camel_case_count')
		call spelunker#cases#reset_case_counter()
	endif

	return b:camel_case_count
endfunction

" Unit Testのときにb:で定義されない時があったので、定義がなくても取れるように
function! spelunker#cases#get_snake_case_count()
	if !exists('b:snake_case_count')
		call spelunker#cases#reset_case_counter()
	endif

	return b:snake_case_count
endfunction

" ファイル全体でスネークかキャメルケースかを判断してincrement
function! spelunker#cases#case_counter(word)
	if a:word =~# '\v[a-z]_\C'
		" x_ にマッチしたらスネークケース
		let b:snake_case_count = spelunker#cases#get_snake_case_count() + 1
	elseif a:word =~# '\v[a-z][A-Z]\C'
		" xX にマッチしたらキャメルケース
		let b:camel_case_count = spelunker#cases#get_camel_case_count() + 1
	endif
endfunction

function! spelunker#cases#is_snake_case_file()
	return (spelunker#cases#get_snake_case_count() >= spelunker#cases#get_camel_case_count())
endfunction

" キャメルケース、パスカルケース、スネークケースの抜き出し
" ex) camelCase, PascalCase, snake_case, lowercase
function! spelunker#cases#get_first_word_in_line(line)
	" 1文字は対象としない
	return matchstr(a:line, '\v([A-Za-z_]{2,})\C')
endfunction

function! spelunker#cases#to_first_char_upper(lowercase_spell)
	return toupper(a:lowercase_spell[0]) . tolower(a:lowercase_spell[1:-1])
endfunction

function! spelunker#cases#words_to_camel_case(word_list)
	let l:spell = ""
	let l:is_first_word = 1

	for w in a:word_list
		" 先頭大文字小文字
		if l:is_first_word == 1
			let w = tolower(w)
		else
			let w = spelunker#cases#to_first_char_upper(w)
		endif

		let l:spell = l:spell . w
		let l:is_first_word = 0
	endfor

	return l:spell
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
