[![CircleCI](https://circleci.com/gh/kamykn/spelunker.vim/tree/master.svg?style=svg)](https://circleci.com/gh/kamykn/spelunker.vim/tree/master)

# Spelunker.vim

Spelunker.vim is a plugin that improves [Vim's spell checking function](https://vim-jp.org/vimdoc-en/options.html#'spell'). It provides a smarter way to correct spelling mistakes by supporting _PascalCase_, _camelCase_ and _snake_case_. Each programming language (JavaScript/TypeScript, PHP, Ruby, CSS, HTML and Vim Script) has an allowlist.

## 1 Installation

#### vim-plug

```
Plug 'kamykn/spelunker.vim'
```

#### NeoBundle

```
NeoBundle 'kamykn/spelunker.vim'
```

## 2 Usage

### 2.1 Settings

Turn off Vim's `spell` as it highlights the same words.

```
set nospell
```

### 2.2 Options

Spelunker.vim offers the following configuration options:

```vim
" Enable spelunker.vim. (default: 1)
" 1: enable
" 0: disable
let g:enable_spelunker_vim = 1

" Enable spelunker.vim on readonly files or buffer. (default: 0)
" 1: enable
" 0: disable
let g:enable_spelunker_vim_on_readonly = 0

" Check spelling for words longer than set characters. (default: 4)
let g:spelunker_target_min_char_len = 4

" Max amount of word suggestions. (default: 15)
let g:spelunker_max_suggest_words = 15

" Max amount of highlighted words in buffer. (default: 100)
let g:spelunker_max_hi_words_each_buf = 100

" Spellcheck type: (default: 1)
" 1: File is checked for spelling mistakes when opening and saving. This
" may take a bit of time on large files.
" 2: Spellcheck displayed words in buffer. Fast and dynamic. The waiting time
" depends on the setting of CursorHold `set updatetime=1000`.
let g:spelunker_check_type = 1

" Highlight type: (default: 1)
" 1: Highlight all types (SpellBad, SpellCap, SpellRare, SpellLocal).
" 2: Highlight only SpellBad.
" FYI: https://vim-jp.org/vimdoc-en/spell.html#spell-quickstart
let g:spelunker_highlight_type = 1

" Option to disable word checking.
" Disable URI checking. (default: 0)
let g:spelunker_disable_uri_checking = 1

" Disable email-like words checking. (default: 0)
let g:spelunker_disable_email_checking = 1

" Disable account name checking, e.g. @foobar, foobar@. (default: 0)
" NOTE: Spell checking is also disabled for JAVA annotations.
let g:spelunker_disable_account_name_checking = 1

" Disable acronym checking. (default: 0)
let g:spelunker_disable_acronym_checking = 1

" Disable checking words in backtick/backquote. (default: 0)
let g:spelunker_disable_backquoted_checking = 1

" Disable default autogroup. (default: 0)
let g:spelunker_disable_auto_group = 1

" Create own custom autogroup to enable spelunker.vim for specific filetypes.
augroup spelunker
  autocmd!
  " Setting for g:spelunker_check_type = 1:
  autocmd BufWinEnter,BufWritePost *.vim,*.js,*.jsx,*.json,*.md call spelunker#check()

  " Setting for g:spelunker_check_type = 2:
  autocmd CursorHold *.vim,*.js,*.jsx,*.json,*.md call spelunker#check_displayed_words()
augroup END

" Override highlight group name of incorrectly spelled words. (default:
" 'SpelunkerSpellBad')
let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'

" Override highlight group name of complex or compound words. (default:
" 'SpelunkerComplexOrCompoundWord')
let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'

" Override highlight setting.
highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#9e9e9e
highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
```

<img src="https://user-images.githubusercontent.com/7608231/48882590-71e57600-ee5e-11e8-9b1a-16191c1ac3b9.png" width=540>

## 3 Commands

### 3.1 Correct wrong spell.

#### `ZL / Zl`

Correct misspelled words with a list of suggestions.

```vim
" Correct all words in buffer.
ZL

" Correct word under cursor.
Zl
```

An example of `ZL` in action:  
<img src="https://user-images.githubusercontent.com/7608231/69977024-516df280-156d-11ea-90df-22b662e4c9a7.gif" width=400>

If you are using nvim version 0.4 or higher, you need to install `kamykn/popup-menu.nvim`.

```
" vim-plug
Plug 'kamykn/popup-menu.nvim'

" NeoBundle
NeoBundle 'kamykn/popup-menu.nvim'
```

If you are using old vim/nvim, this function using [inputlist()](https://vim-jp.org/vimdoc-en/eval.html#inputlist()) instead of [popup_menu()](https://vim-jp.org/vimdoc-en/popup.html#popup_menu()).  
(Before vim version 8.1.1391.)

<img src="https://user-images.githubusercontent.com/7608231/48882608-89246380-ee5e-11e8-88e3-958b47353ddb.gif" width=540>

#### `ZC / Zc`

Correct misspelled words by inserting a correction.

```vim
" Correct all words in buffer.
ZC

" Correct word under cursor.
Zc
```

An example of `ZC` in action:

<img src="https://user-images.githubusercontent.com/7608231/48882594-7c077480-ee5e-11e8-83fe-68691bb13823.gif" width=540>

#### `ZF / Zf`

Correct misspelled words by picking first item on suggestion list. (This is like "I'm feeling lucky!")

```vim
" Correct all words in buffer.
ZF

" Correct word under cursor.
Zf
```

An example of `ZF` in action:

<img src="https://user-images.githubusercontent.com/7608231/50171177-16ab8400-0335-11e9-8eae-6ce1b249babd.gif" width=540>

### 3.2 Add words to spellfile

Spelunker.vim use Vim `spell` commands as default. You can also add word under cursor to `spellfile` with the following commands:

```vim
" Add selected word to spellfile
" zg =>
Zg

" zw =>
Zw

" zug =>
Zug

" zuw =>
Zuw

" Add selected word to the internal word list
" zG =>
ZG

" zW =>
ZW

" zuG =>
ZUG

" zuW =>
ZUW
```

Read http://vim-jp.org/vimdoc-en/spell.html#zg for more information.

### 3.3 Add all misspelled words in buffer to spellfile.

Run the following command to add all misspelled words to the `spellfile`:

```vim
:SpelunkerAddAll
```

### 3.4 Jump cursor to misspelled words.
#### `ZN / ZP`
```
" Jump cursor to next misspelled words.
ZN

" Jump cursor to previous misspelled words.
ZP
```

This function is depend on [wrapscan](https://vim-jp.org/vimdoc-en/options.html#'wrapscan') setting.

An example of `ZN`/`ZP` in action:

<img src="https://user-images.githubusercontent.com/7608231/65333922-52dd7f00-dbfc-11e9-93a4-39f239196a51.gif" width=540>

### 3.5 Toggle on and off.
#### `ZT / Zt`
```vim
" Toggle to enable or disable.
ZT

" Toggle to enable or disable only the current buffer.
Zt
```

```
" The initial state depends on the value of g:enable_spelunker_vim.
" 1: Default on.
" 0: Default off.
" g:enable_spelunker_vim = 1
```

<img src="https://user-images.githubusercontent.com/7608231/65375352-6a396c80-dccf-11e9-9295-1dd061140a78.gif" width=540>

### 3.6 CtrlP Extention
#### CtrlPSpell

[ctrlp](https://github.com/ctrlpvim/ctrlp.vim) is fuzzy finder.

Need setting, see below:

```vim
" ctrlp ext
let g:ctrlp_extensions = get(g:, 'ctrlp_extensions', [])
      \ + ['spelunker']
```

Start `:CtrlPSpell` then list up bad spell.
Select word to jump first find this bad spell.
Check the context and suitability and act (fix or add, etc...).

## 4 Allowlist

### 4.1 General programming allowlist

Commonly used words are set to be excluded. Compound words and complex words may be highlighted incorrectly, but another highlight group (SpelunkerComplexOrCompoundWord) is being adapted.

Please see the code for details: [white_list.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list.vim)

### 4.2 Programming language specific allowlist

JavaScript/TypeScript, PHP, Ruby, CSS, HTML and Vim Script is currently supported. More support will be added in the future.

| Programming language  | White list                                                                                                                               |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| CSS, LESS, SCSS(Sass) | [white_list_css.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_css.vim)               |
| HTML                  | [white_list_html.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_html.vim)             |
| JavaScript/TypeScript | [white_list_javascript.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_javascript.vim) |
| PHP                   | [white_list_php.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_php.vim)               |
| Ruby                  | [white_list_ruby.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_ruby.vim)             |
| Vim Script            | [white_list_vim.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_vim.vim)               |

### 4.3 User's allowlist.

You can add words to your user specific allowlist:

```vim
let g:spelunker_white_list_for_user = ['kamykn', 'vimrc']
```
