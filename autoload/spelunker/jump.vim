" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#jump#jump_matched(is_search_next)
    let l:spell_bad_list = []
    let l:current_line = line(".")
    let l:start_line = l:current_line

    let l:end_line = s:get_end_of_line(a:is_search_next)
    let l:move_next = s:get_move_next(a:is_search_next)

    " 表示範囲だけhighlightしている場合もあるので、1行ずつチェックしていく
    while 1
        let l:matched_pos = -1

        if s:break_if_end_of_line(a:is_search_next, l:current_line, l:end_line) == 1
            break
        endif

        let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:current_line, -1)

        if len(l:spell_bad_list) > 0
            for word in l:spell_bad_list
                let l:pattern = spelunker#matches#get_match_pattern(word)

                let l:start_pos = s:get_start_pos(l:start_line, l:current_line, a:is_search_next)
                let l:tmp_matched_pos = s:get_matched_pos(l:current_line, l:pattern, l:start_pos, a:is_search_next)

                let l:matched_pos = s:get_match_pos(l:matched_pos, l:tmp_matched_pos, a:is_search_next)
            endfor
        endif

        if l:matched_pos >= 0
            break
        endif

        let l:current_line = l:current_line + l:move_next
    endwhile

    if l:matched_pos >= 0
        call cursor(l:current_line, l:matched_pos + 1)
    endif
endfunction

function s:get_matched_pos(current_line, pattern, start_pos, is_search_next)
    if a:is_search_next == 1
        return match(getline(a:current_line), a:pattern, a:start_pos)
    endif

    " 逆順の場合、最後にマッチするポジションを返す
    let l:last_matched_pos = -1
    while 1
        let l:match_start_pos = l:last_matched_pos + 1
        let l:matched_pos = match(getline(a:current_line), a:pattern, l:match_start_pos)

        if a:start_pos - 1 < l:matched_pos || l:matched_pos == -1
            break
        endif

        let l:last_matched_pos = l:matched_pos
    endwhile

    return l:last_matched_pos
endfunction

function s:get_start_pos(start_line, current_line, is_search_next)
    if a:start_line == a:current_line
        let l:start_pos = col('.')
        if a:is_search_next == 1
            let l:start_pos = l:start_pos + 1
        else
            let l:start_pos = l:start_pos - 1
        endif
    else
        if a:is_search_next == 1
            let l:start_pos = 0
        else
            let l:start_pos = strchars(getline(a:current_line))
        endif
    endif

    return l:start_pos
endfunction

function s:break_if_end_of_line(is_search_next, current_line, end_line)
    if a:is_search_next == 1
        if a:current_line > a:end_line
            return 1
        endif
    else
        if a:current_line < a:end_line
            return 1
        endif
    endif

    return 0
endfunction

function s:get_end_of_line(is_search_next)
    if a:is_search_next == 1
        return line("w$")
    else
        return 0
    endif
endfunction

function s:get_move_next(is_search_next)
    if a:is_search_next == 1
        return 1
    else
        return -1
    endif
endfunction

function s:get_match_pos(matched_pos, tmp_matched_pos, is_search_next)
    if a:is_search_next == 1
        let l:matched_pos = a:matched_pos >= 0 ?
                    \ min([a:matched_pos, a:tmp_matched_pos]) :
                    \ a:tmp_matched_pos
    else
        let l:matched_pos = a:matched_pos >= 0 ?
                    \ max([a:matched_pos, a:tmp_matched_pos]) :
                    \ a:tmp_matched_pos
    endif

    return l:matched_pos
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
