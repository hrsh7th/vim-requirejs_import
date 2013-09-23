let s:save_cpo = &cpo
set cpo&vim

let g:requirejs_import#debug = get(g:, 'requirejs_import#debug', 0)
let g:requirejs_import#quote = get(g:, 'requirejs_import#quote', "'")

function! requirejs_import#import(buf, path)
  let l:buf = a:buf
  let l:path = requirejs_import#append_quote(requirejs_import#trim_quote(a:path))
  let l:name = requirejs_import#path2name(l:path)
  let l:buf = requirejs_import#append_def(l:buf, l:path)
  let l:buf = requirejs_import#append_arg(l:buf, l:name)
  return l:buf
endfunction

function! requirejs_import#append_def(buf, text)
  if requirejs_import#is_first_def(a:buf)
    let l:buf = requirejs_import#clean_def(a:buf)
    return substitute(l:buf, requirejs_import#regex([
          \   [':BEFORE_DEF:', '\['],
          \   [':OTHER:'],
          \   ['\]', ':OTHER:']
          \ ]), printf('\1%s\3', a:text), 'g')
  else
    if !requirejs_import#is_def_multiline(a:buf)
      return substitute(a:buf, requirejs_import#regex([
            \   [':BEFORE_DEF:', '\[', ':OTHER:'],
            \   ['\]', ':OTHER:']
            \ ]), printf('\1, %s\2', a:text), 'g')
    else
      return substitute(a:buf, requirejs_import#regex([
            \   [':BEFORE_DEF:', '\['],
            \   ['[^[]\+'],
            \   ["\n"],
            \   ['\]', ':OTHER:']
            \ ]), printf('\1\2,\n' . requirejs_import#get_indent() . '%s\n\4', a:text), 'g')
    endif
  endif
endfunction
function! requirejs_import#clean_def(buf)
  return substitute(a:buf, requirejs_import#regex([
        \   [':BEFORE_DEF:', '\['],
        \   [':OTHER:'],
        \   ['\]', ':OTHER:']
        \ ]), '\1\3', 'g')
endfunction

function! requirejs_import#append_arg(buf, text)
  if requirejs_import#is_first_arg(a:buf)
    let l:buf = requirejs_import#clean_arg(a:buf)
    return substitute(l:buf, requirejs_import#regex([
          \   [':BEFORE_ARG:', '('],
          \   [':OTHER:'],
          \   [')', ':OTHER:']
          \ ]), printf('\1%s\3', a:text), 'g')
  else
    if !requirejs_import#is_arg_multiline(a:buf)
      return substitute(a:buf, requirejs_import#regex([
            \   [':BEFORE_ARG:', '(', ':OTHER:'],
            \   [')', ':OTHER:']
            \ ]), printf('\1, %s\2', a:text), 'g')
    else
      return substitute(a:buf, requirejs_import#regex([
            \   [':BEFORE_ARG:', '('],
            \   ['[^(]\+'],
            \   ["\n"],
            \   [')', ':OTHER:']
            \ ]), printf('\1\2,\n' . requirejs_import#get_indent() . '%s\n\4', a:text), 'g')
    endif
  endif
endfunction
function! requirejs_import#clean_arg(buf)
  return substitute(a:buf, requirejs_import#regex([
        \   [':BEFORE_ARG:', '('],
        \   [':OTHER:'],
        \   [')', ':OTHER:']
        \ ]), '\1\3', 'g')
endfunction

function! requirejs_import#is_first_def(buf)
  return match(a:buf, requirejs_import#regex([
        \   ':BEFORE_DEF:', '\[', '\]'
        \ ])) >= 0
endfunction

function! requirejs_import#is_first_arg(buf)
  return match(a:buf, requirejs_import#regex([
        \   ':BEFORE_ARG:', '(', ')'
        \ ])) >= 0
endfunction

function! requirejs_import#is_def_multiline(buf)
  return match(a:buf, requirejs_import#regex([
        \   [':BEFORE_DEF:', '\['],
        \   ["\n", ':OTHER:', "\n"],
        \   ['\]']
        \ ])) >= 0
endfunction

function! requirejs_import#is_arg_multiline(buf)
  return match(a:buf, requirejs_import#regex([
        \   [':BEFORE_ARG:', '('],
        \   ["\n", ':OTHER:', "\n"],
        \   [')']
        \ ])) >= 0
endfunction

let s:p = {
      \ ':BLANK:': '\_\s\{-}',
      \ ':OTHER:': '\_.\{-}',
      \ ':BEFORE_DEF:': join(['\_.\{-}', 'define', '('], '\_\s\{-}'),
      \ ':BEFORE_ARG:': join(['\_.\{-}', 'define', '(', '\[', '\_.\{-}', '\]', ',', 'function'], '\_\s\{-}')
      \ }

function! requirejs_import#regex(words)
  let l:_ = []
  for l:word in s:regex(a:words)
    if type(l:word) == type([])
      call add(l:_, '\(' . join(l:word, s:p[':BLANK:']) . '\)')
    else
      call add(l:_, l:word)
    endif
  endfor
  if g:requirejs_import#debug
    echo 'REGEX: ' . join(l:_, s:p[':BLANK:'])
  endif
  return join(l:_, s:p[':BLANK:'])
endfunction

function! s:regex(words)
  let l:_ = []
  for l:word in a:words
    if type(l:word) == type([])
      call add(l:_, s:regex(l:word))
    else
      if exists("s:p['" . l:word . "']")
        call add(l:_, s:p[l:word])
      else
        call add(l:_, l:word)
      endif
    endif
  endfor
  return l:_
endfunction

function! requirejs_import#path2name(path)
  let l:path = requirejs_import#trim_quote(a:path)
  let l:path = substitute(l:path, '\/$', '', 'g')
  return substitute(l:path, '^.*\/\(.*\)$', '\1', 'g')
endfunction

function! requirejs_import#append_quote(path)
  return g:requirejs_import#quote . a:path . g:requirejs_import#quote
endfunction

function! requirejs_import#trim_quote(path)
  return substitute(substitute(a:path, "'", '', 'g'), '"', '', 'g')
endfunction

function! requirejs_import#get_indent()
  if &expandtab
    if exists('&softtabstop') && !exists('&tabstop')
      return repeat(' ', &softtabstop)
    endif
    if !exists('&softtabstop') && exists('&tabstop')
      return repeat(' ', &tabstop)
    endif
    if !exists('&softtabstop') && !exists('&tabstop')
      return '  '
    endif
    if exists('&softtabstop') && exists('&tabstop')
      return repeat(' ', &softtabstop)
    endif
  else
    return "\t"
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

