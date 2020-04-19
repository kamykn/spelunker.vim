" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#words#search_target_word()
	let l:cursor_position = col('.')
	let l:line = getline('.')

	" get_word_list_in_lineの中で制御文字を取り除いたりしている
	let l:word_list = spelunker#spellbad#get_word_list_in_line(l:line, [])

	" 単語のポジションリストを返して、ポジションスタート + 単語長の中にcursor_positionがあればそこが現在位置
	for word in l:word_list
		let l:word_index_list = s:find_word_index_list(l:line, word)
		for target_word_start_pos in l:word_index_list
			if target_word_start_pos <= l:cursor_position && l:cursor_position <= target_word_start_pos + strlen(word)
				return word
			endif
		endfor
	endfor

	return ''
endfunction


function! s:find_word_index_list(line_str, search_word)
	let l:cword_length         = strlen(a:search_word)
	let l:find_word_index_list = []
	let l:line_str             = a:line_str

	while 1
		let l:tmp_cword_pos = stridx(l:line_str, a:search_word)
		if l:tmp_cword_pos == -1
			break
		endif

		call add(l:find_word_index_list, l:tmp_cword_pos)
		let l:line_str = strpart(l:line_str, l:tmp_cword_pos + l:cword_length)
	endwhile

	return l:find_word_index_list
endfunction

function! spelunker#words#format_spell_suggest_list(spell_suggest_list, target_word)
	" 変換候補選択用リスト
	let l:spell_suggest_list_for_input_list = []
	" 変換候補リプレイス用リスト
	let l:spell_suggest_list_for_replace   = []

	let l:select_index_strlen = strlen(len(a:spell_suggest_list))

	let l:i = 1
	for s in a:spell_suggest_list
		" アクセント付き文字の入った単語は除外
		if s =~# '\v[À-ú]\C'
			continue
		endif

		" シングルクオートは除外
		if stridx(s, "'") > 0
			continue
		endif

		let l:index_str = printf("%" . l:select_index_strlen . "d", l:i) . ': '

		" 小文字前提で処理をする
		" 記号(ドット)を削除する
		" TODO: 全大文字の場合の考慮
		let l:spell = tolower(substitute(s, '\.', ' ', 'g'))

		" 2単語の場合連結
		if stridx(l:spell, ' ') > 0
			let l:spell = substitute(l:spell, '\s', ' ', 'g')
			let l:suggest_words = split(l:spell, ' ')

			if spelunker#cases#is_snake_case_file()
				let l:spell = join(l:suggest_words, '_')
			else
				let l:spell = spelunker#cases#words_to_camel_case(l:suggest_words)
			endif
		endif

		if a:target_word[0] =~# '\v[A-Z]\C'
			" #10 2語以上の場合、後ろの文字が小文字になったりしないように修正した
			let l:spell = toupper(l:spell[0]) . l:spell[1:-1]
		endif

		call add(l:spell_suggest_list_for_replace, l:spell)
		call add(l:spell_suggest_list_for_input_list, l:index_str . '"' . l:spell . '"')
		let l:i += 1
	endfor

	return [l:spell_suggest_list_for_input_list, l:spell_suggest_list_for_replace]
endfunction

function! spelunker#words#cut_text_word_before (text, word)
	let l:found_pos = stridx(a:text, a:word)

	if l:found_pos < 0
		return a:text
	endif

	let l:word_length = len(a:word)
	return strpart(a:text, l:found_pos + l:word_length)
endfunction

" 書き換えてカーソルポジションを直す
function! spelunker#words#replace_word(target_word, replace_word, is_correct_all)
	let l:pos = getpos(".")

	if a:is_correct_all
		execute "silent! %s/\\v([A-Z]@<!)" . a:target_word . "([a-z]@!)\\C/". a:replace_word . "/g"
	else
		let l:right_move = strlen(a:target_word) - 1
		execute "silent! normal /" . a:target_word . "\<CR>Nv" . l:right_move . "lc" . a:replace_word
	endif

	call setpos('.', l:pos)
endfunction

function! spelunker#words#echo_for_white_list(spell_bad_list)
	let l:for_echo_list = []
	for word in a:spell_bad_list
		let word = tolower(word)
		if index(l:for_echo_list, word) == -1
			call add(l:for_echo_list, word)
		endif
	endfor
	echo l:for_echo_list
endfunction

" 大文字小文字は区別してリスト登録している
function! spelunker#words#check()
	call spelunker#cases#reset_case_counter()

	let l:window_text_list = spelunker#get_buffer#all()
	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:window_text_list)

	call spelunker#words#highlight(l:spell_bad_list)
endfunction

" 大文字小文字は区別してリスト登録している
function! spelunker#words#check_display_area()
	call spelunker#cases#reset_case_counter()

	let l:window_text_list = spelunker#get_buffer#displayed()
	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:window_text_list)

	" unique
	let l:spell_bad_list = filter(copy(l:spell_bad_list), 'index(l:spell_bad_list, v:val, v:key+1)==-1')

	call spelunker#words#highlight(l:spell_bad_list)
endfunction

function! spelunker#words#highlight(spell_bad_list)
	let l:spell_bad_list = a:spell_bad_list

	" matchadd()の対象が多すぎるとスクロール時に毎回処理が走るっぽく、重くなるため
	if len(l:spell_bad_list) > g:spelunker_max_hi_words_each_buf
		if !exists('b:is_too_much_words_notified')
			echon 'Too many spell bad words. (' . len(l:spell_bad_list) . ' words found.)'
		endif

		let l:spell_bad_list = l:spell_bad_list[0:g:spelunker_max_hi_words_each_buf]

		" 2回目は通知しない
		let b:is_too_much_words_notified = 1
	endif

	if !exists('b:match_id_dict')
		let b:match_id_dict = {}
	endif

	" 同じbufferながら、ウインドウを2つ開いたときに両方正しくhighlightされるように
	let l:window_id = win_getid()
	if !has_key(b:match_id_dict, l:window_id)
		let b:match_id_dict[l:window_id] = {}
	endif

	let [l:word_list_for_delete_match, b:match_id_dict[l:window_id]] =
				\ spelunker#matches#add_matches(l:spell_bad_list, b:match_id_dict[l:window_id])

	if len(l:word_list_for_delete_match) == 0
		return
	endif

	let b:match_id_dict[l:window_id] =
				\ spelunker#matches#delete_matches(l:word_list_for_delete_match, b:match_id_dict[l:window_id], l:window_id)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
