"
" mainview-subview.vim: better support for vim on two monitors 
" This fork allows you to run one vim view as your "main" vim,
" and another session named EXPANDEDVIEW to show a full-screen view
" of the current vim window.
"
"
" Author: Bernt R. Brenna, Armin Samii
"
"
" Instructions
" ============
"
" Start a number of vim servers and source the script:
"
" $ vim <filename>
" :source mainview-subview.vim
" $ vim --servername EXPANDEDVIEW
" :source mainview-subview.vim
"
" When you move to a different vim window, that  file opens in the subview.
"
" Running the test suite TODO outdated
" ======================
"
" $ cd tests
" $ ./run
"

function! s:servers()
    return split(serverlist(), "\n")
endfunction


function! s:other_servers() 
    return filter(s:servers(), 'v:val != "' . v:servername . '"')
endfunction

function! Remote_Open(filename)
    " This function is called by the other vim instance
    echom "Remote_Open.filename: " . a:filename

	let g:isRemotelyOpening = 1
    execute "edit " . a:filename
	let g:isRemotelyOpening = 0
    redraw

    return "Server " . v:servername . " opened file " . a:filename
endfunction

function! Open_Read_Only()
	if g:isRemotelyOpening == 1
		let v:swapchoice = "o"
	endif
endfunction

function! Load_Expanded_View()
	if v:servername ==# 'EXPANDEDVIEW'
		echom "You should not be opening files here. This is a secondary view."
		return
	endif

    for server in s:other_servers()
        if server ==# 'EXPANDEDVIEW'
            echom "Found the expanded server and trying to open " . expand("%:p")
            let remexpr = 'Remote_Open("' . expand("%:p") . '")'
			echom "start"
            echom remote_expr(server, remexpr)
			echom "fin"
        endif
    endfor
endfunction

let g:isRemotelyOpening = 0
autocmd! SwapExists *
autocmd SwapExists * call Open_Read_Only()
autocmd! WinEnter *
autocmd WinEnter * call Load_Expanded_View()
