" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:get_spell_bad_list(text, spell_good_list, spell_bad_list)
	let l:line_for_find_target_word = a:text

	let l:spell_good_list = a:spell_good_list
	let l:spell_bad_list  = a:spell_bad_list

	while 1
		" キャメルケース、パスカルケース、スネークケースの抜き出し
		" ex) camelCase, PascalCase, snake_case, __construct
		let l:match_target_word = matchstr(l:line_for_find_target_word, '\v([_]*[A-Za-z_]+)\C')
		if l:match_target_word == ""
			break
		endif

		let l:line_for_find_target_word = s:cut_text_word_before(l:line_for_find_target_word, l:match_target_word)

		let l:word_list = s:code_to_words(l:match_target_word, 1)
		let [l:spell_good_list, l:spell_bad_list] = s:filter_spell_good_bad_list(l:word_list, l:spell_good_list, l:spell_bad_list)
	endwhile

	return [l:spell_good_list, l:spell_bad_list]
endfunction

function! s:filter_spell_good_bad_list(word_list, spell_good_list, spell_bad_list)
	let l:spell_good_list = a:spell_good_list
	let l:spell_bad_list  = a:spell_bad_list

	for word in a:word_list
		" 特定文字数以上のみ検出
		if strlen(word) < g:spellunker_min_char_len
			continue
		endif

		if index(g:spellunker_white_list, word) >= 0
			continue
		endif

		" すでに見つかっているspell_bad_wordの場合スルー
		if (index(l:spell_bad_list, word) != -1 || index(l:spell_good_list, word) != -1)
			continue
		endif

		let [l:spell_bad_word, l:error_type] = spellbadword(word)
		if empty(l:spell_bad_word)
			call add(l:spell_good_list, word)
			continue
		endif

		call add(l:spell_bad_list, l:spell_bad_word)
	endfor

	return [l:spell_good_list, l:spell_bad_list]
endfunction

function! s:code_to_words(line_of_code, should_be_lowercase)
	let l:split_by   = ' '
	let l:words_list = []

	" 単語ごとに空白で区切った後にsplitで単語だけの配列を作る
	" ex) spell_bad_word -> spell Bad Word -> ['spell', 'Bad', 'Word']
	" ex) spell_bad_word -> spell bad word -> ['spell', 'bad', 'word']
	let l:splitWord = split(substitute(a:line_of_code, '\v[_]*([A-Z]{0,1}[a-z]+)\C', l:split_by . "\\1", "g"), l:split_by)

	for s in l:splitWord
		if index(l:words_list, s) != -1
			continue
		endif

		let l:word = s
		if a:should_be_lowercase
			let l:word = tolower(s)
		endif

		call add(l:words_list, word)
	endfor

	return l:words_list
endfunction

function! s:search_current_word(line_str, cword, cursor_position)
	let [l:word_start_pos_in_cword, l:cword_start_pos] = s:get_target_word_pos(a:line_str, a:cword, a:cursor_position)

	" 現在のカーソル位置がcwordの中で何文字目か
	let l:cursor_pos_in_cword = a:cursor_position - l:word_start_pos_in_cword
	" その単語がcwordの中で何文字目から始まるか
	let l:word_start_pos_in_cword = l:word_start_pos_in_cword - l:cword_start_pos

	let l:check_words_list = s:code_to_words(a:cword, 0)
	let l:last_word_length = 1
	for w in l:check_words_list
		if l:cursor_pos_in_cword <= strlen(w) + l:last_word_length
			let [l:word_start_pos_in_cword, l:tmp] = s:get_target_word_pos(a:cword, w, l:cursor_pos_in_cword)
			return [w, l:cursor_pos_in_cword, l:word_start_pos_in_cword]
		endif
		let l:last_word_length += strlen(w)
	endfor

	return [get(l:check_words_list, 0, a:cword), 0, 0]
endfunction

" 行上でどの単語にカーソルが乗っていたかを取得する
function! s:get_target_word_pos(line_str, cword, cursor_pos_in_cword)
	" 単語の末尾よりもカーソルが左だった場合、cursor_pos_in_cword - wordIndexが単語内の何番目にカーソルがあったかが分かる
	" return [カーソルがある(spellチェックされる最小単位の)単語の開始位置, cword全体の開始位置]

	let l:word_index_list = s:find_word_index_list(a:line_str, a:cword)

	for target_word_start_pos in l:word_index_list
		if target_word_start_pos <= a:cursor_pos_in_cword && a:cursor_pos_in_cword <= target_word_start_pos + strlen(a:cword)
			return [target_word_start_pos, get(l:word_index_list, 0, 0)]
		endif
	endfor

	return [0, 0]
endfunction

function! s:find_word_index_list(line_str, cword)
	" 単語のポジションリストを返して、ポジションスタート + 単語長の中にcurposがあればそこが現在位置

	let l:cword_length         = strlen(a:cword)
	let l:find_word_index_list = []
	let l:line_str             = a:line_str

	while 1
		let l:tmp_cword_pos = stridx(l:line_str, a:cword)
		if l:tmp_cword_pos < 0
			break
		endif

		call add(l:find_word_index_list, l:tmp_cword_pos)
		let l:line_str = strpart(l:line_str, l:tmp_cword_pos + l:cword_length)
	endwhile

	return l:find_word_index_list
endfunction

function! s:get_spell_suggest_list(spell_suggest_list, target_word, cword)
	" 変換候補選択用リスト
	let l:spell_suggest_list_for_input_list = []
	" 変換候補リプレイス用リスト
	let l:spell_suggest_list_for_replace   = []

	let l:select_index_strlen = strlen(len(a:spell_suggest_list))

	let i = 1
	for s in a:spell_suggest_list
		let l:index_str = printf("%" . l:select_index_strlen . "d", i) . ': '

		" 記号削除
		let s = substitute(s, '\.', " ", "g")

		" 2単語の場合連結
		if stridx(s, ' ') > 0
			let s = substitute(s, '\s', ' ', 'g')
			let l:suggest_words = split(s, ' ')
			let s = ''
			for w in l:suggest_words
				let s = s . s:to_first_char_upper(w)
			endfor
		endif

		" 先頭大文字小文字
		if match(a:target_word[0], '\v[A-Z]\C') == -1
			let s = tolower(s)
		else
			let s = s:to_first_char_upper(s)
		endif

		call add(l:spell_suggest_list_for_replace, s)
		call add(l:spell_suggest_list_for_input_list, l:index_str . '"' . s . '"')
		let i += 1
	endfor

	return [l:spell_suggest_list_for_input_list, l:spell_suggest_list_for_replace]
endfunction

function! s:cut_text_word_before (text, word)
	let l:found_pos = stridx(a:text, a:word)

	if l:found_pos < 0
		return a:text
	endif

	let l:word_length = len(a:word)
	return strpart(a:text, l:found_pos + l:word_length)
endfunction

" match_idを先頭の1単語目の場合と２単語目の場合の大文字のケースで管理する必要が有ることに注意
" 例：{'strlen': 4, 'Strlen': 5}
function! s:add_matches(window_text_list, match_id_dict)
	let l:ignore_spell_bad_list = keys(a:match_id_dict)
	let l:word_list_for_delete  = l:ignore_spell_bad_list
	let l:match_id_dict         = a:match_id_dict

	" goodは重複チェック判定用
	let l:spell_good_list = []
	let l:spell_bad_list  = []

	for w in a:window_text_list
		let [l:spell_good_list, l:spell_bad_list] = s:get_spell_bad_list(w, l:spell_good_list, l:spell_bad_list)
	endfor

	for s in l:spell_bad_list
		let l:lowercase_spell = tolower(s)
		let l:first_char_upper_spell = s:to_first_char_upper(l:lowercase_spell)
		let l:upperspell = toupper(l:lowercase_spell)

		" 新たに見つかった場合
		if index(l:ignore_spell_bad_list, l:lowercase_spell) == -1
			" 大文字小文字無視オプションを使わない(事故るのを防止するため)
			" ng: xxxAttr -> [atTr]iplePoint

			let l:highlight_group = g:spellunker_spell_bad_group
			if white_list#is_compound_word(l:lowercase_spell)
				let l:highlight_group = g:spellunker_compound_word_group
			endif

			" lowercase
			" ex: xxxStrlen -> [strlen]
			let l:match_id = matchadd(l:highlight_group, '\v([A-Za-z]@<!)' . l:lowercase_spell . '([a-z]@!)\C')
			execute 'let l:match_id_dict.' . l:lowercase_spell . ' = ' . l:match_id

			" first character uppercase spell
			let l:match_id = matchadd(l:highlight_group, '\v' . l:first_char_upper_spell . '([a-z]@!)\C')
			execute 'let l:match_id_dict.' . l:first_char_upper_spell . ' = ' . l:match_id

			" UPPERCASE spell
			" 正しい単語の定数で引っかからないように注意
			" ng: xxxAttr -> [ATTR]IBUTE
			let l:match_id = matchadd(l:highlight_group, '\v([A-Z]@<!)' . l:upperspell . '([A-Z]@!)\C')
			execute 'let l:match_id_dict.' . l:upperspell . ' = ' . l:match_id

			" Management of the spelling list in the lower case
			call add(l:ignore_spell_bad_list, l:lowercase_spell)
		endif

		" 削除予定リストから単語消す
		let l:del_index = index(l:word_list_for_delete, l:lowercase_spell)
		if l:del_index != -1
			call remove(l:word_list_for_delete, l:del_index)
		endif

		let l:del_index = index(l:word_list_for_delete, l:first_char_upper_spell)
		if l:del_index != -1
			call remove(l:word_list_for_delete, l:del_index)
		endif

		let l:del_index = index(l:word_list_for_delete, l:upperspell)
		if l:del_index != -1
			call remove(l:word_list_for_delete, l:del_index)
		endif
	endfor

	return [l:word_list_for_delete, l:match_id_dict]
endfunction

function! s:to_first_char_upper(lowercase_spell)
	return toupper(a:lowercase_spell[0]) . a:lowercase_spell[1:-1]
endfunction

function! s:delete_matches(word_list_for_delete, match_id_dict)
	let l:match_id_dict = a:match_id_dict

	for l in a:word_list_for_delete
		let l:delete_match_id = get(l:match_id_dict, l, 0)
		if l:delete_match_id > 0
			try
				call matchdelete(l:delete_match_id)
			catch
				" エラー読み捨て
			finally
				let l:del_index = index(values(l:match_id_dict), l:delete_match_id)
				if l:del_index != 1
					call remove(l:match_id_dict, keys(l:match_id_dict)[l:del_index])
				endif
			endtry
		endif
	endfor

	return l:match_id_dict
endfunction

function! spellunker#check()
	if &readonly
		return
	endif

	if g:enable_spellunker == 0
		return
	endif

	call white_list#init_white_list()

	redir => spell_setting_capture
		silent execute "setlocal spell?"
	redir END

	" ex) '      spell' -> 'spell'
	let l:spell_setting = substitute(l:spell_setting_capture, '\v(\n|\s)\C', '', 'g')
	setlocal spell

	let l:window_text_list = getline(1, '$')

	if !exists('b:match_id_dict')
		let b:match_id_dict = {}
	endif

	let [l:word_list_for_delete, b:match_id_dict] = s:add_matches(l:window_text_list, b:match_id_dict)

	if l:spell_setting != "spell"
		setlocal nospell
	endif

	if len(l:word_list_for_delete) == 0
		return
	endif

	let b:match_id_dict = s:delete_matches(l:word_list_for_delete, b:match_id_dict)
endfunction

function! spellunker#open_fix_list()
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z_]')
		echo "It does not match [A-Za-z_]."
		return
	endif

	let l:cursor_position = col('.')
	let [l:target_word, l:cursor_pos_in_cword, l:word_start_pos_in_cword] = s:search_current_word(getline('.'), l:cword, l:cursor_position)
	let l:spell_suggest_list = spellsuggest(l:target_word, g:spellunker_max_suggest_words)

	if len(l:spell_suggest_list) == 0
		echo "No suggested words."
		return
	endif

	let [l:spell_suggest_list_for_input_list, l:spell_suggest_list_for_replace] = s:get_spell_suggest_list(l:spell_suggest_list, l:target_word, l:cword)

	let l:selected     = inputlist(l:spell_suggest_list_for_input_list)
	let l:selectedWord = l:spell_suggest_list_for_replace[l:selected - 1]

	let l:replace  = strpart(l:cword, 0, l:word_start_pos_in_cword)
	let l:replace .= l:selectedWord
	let l:replace .= strpart(l:cword, l:word_start_pos_in_cword + strlen(l:target_word), strlen(l:cword))

	" 書き換えてカーソルポジションを直す
	execute "normal ciw" . l:replace
	execute "normal b" . l:cursor_pos_in_cword . "l"
endfunction

function! spellunker#execute_with_target_word(command)
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z_]')
		echo "It does not match [A-Za-z_]."
		return
	endif

	let l:cursor_position = col('.')
	let [l:target_word, l:cursor_pos_in_cword, l:word_start_pos_in_cword] = s:search_current_word(getline('.'), l:cword, l:cursor_position)

	execute a:command . ' ' . tolower(l:target_word)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
