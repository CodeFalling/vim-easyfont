if !has("gui_running") || &cp || version < 700
	finish
end

let g:default_size = 12

let s:current_dir = expand("<sfile>:p:h")

function! s:SetFontAndStyle(name, style, size)
	exec "set guifont=". s:FormatFont(a:name, a:style, a:size)
endfunction

function! SetFont(name, size)
    if a:name =~? "\\<bold\\>.*\\<italic\\>" || a:name =~? "\\<italic\\>.*\\<bold\\>"
        exec "set guifont=". s:FormatFont(a:name, "bi", a:size)
    elseif a:name =~? "\\<bold\\>"
        exec "set guifont=". s:FormatFont(a:name, "b", a:size)
    elseif a:name =~? "\\<italic\\>"
        exec "set guifont=". s:FormatFont(a:name, "i", a:size)
    else
        exec "set guifont=". s:FormatFont(a:name, "", a:size)
    endif
endfunction

function! s:SetFontSize(n)
    call SetFont(GetCurrentFont(), a:n)
endfunction


function! GetCurrentFontSize()
    let font = &guifont

    if font == ""
        " Not set!
        return 12
    elseif has("gui_macvim")
        " dostuff ..
        " split(":")
    elseif has("gui_gtk2") || has("gui_gnome")
        if font =~? "\\d\\+$"
            let size = matchstr(font, " \\zs\\d\\+")
            return size
        endif
    elseif has("gui_win32") || has("gui_win64")
        if font =~? ":h\\d\\+"
			let size = matchstr(font, ":h\\zs\\d\\+") 
            return size
        endif
    endif
    " If size has been removed from guifont for some reason...
    return g:default_size
endfunction

function! EasyFont()
    let s:easyfont = GetCurrentFont()
    let s:easyfontsize = GetCurrentFontSize()
    let s:linum = line(".")
    call append(s:linum,"set g:easyfont_font='".s:easyfont."'")
    call append(s:linum+1,"set g:easyfont_size=".s:easyfontsize)
endfunction

function! GetCurrentFont()
    let font = &guifont

    if font == ""
        " Not set!
        " Probably Monospace
        return "Monospace"
    elseif has("gui_macvim")
        let name = split(font, ":")[0]
        return name
        " dostuff ..
    elseif has("gui_gtk2") || has("gui_gnome")
        if font =~? " \\d\\+$"
            let name = matchstr(font, ".* \\ze\\d\\+")
            let name = substitute(name, "\\s*$", "", "")
            return name
        else
            return font
        endif
    elseif has("gui_win32") || has("gui_win64")
        let name = split(font, ":")[0]
        let name = substitute(name, "_", " ", "g")
        return name
    endif
    return font
endfunction

function! s:FormatFont(name, style, size)
    if has("gui_macvim")
        let name = substitute(a:name, " ", "\\\\ ", "g")
        return name . ":h" . a:size
    elseif has("gui_gtk2") || has("gui_gnome")
        let font = substitute(a:name, " Bold", "", "g")
        let font = substitute(font, " Italic", "", "g")
        let expanded_style = s:ExpandStyle(a:style)
        if expanded_style != ""
            let font = font . " " . expanded_style . " " . a:size
        else
            let font = font . " " . a:size
        endif
        return substitute(font, " ", "\\\\ ", "g")
    elseif has("gui_win32") || has("gui_win64")
        let name = substitute(a:name, " ", "_", "g")[:30]
        return name . ":" . a:style . ":h" . a:size
    else
        " OH NO Console!
    endif
endfunction

if has("gui_running")
	if exists("g:easyfont_font")
		if exists("g:easyfont_size")
			call SetFont(g:easyfont_font, g:easyfont_size)
		else
			call SetFont(g:easyfont_font, g:default_size)
		endif
	endif
endif

command! -nargs=0 EasyFont call EasyFont()
