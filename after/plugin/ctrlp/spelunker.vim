let s:save_cpo = &cpo
set cpo&vim

" command define after ctrlp load
command! CtrlPSpell :call ctrlp#init(ctrlp#spelunker#id())

let &cpo = s:save_cpo
unlet s:save_cpo
