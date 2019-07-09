" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#check_displayed_words()
	if &readonly
		return
	endif

	if g:enable_spelunker_vim == 0
		return
	endif

	if g:spelunker_check_type != g:spelunker_check_type_cursor_hold
		return
	endif

	call spelunker#words#check_display_area()
endfunction

function! spelunker#check()
	if &readonly
		return
	endif

	if g:enable_spelunker_vim == 0
		return
	endif

	if g:spelunker_check_type != g:spelunker_check_type_buf_lead_write
		return
	endif

	call spelunker#words#check()
endfunction

function! spelunker#check_and_echo_list()
	if &readonly
		return
	endif

	if g:enable_spelunker_vim == 0
		return
	endif

	call spelunker#cases#reset_case_counter()
	" ホワイトリスト作るとき用のオプション
	let l:orig_spelunker_target_min_char_len = g:spelunker_target_min_char_len
	let g:spelunker_target_min_char_len = 1

	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(1, '$')

	" ホワイトリスト作るとき用のオプション
	let g:spelunker_target_min_char_len = l:orig_spelunker_target_min_char_len
	call spelunker#words#echo_for_white_list(l:spell_bad_list)
endfunction

function! spelunker#execute_with_target_word(command)
	let l:target_word = spelunker#words#search_target_word()
	if l:target_word == ''
		return
	endif

	execute a:command . ' ' . tolower(l:target_word)
endfunction

function! spelunker#add_all_spellgood()
	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(1, '$')

	if len(l:spell_bad_list) == 0
		return
	endif

	for word in l:spell_bad_list
		execute 'silent! spellgood ' . tolower(word)
	endfor

	echon len(l:spell_bad_list) . ' word(s) added to the spellfile.'
endfunction

function! spelunker#correct()
	call spelunker#correct#correct(0)
endfunction

function! spelunker#correct_all()
	call spelunker#correct#correct(1)
endfunction

function! spelunker#correct_from_list()
	let l:is_correct_all = 0
	let l:is_feeling_lucky = 0
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
endfunction

function! spelunker#correct_all_from_list()
	let l:is_correct_all = 1
	let l:is_feeling_lucky = 0
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
endfunction

function! spelunker#correct_feeling_lucky()
	let l:is_correct_all = 0
	let l:is_feeling_lucky = 1
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
endfunction

function! spelunker#correct_all_feeling_lucky()
	let l:is_correct_all = 1
	let l:is_feeling_lucky = 1
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
endfunction

" spell設定を戻す
function! spelunker#reduce_spell_setting(spell_setting)
	if a:spell_setting != "spell"
		setlocal nospell
	endif
endfunction

" 処理前のspell設定を取得
function! spelunker#get_current_spell_setting()
	redir => spell_setting_capture
		silent execute "setlocal spell?"
	redir END

	" ex) '      spell' -> 'spell'
	return  substitute(l:spell_setting_capture, '\v(\n|\s)\C', '', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
