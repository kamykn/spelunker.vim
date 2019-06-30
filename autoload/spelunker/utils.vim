" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" 特定の文字数以上のみ返す
function! spelunker#utils#filter_list_char_length(word_list)
	let l:filtered_word_list = []

	for word in a:word_list
		if strlen(word) < g:spelunker_target_min_char_len
			continue
		endif

		call add(l:filtered_word_list, word)
	endfor

	return l:filtered_word_list
endfunction

function! spelunker#utils#code_to_words(line_of_code)
	let l:split_by   = ' '
	let l:words_list = []

	" 単語ごとに空白で区切った後にsplitで単語だけの配列を作る
	" ex) spellBadWord -> spell Bad Word -> ['spell', 'Bad', 'Word']
	" ex) spell_bad_word -> spell bad word -> ['spell', 'bad', 'word']

	" ABC_DEF -> ABC DEF
	let l:code_for_split = substitute(a:line_of_code, '_', l:split_by, "g")

	" ABCdef -> AB Cdef
	" abcAPI -> abc API
	let l:code_for_split = substitute(l:code_for_split, '\v([A-Z]@<![A-Z]|[A-Z][a-z])\C', l:split_by . "\\1", "g")

	" AA__BB -> AA  BB -> AA BB
	let l:code_for_split = substitute(l:code_for_split, '\v\s+', l:split_by, "g")

	return split(l:code_for_split, l:split_by)
endfunction

" \n \r \t (制御文字)をスペースに置き換え
function! spelunker#utils#convert_control_character_to_space(line)
	" ex) \nabcd -> \n abcd
	return substitute(a:line, '\v(\\n|\\r|\\t)\C', '  ', "g")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
