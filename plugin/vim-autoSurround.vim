"code
function! AutoSurround(start_char, end_char)
  " Check if there is an active visual selection
  if visualmode() == "v"
    " Get the the start and end position of the selection
    let [start_line, start_col] = getpos("'<")[1:2]
    let [end_line, end_col] = getpos("'>")[1:2]
    let final_line = getline(end_line)
    let first_line = getline(start_line)
    if len(first_line) == 0
      let start_line += 1
      let start_col = 1
    endif
    if len(final_line) == 0
      let end_line -= 1
      let final_line = getline(end_line)
      let end_col = len(final_line)
    endif
    if end_col == len(final_line) + 1 
      call cursor(end_line, end_col - 1)
      let end_col -= 1
    endif
    " Get the selected text
    let lines = []
    let selected_text = ''
    if start_line == end_line 
      let selected_text = getline(start_line, end_line)
    else
      for line_number in range(start_line, end_line)
        let line_content = getline(line_number)
        call add(lines, [line_number, line_content])
      endfor
    endif
    if len(lines) > 0
      for i in range(0, len(lines) - 1)
        if i == 0
          let previous = start_col == 1 ? '' : lines[0][1][0 : start_col - 2]
          let lines[0][1] = previous . a:start_char . lines[0][1][start_col - 1:]
        elseif i == len(lines) - 1
          let lines[i][1] = lines[i][1][: end_col - (&selection == 'inclusive' ? 1 : 2)] . a:end_char . lines[i][1][end_col:]
        endif
        call setline(lines[i][0], lines[i][1])
      endfor
    endif
    if type(selected_text) == 3
      let selected_text[-1] = selected_text[-1][: end_col - (&selection == 'inclusive' ? 1 : 2)]
      let selected_text[0] = selected_text[0][start_col - 1:]
      let selected_text = join(selected_text, "\n")
      let selected_text = a:start_char . selected_text . a:end_char
      " Replace the selection with the modified text
      call setline(start_line, strpart(getline(start_line), 0, start_col - 1) . selected_text . strpart(getline(end_line), end_col))
    endif
    call cursor(start_line, start_col + 1)
    normal! v
    let number = len(lines) > 0 ? 0 : 1
    call cursor(end_line, end_col + number)
  endif
endfunction

"mappings
vnoremap <silent> < :<c-u> call AutoSurround("<", ">")<CR>
vnoremap <silent> > :<c-u> call AutoSurround("<", ">")<CR>
vnoremap <silent> ( :<c-u> call AutoSurround("(", ")")<CR>
vnoremap <silent> ) :<c-u> call AutoSurround("(", ")")<CR>
vnoremap <silent> { :<c-u> call AutoSurround("{", "}")<CR>
vnoremap <silent> } :<c-u> call AutoSurround("{", "}")<CR>
vnoremap <silent> [ :<c-u> call AutoSurround("[", "]")<CR>
vnoremap <silent> ] :<c-u> call AutoSurround("[", "]")<CR>
vnoremap <silent> ' :<c-u> call AutoSurround("'", "'")<CR>
vnoremap <silent> " :<c-u> call AutoSurround('"', '"')<CR>
vnoremap <silent> ` :<c-u> call AutoSurround('`', '`')<CR>

