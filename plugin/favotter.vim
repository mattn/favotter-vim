function! s:ShowFavotter(...)
  let user = a:0 > 0 ? a:1 : exists('g:favotter_user') ? g:favotter_user : ''
  if len(user) == 0
    echohl WarningMsg
    echo "Usage:"
    echo "  :Favotter [user]"
    echo "  you can set g:favotter_user to specify default user"
    echohl None
    return
  endif
  let res = webapi#http#get("http://favotter.net/user/".user)
  let res.content = iconv(res.content, 'utf-8', &encoding)
  let res.content = substitute(res.content, '<\(br\|meta\|link\|hr\)\s*>', '<\1/>', 'g')
  let res.content = substitute(res.content, '<img\([^>]*\)>', '<img\1/>', 'g')
  let dom = webapi#xml#parse(res.content)
  for item in dom.findAll({'class': 'entry xfolkentry hentry  '})
    let tweet = item.find('span')
    let text = substitute(tweet.value(), "\n", " ", "g")
    let text = substitute(text, "^ *", "", "")
    echohl Function
    echo text
    echohl None
    let favotters = item.find('span', {"class": "favotters"}).childNodes('a')
    let line = 'FAV:'
    for favotter in favotters
      let line .= " " . favotter.childNode('img').attr['alt']
    endfor
    echohl Statement
    echo line
    echohl None
    echo "\n"
  endfor
endfunction

command! -nargs=? Favotter call <SID>ShowFavotter(<f-args>)
