let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* RequireJsImport call s:requirejs_import(<f-args>)
function! s:requirejs_import(...)
  if len(a:000) == 0
    let l:path = input('Path: ')
  else
    let l:path = a:000[0]
  endif

  if strlen(l:path) <= 0
    return
  endif

  let l:path = s:append_quote(s:trim_quote(l:path))
  let l:name = s:path2name(s:trim_quote(l:path))
  let l:buf = join(getline('1', '$'), "\n")
  let l:buf = requirejs_import#append_def(l:buf, l:path)
  let l:buf = requirejs_import#append_arg(l:buf, l:name)

  1,$delete
  put!=l:buf
endfunction

function! s:path2name(path)
  return requirejs_import#path2name(a:path)
endfunction

function! s:append_quote(path)
  return g:requirejs_import#quote . a:path . g:requirejs_import#quote
endfunction

function! s:trim_quote(path)
  return substitute(substitute(a:path, "'", '', 'g'), '"', '', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

