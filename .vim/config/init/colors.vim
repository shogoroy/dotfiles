if has("unix")
  let s:os = system("uname")
  if s:os == "Darwin\n"
    colorscheme gotham
  elseif s:os == "Linux\n"
    colorscheme monokai
  endif
endif
