" Checking camel case words spelling.
" Version 1.0.0
" Author kmszk
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:getSpellBadList(text)
	let l:lineForFindCamelCase = a:text
	let l:spellBadList         = []

	while 1
		" キャメルケースとパスカルケースの抜き出し
		let l:matchCamelCaseWord = matchstr(l:lineForFindCamelCase, '\v([A-Za-z]@<!)[A-Za-z]+[A-Z][A-Za-z]+\C')
		if l:matchCamelCaseWord == ""
			break
		endif

		let l:lineForFindCamelCase = s:cutTextWordBefore(l:lineForFindCamelCase, l:matchCamelCaseWord)

		let l:wordList = s:camelCaseToWords([l:matchCamelCaseWord])
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

functio! s:filterSpellBadList(wordList)
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

function! s:camelCaseToWords(camelCaseWordList)
	let l:splitBy   = ' '
	let l:wordsList = []

	for c in a:camelCaseWordList
		let l:splitWord = split(substitute(c, '\v([A-Z][a-z]*)\C', l:splitBy . "\\1", "g"), l:splitBy)

		for s in l:splitWord
			if index(l:wordsList, s) != -1
				continue
			endif

			call add(l:wordsList, s)
		endfor
	endfor

	return l:wordsList
endfunction

function! s:searchCurrentWordOnCamelCase(lineStr, cword, currentColPos)
	" 単語の末尾よりもカーソルが左だった場合、currentColPos-wordIndexが単語内の何番目にカーソルがあったかが分かる
	let [l:wordPos, l:cwordPos] = s:getCamelCaseWordPos(a:lineStr, a:cword, a:currentColPos)

	" 現在のカーソル位置がcwordの中で何文字目か
	let l:colPosInCWord = a:currentColPos - l:wordPos
	" その単語がcwordの中で何文字目から始まるか
	let l:wordStartPosInCWord = l:wordPos - l:cwordPos

	let l:checkWordsList = s:camelCaseToWords([a:cword])
	let l:lastWordLength = 0
	for w in l:checkWordsList
		if l:colPosInCWord <= strlen(w) + l:lastWordLength
			let [l:wordPos, l:tmp] = s:getCamelCaseWordPos(a:cword, w, l:colPosInCWord)
			return [w, l:colPosInCWord, l:wordPos]
		endif
		let l:lastWordLength += strlen(w)
	endfor

	return [get(l:checkWordsList, 0, a:cword), 0, 0]
endfunction

function! s:getCamelCaseWordPos(lineStr, cword, currentColPos)
	" 単語の末尾よりもカーソルが左だった場合、currentColPos-wordIndexが単語内の何番目にカーソルがあったかが分かる
	" return [キャメルケース上のカーソルがある単語の開始位置, cword全体の開始位置]

	let l:wordIndexList = s:findWordIndexList(a:lineStr, a:cword)

	for i in l:wordIndexList
		if i <= a:currentColPos && a:currentColPos <= i + strlen(a:cword)
			return [i, get(l:wordIndexList, 0, 0)]
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

function! s:getSpellSuggestList(spellSuggestList, currentCamelCaseWord, cword)
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
		if match(a:currentCamelCaseWord[0], '\v[A-Z]\C') == -1
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

			if index(l:ignoreSpellBadList, l:lowercaseSpell) == -1
				" lowercase
				let l:matchID = matchadd(g:CCSpellCheckMatchGroupName, '\v([A-Za-z]@<!)' . l:lowercaseSpell . '([A-Z]@=)\C')
				execute 'let l:matchIDDict.' . l:lowercaseSpell . ' = ' . l:matchID

				" first character uppercase spell
				let l:firstCharUpperSpell = s:toFirstCharUpper(l:lowercaseSpell)
				let l:matchID = matchadd(g:CCSpellCheckMatchGroupName, '\v' . l:firstCharUpperSpell . '([a-z]@!)\C')
				execute 'let l:matchIDDict.' . l:firstCharUpperSpell . ' = ' . l:matchID

				" Management of the spelling list in the lower case
				call add(l:ignoreSpellBadList, l:lowercaseSpell)
			endif

			let l:delIndex = index(l:wordListForDelete, l:lowercaseSpell)
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

	setlocal spell

	let l:windowTextList = getline(1, '$')

	if !exists('b:matchIDDict')
		let b:matchIDDict = {}
	endif

	let l:ignoreSpellBadList = keys(b:matchIDDict)
	let l:wordListForDelete  = keys(b:matchIDDict)

	let [l:wordListForDelete, b:matchIDDict] = s:addMatches(l:windowTextList, l:ignoreSpellBadList, l:wordListForDelete, b:matchIDDict)

	if len(l:wordListForDelete) == 0
		return
	endif

	let b:matchIDDict = s:deleteMatches(l:wordListForDelete, b:matchIDDict)
endfunction

function! CCSpellCheck#OpenFixList()
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z]')
		echo "It does not match [A-Za-z]."
		return
	endif

	let [l:currentCamelCaseWord, l:colPosInCWord, l:wordStartPosInCWord] = s:searchCurrentWordOnCamelCase(getline('.'), l:cword, col('.'))
	let l:spellSuggestList = spellsuggest(l:currentCamelCaseWord, g:CCSpellCheckMaxSuggestWords)

	if len(l:spellSuggestList) == 0
		echo "No suggested words."
		return
	endif

	let [l:spellSuggestListForInputList, l:spellSuggestListForReplace] = s:getSpellSuggestList(l:spellSuggestList, l:currentCamelCaseWord, l:cword)

	let l:selected     = inputlist(l:spellSuggestListForInputList)
	let l:selectedWord = l:spellSuggestListForReplace[l:selected - 1]

	let l:replace  = strpart(l:cword, 0, l:wordStartPosInCWord)
	let l:replace .= l:selectedWord
	let l:replace .= strpart(l:cword, l:wordStartPosInCWord + strlen(l:currentCamelCaseWord), strlen(l:cword))

	" 書き換えてカーソルポジションを直す
	execute "normal ciw" . l:replace
	execute "normal b" . l:colPosInCWord . "l"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
