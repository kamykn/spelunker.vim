# Spelunker.vim

Spelunker.vim is a plugin that improves [Vim's spell checking function](https://vim-jp.org/vimdoc-en/options.html#'spell'). It provides a smarter way to correct spelling mistakes by supporting _PascalCase_, _camelCase_ and _snake_case_. Each programming language (JavaScript/TypeScript, PHP, Ruby, CSS, HTML and Vim Script) have a whitelist.

## 1 Installation

### vim-plug

```
Plug 'kamykn/spelunker.vim'
```

### NeoBundle

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
let g:enable_spelunker_vim = 1

" Check spelling for words longer than set characters. (default: 4)
let g:spelunker_target_min_char_len = 4

" Max amount of word suggestions. (default: 15)
let g:spelunker_max_suggest_words = 15

" Max amount of highlighteds words in buffer. (default: 100)
let g:spelunker_max_hi_words_each_buf = 100

" Spellcheck type: (default: 1)
" 1: File is checked for spelling mistakes when opening and saving. This
" may take a bit of time on large files.
" 2: Spellcheck displayed words in buffer. Fast and dynamic. The waiting time
" depeds on the setting of CursorHold `set updatetime=1000`.
g:spelunker_check_type = 1

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

" Override highlight group name of incorrectly spelledc words. (default:
" 'SpelunkerSpellBad')
let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'

" Override highlight group name of complex or compound words. (default:
" 'SpelunkerComplexOrCompoundWord')
let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'

" Override highlight setting.
highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#9e9e9e
highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
```

![spelunker_highlight_group](https://user-images.githubusercontent.com/7608231/48882590-71e57600-ee5e-11e8-9b1a-16191c1ac3b9.png)

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

![spelunker_zl](https://user-images.githubusercontent.com/7608231/48882608-89246380-ee5e-11e8-88e3-958b47353ddb.gif)

#### `ZC / Zc`

Correct misspelled words by inserting a correction.

```vim
" Correct all words in buffer.
ZC

" Correct word under cursor.
Zc
```

An example of `ZC` in action:

![spelunker_zc](https://user-images.githubusercontent.com/7608231/48882594-7c077480-ee5e-11e8-83fe-68691bb13823.gif)

#### `ZF / Zf`

Correct misspelled words by picking first item on suggestion list. (This is like "I'm feeling lucky!")

```vim
" Correct all words in buffer.
ZF

" Correct word under cursor.
Zf
```

An example of `ZF` in action:

![spelunker_zf](https://user-images.githubusercontent.com/7608231/50171177-16ab8400-0335-11e9-8eae-6ce1b249babd.gif)

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

## 4 Whitelist

### 4.1 General programming whitelist

Commonly used words are set to be excluded. Compound words and complex words may be highlighted incorrectly, but another highlight group (SpelunkerComplexOrCompoundWord) is being adapted.

Please see the code for details: https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list.vim

### 4.2 Programming language specific whitelist

JavaScript/TypeScript, PHP, Ruby, CSS, HTML and Vim Script is currently supported. More support will be added in the future.

| Programming language  | White list                                                                                                                               |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| CSS, LESS, SCSS(Sass) | [white_list_css.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_css.vim)               |
| HTML                  | [white_list_html.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_html.vim)             |
| JavaScript/TypeScript | [white_list_javascript.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_javascript.vim) |
| PHP                   | [white_list_php.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_php.vim)               |
| Ruby                  | [white_list_ruby.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_ruby.vim)             |
| Vim Script            | [white_list_vim.vim](https://github.com/kamykn/spelunker.vim/blob/master/autoload/spelunker/white_list/white_list_vim.vim)               |

### 4.3 User's whitelist.

You can add words to your user specific whitelist:

```vim
let g:spelunker_white_list_for_user = ['kamykn', 'vimrc']
```
