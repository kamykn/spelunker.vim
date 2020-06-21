" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" end_lineの指定がなければ1行のみ
function! spelunker#spellbad#get_spell_bad_list(window_text_list)
	call spelunker#white_list#init_white_list()

	" spellgood で対象から外れる場合もあるので、全部チェックする必要があり
	" NOTE: spellgood系操作でmatch_id_dictから消してあげたらチェック不要になる。
	"       ただし、match_id_dictをglobalにする必要あり
	let l:word_list = s:get_word_list(a:window_text_list)

	let l:current_spell_setting = spelunker#get_current_spell_setting()
	setlocal spell

	let l:spell_bad_list = s:filter_spell_bad_list(l:word_list)

	call spelunker#reduce_spell_setting(l:current_spell_setting)

	return l:spell_bad_list
endfunction

" 大文字小文字を区別して単語リストを取得
function! s:get_word_list(window_text_list)
	let l:word_list = []

	for line in a:window_text_list
		let l:word_list = spelunker#spellbad#get_word_list_in_line(line, l:word_list)
	endfor

	return l:word_list
endfunction

function! spelunker#spellbad#get_word_list_in_line(line, word_list)
	let l:word_list = a:word_list
	let l:line = spelunker#utils#convert_control_character_to_space(a:line)

	while 1
		" 関数名、変数名ごとに抜き出し(1関数名、変数名ごとに処理)
		let l:match_target_word = spelunker#cases#get_first_word_in_line(l:line)
		if l:match_target_word == ""
			break
		endif

		call spelunker#cases#case_counter(l:match_target_word)

		" 次のループのための処理
		let l:line = spelunker#words#cut_text_word_before(l:line, l:match_target_word)

		" 単語の抜き出し
		let l:find_word_list = spelunker#utils#code_to_words(l:match_target_word)

		for word in l:find_word_list
			if index(l:word_list, word) == -1
				call add(l:word_list, word)
			endif
		endfor
	endwhile

	return l:word_list
endfunction

" word_listから、misspelledなワードだけを返す
function! s:filter_spell_bad_list(word_list)
	let l:spell_bad_list  = []

	" 言語別ホワイトリストの取得
	let l:white_list_for_lang = []
	try
		let l:filetype = &filetype
		execute 'let l:white_list_for_lang = spelunker#utils#filter_list_char_length(spelunker#white_list#white_list_' . l:filetype . '#get_white_list())'
	catch
		" 読み捨て
	endtry

	let l:white_list_for_user = []
	try
		execute 'let l:white_list_for_user = g:spelunker_white_list_for_user'
	catch
		" 読み捨て
	endtry

	let l:spelunker_white_list = spelunker#utils#filter_list_char_length(g:spelunker_white_list)

	for orig_word in spelunker#utils#filter_list_char_length(a:word_list)
		let l:lowercase_word = tolower(orig_word)

		if index(l:spelunker_white_list, l:lowercase_word) >= 0 ||
			\ index(l:white_list_for_lang, l:lowercase_word) >= 0 ||
			\ index(l:white_list_for_user, l:lowercase_word) >= 0
			continue
		endif

		let [l:spell_bad_word, l:spell_bad_type] = spellbadword(l:lowercase_word)

		if l:spell_bad_word != ''
			" Wednesdayなど、先頭大文字しかない単語があるためもう一回チェック
			let [l:spell_bad_word, l:spell_bad_type] = spellbadword(spelunker#cases#to_first_char_upper(l:lowercase_word))
		endif

		if g:spelunker_highlight_type == g:spelunker_highlight_spell_bad && l:spell_bad_type != 'bad'
			continue
		endif

		" 登録は元のケースで行う。辞書登録とそのチェックにかけるときのみlowerケースになる。
		" 元々ここでlowercaseだけ管理し、lower,UPPER,UpperCamelCaseをmatchadd()していたが、
		" 最少のマッチだけを登録させる為、ここで実際に引っかかるものを登録させ、
		" これらをmatchaddさせる。
		if l:spell_bad_word != '' && index(l:spell_bad_list, orig_word) == -1
			call add(l:spell_bad_list, orig_word)
		endif
	endfor

	return l:spell_bad_list
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
