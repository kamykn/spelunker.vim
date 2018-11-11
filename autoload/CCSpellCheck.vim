" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:getSpellBadList(text)
	let l:lineForFindTargetWord = a:text
	let l:spellBadList         = []

	while 1
		" キャメルケース、パスカルケース、スネークケースの抜き出し
		" ex) camelCase, PascalCase, snake_case, __construct
		let l:matchTargetWord = matchstr(l:lineForFindTargetWord, '\v([_]*[A-Za-z_]+)\C')
		if l:matchTargetWord == ""
			break
		endif

		let l:lineForFindTargetWord = s:cutTextWordBefore(l:lineForFindTargetWord, l:matchTargetWord)

		let l:wordList = s:codeToWords(l:matchTargetWord, 1)
		let l:foundSpellBadList = s:filterSpellBadList(l:wordList)

		if len(l:foundSpellBadList) == 0
			continue
		endif

		for s in l:foundSpellBadList
			if index(l:spellBadList, s) == -1
				call add(l:spellBadList, s)
			endif
		endfor
	endwhile

	return l:spellBadList
endfunction

function! s:filterSpellBadList(wordList)
	let l:spellBadList = []
	let l:currentPos   = 0

	for w in a:wordList
		if strlen(w) <= 1
			continue
		endif

		let [l:spellBadWord, l:errorType] = spellbadword(w)
		if empty(l:spellBadWord)
			continue
		endif

		if index(g:CCSpellCheckWhiteList, l:spellBadWord) >= 0
			continue
		endif

		let l:wordLength = len(l:spellBadWord)

		" すでに見つかっているspellBadWordの場合スルー
		if index(l:spellBadList, l:spellBadWord) != -1
			continue
		endif

		" 特定文字数以上のみ検出
		if l:wordLength >= g:CCSpellCheckMinCharacterLength
			call add(l:spellBadList, l:spellBadWord)
		endif
	endfor

	return l:spellBadList
endfunction

function! s:codeToWords(lineOfCode, shouldBeLowercase)
	let l:splitBy   = ' '
	let l:wordsList = []

	" 単語ごとに空白で区切った後にsplitで単語だけの配列を作る
	" ex) spellBadWord -> spell Bad Word -> ['spell', 'Bad', 'Word']
	" ex) spell_bad_word -> spell bad word -> ['spell', 'bad', 'word']
	let l:splitWord = split(substitute(a:lineOfCode, '\v[_]*([A-Z]{0,1}[a-z]+)\C', l:splitBy . "\\1", "g"), l:splitBy)

	for s in l:splitWord
		if index(l:wordsList, s) != -1
			continue
		endif

		let l:word = s
		if a:shouldBeLowercase
			let l:word = tolower(s)
		endif

		call add(l:wordsList, word)
	endfor

	return l:wordsList
endfunction

function! s:searchCurrentWord(lineStr, cword, cursorPosition)
	let [l:wordStartPosInCWord, l:cwordStartPos] = s:getTargetWordPos(a:lineStr, a:cword, a:cursorPosition)

	" 現在のカーソル位置がcwordの中で何文字目か
	let l:cursorPosInCWord = a:cursorPosition - l:wordStartPosInCWord
	" その単語がcwordの中で何文字目から始まるか
	let l:wordStartPosInCWord = l:wordStartPosInCWord - l:cwordStartPos

	let l:checkWordsList = s:codeToWords(a:cword, 0)
	let l:lastWordLength = 1
	for w in l:checkWordsList
		if l:cursorPosInCWord <= strlen(w) + l:lastWordLength
			let [l:wordStartPosInCWord, l:tmp] = s:getTargetWordPos(a:cword, w, l:cursorPosInCWord)
			return [w, l:cursorPosInCWord, l:wordStartPosInCWord]
		endif
		let l:lastWordLength += strlen(w)
	endfor

	return [get(l:checkWordsList, 0, a:cword), 0, 0]
endfunction

" 行上でどの単語にカーソルが乗っていたかを取得する
function! s:getTargetWordPos(lineStr, cword, cursorPosInCWord)
	" 単語の末尾よりもカーソルが左だった場合、cursorPosInCWord - wordIndexが単語内の何番目にカーソルがあったかが分かる
	" return [カーソルがある(spellチェックされる最小単位の)単語の開始位置, cword全体の開始位置]

	let l:wordIndexList = s:findWordIndexList(a:lineStr, a:cword)

	for targetWordStartPos in l:wordIndexList
		if targetWordStartPos <= a:cursorPosInCWord && a:cursorPosInCWord <= targetWordStartPos + strlen(a:cword)
			return [targetWordStartPos, get(l:wordIndexList, 0, 0)]
		endif
	endfor

	return [0, 0]
endfunction

function! s:findWordIndexList(lineStr, cword)
	" 単語のポジションリストを返して、ポジションスタート + 単語長の中にcurposがあればそこが現在位置

	let l:cwordLength       = strlen(a:cword)
	let l:findWordIndexList = []
	let l:lineStr           = a:lineStr

	while 1
		let l:tmpCwordPos = stridx(l:lineStr, a:cword)
		if l:tmpCwordPos < 0
			break
		endif

		call add(l:findWordIndexList, l:tmpCwordPos)
		let l:lineStr = strpart(l:lineStr, l:tmpCwordPos + l:cwordLength)
	endwhile

	return l:findWordIndexList
endfunction

function! s:getSpellSuggestList(spellSuggestList, targetWord, cword)
	" 変換候補選択用リスト
	let l:spellSuggestListForInputList = []
	" 変換候補リプレイス用リスト
	let l:spellSuggestListForReplace   = []

	let l:selectIndexStrlen = strlen(len(a:spellSuggestList))

	let i = 1
	for s in a:spellSuggestList
		let l:indexStr = printf("%" . l:selectIndexStrlen . "d", i) . ': '

		" 記号削除
		let s = substitute(s, '\.', " ", "g")

		" 2単語の場合連結
		if stridx(s, ' ') > 0
			let s = substitute(s, '\s', ' ', 'g')
			let l:suggestWords = split(s, ' ')
			let s = ''
			for w in l:suggestWords
				let s = s . s:toFirstCharUpper(w)
			endfor
		endif

		" 先頭大文字小文字
		if match(a:targetWord[0], '\v[A-Z]\C') == -1
			let s = tolower(s)
		else
			let s = s:toFirstCharUpper(s)
		endif

		call add(l:spellSuggestListForReplace, s)
		call add(l:spellSuggestListForInputList, l:indexStr . '"' . s . '"')
		let i += 1
	endfor

	return [l:spellSuggestListForInputList, l:spellSuggestListForReplace]
endfunction

function! s:cutTextWordBefore (text, word)
	let l:foundPos = stridx(a:text, a:word)

	if l:foundPos < 0
		return a:text
	endif

	let l:wordLength = len(a:word)
	return strpart(a:text, l:foundPos + l:wordLength)
endfunc

" matchIDを先頭の1単語目の場合と２単語目の場合の大文字のケースで管理する必要が有ることに注意
" 例：{'strlen': 4, 'Strlen': 5}
function! s:addMatches(windowTextList, ignoreSpellBadList, wordListForDelete, matchIDDict)
	let l:ignoreSpellBadList = a:ignoreSpellBadList
	let l:wordListForDelete  = a:wordListForDelete
	let l:matchIDDict        = a:matchIDDict

	for w in a:windowTextList
		let l:spellBadList = s:getSpellBadList(w)

		if len(l:spellBadList) == 0
			continue
		endif

		for s in l:spellBadList
			let l:lowercaseSpell = tolower(s)
			let l:firstCharUpperSpell = s:toFirstCharUpper(l:lowercaseSpell)
			let l:upperSpell = toupper(l:lowercaseSpell)

			" 新たに見つかった場合
			if index(l:ignoreSpellBadList, l:lowercaseSpell) == -1
				" 大文字小文字無視オプションを使わない(事故るのを防止するため)
				" ng: xxxAttr -> [atTr]iplePoint

				" lowercase
				" ex: xxxStrlen -> [strlen]
				let l:matchID = matchadd(g:CCSpellCheckMatchGroupName, '\v([A-Za-z]@<!)' . l:lowercaseSpell . '([a-z]@!)\C')
				execute 'let l:matchIDDict.' . l:lowercaseSpell . ' = ' . l:matchID

				" first character uppercase spell
				let l:matchID = matchadd(g:CCSpellCheckMatchGroupName, '\v' . l:firstCharUpperSpell . '([a-z]@!)\C')
				execute 'let l:matchIDDict.' . l:firstCharUpperSpell . ' = ' . l:matchID

				" UPPERCASE spell
				" 正しい単語の定数で引っかからないように注意
				" ng: xxxAttr -> [ATTR]IBUTE
				let l:matchID = matchadd(g:CCSpellCheckMatchGroupName, '\v([A-Z]@<!)' . l:upperSpell . '([A-Z]@!)\C')
				execute 'let l:matchIDDict.' . l:upperSpell . ' = ' . l:matchID

				" Management of the spelling list in the lower case
				call add(l:ignoreSpellBadList, l:lowercaseSpell)
			endif

			" 削除予定リストから単語消す
			let l:delIndex = index(l:wordListForDelete, l:lowercaseSpell)
			if l:delIndex != -1
				call remove(l:wordListForDelete, l:delIndex)
			endif

			let l:delIndex = index(l:wordListForDelete, l:firstCharUpperSpell)
			if l:delIndex != -1
				call remove(l:wordListForDelete, l:delIndex)
			endif

			let l:delIndex = index(l:wordListForDelete, l:upperSpell)
			if l:delIndex != -1
				call remove(l:wordListForDelete, l:delIndex)
			endif
		endfor
	endfor

	return [l:wordListForDelete, l:matchIDDict]
endfunction

function! s:toFirstCharUpper(lowercaseSpell)
	return toupper(a:lowercaseSpell[0]) . a:lowercaseSpell[1:-1]
endfunction

function! s:deleteMatches(wordListForDelete, matchIDDict)
	let l:matchIDDict = a:matchIDDict

	for l in a:wordListForDelete
		let l:deleteMatchID = get(l:matchIDDict, l, 0)
		if l:deleteMatchID > 0
			try
				call matchdelete(l:deleteMatchID)
			catch
				" エラー読み捨て
			finally
				let l:delIndex = index(values(l:matchIDDict), l:deleteMatchID)
				if l:delIndex != 1
					call remove(l:matchIDDict, keys(l:matchIDDict)[l:delIndex])
				endif
			endtry
		endif
	endfor

	return l:matchIDDict
endfunction

function! CCSpellCheck#check()
	if &readonly
		return
	endif

	if g:EnableCCSpellCheck == 0
		return
	endif

	call whiteList#initWhiteList()

	redir => spellSettingCapture
		silent execute "setlocal spell?"
	redir END

	" ex) '      spell' -> 'spell'
	let l:spellSetting = substitute(l:spellSettingCapture, '\v(\n|\s)\C', '', 'g')
	setlocal spell

	let l:windowTextList = getline(1, '$')

	if !exists('b:matchIDDict')
		let b:matchIDDict = {}
	endif

	let l:ignoreSpellBadList = keys(b:matchIDDict)
	let l:wordListForDelete  = keys(b:matchIDDict)

	let [l:wordListForDelete, b:matchIDDict] = s:addMatches(l:windowTextList, l:ignoreSpellBadList, l:wordListForDelete, b:matchIDDict)

	if l:spellSetting != "spell"
		setlocal nospell
	endif

	if len(l:wordListForDelete) == 0
		return
	endif

	let b:matchIDDict = s:deleteMatches(l:wordListForDelete, b:matchIDDict)
endfunction

function! CCSpellCheck#openFixList()
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z_]')
		echo "It does not match [A-Za-z_]."
		return
	endif

	let l:cursorPosition = col('.')
	let [l:targetWord, l:cursorPosInCWord, l:wordStartPosInCWord] = s:searchCurrentWord(getline('.'), l:cword, l:cursorPosition)
	let l:spellSuggestList = spellsuggest(l:targetWord, g:CCSpellCheckMaxSuggestWords)

	if len(l:spellSuggestList) == 0
		echo "No suggested words."
		return
	endif

	let [l:spellSuggestListForInputList, l:spellSuggestListForReplace] = s:getSpellSuggestList(l:spellSuggestList, l:targetWord, l:cword)

	let l:selected     = inputlist(l:spellSuggestListForInputList)
	let l:selectedWord = l:spellSuggestListForReplace[l:selected - 1]

	let l:replace  = strpart(l:cword, 0, l:wordStartPosInCWord)
	let l:replace .= l:selectedWord
	let l:replace .= strpart(l:cword, l:wordStartPosInCWord + strlen(l:targetWord), strlen(l:cword))

	" 書き換えてカーソルポジションを直す
	execute "normal ciw" . l:replace
	execute "normal b" . l:cursorPosInCWord . "l"
endfunction

function! CCSpellCheck#executeWithTargetWord(command)
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z_]')
		echo "It does not match [A-Za-z_]."
		return
	endif

	let l:cursorPosition = col('.')
	let [l:targetWord, l:cursorPosInCWord, l:wordStartPosInCWord] = s:searchCurrentWord(getline('.'), l:cword, l:cursorPosition)

	execute a:command . ' ' . tolower(l:targetWord)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
