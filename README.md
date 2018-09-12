# CCSpellCheck.vim
CCSpellCheck.vim is checking camelcase word spell.

## 1.Installation
### Installation with NeoBundle
```
NeoBundle 'kamykn/CCSpellCheck.vim'
```

## 2.Useage
### 2.i. Options.
CCSpellChecker offers the following options.

```
" Use CCSpellCheck.vim. (1 / 0) (default 1)
let g:CCSpellCheckEnable = 1

" Setting for start checking min length of character. (default 4)
let g:CCSpellCheckMinCharacterLength = 4

" Setting for max suggest words list length. (default 50)
let g:CCSpellCheckMaxSuggestWords = 50


" Override highlight group name. (default 'CCSpellBad')
let g:CCSpellCheckMatchGroupName = 'CCSpellBad'

" Override highlight setting.
highlight CCSpellBad cterm=reverse ctermfg=magenta gui=reverse guifg=magenta
```

### 2.ii. Correct bad spell.
Move the cursor over the wrong spelling and enter the following commands

```
Z=
```

### 2.iii. Add word as good spell list.
Add the selected word in Visual-mode with the following command.
CCSpellcheck use 'spell' commands provided by vim as default.

FYI:
http://vim-jp.org/vimdoc-en/spell.html#zg

```
# Add selected word to spellfile
# => zg
Zg

# => zw
Zw

# => zug
Zug

# => zuw
Zuw

# Add selected word to the internal word list
# => zG
ZG

# => zW
ZW

# => zuG
ZUG

# => zuW
ZUW
```

## 3.Articles (in Japanese)
Vimでキャメルケースのスペルチェックをするプラグインを作った
https://qiita.com/kamykn/items/ce536aff00f44960e811
