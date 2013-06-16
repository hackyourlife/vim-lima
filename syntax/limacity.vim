" Vim language file
"  Language:		lima-city forum code
"  Maintainer:		hackyourlife
"  Version:		0.1
"  Latest Change:	2013-06-05
" -----------------------------------------------------

if version < 600
	syntax clear
endif

if !exists("main_syntax")
	if version < 600
		syntax clear
	elseif exists("b:current_syntax")
		finish
	endif
	let main_syntax = 'limacity'
endif

sy case ignore
syntax spell toplevel

sy region	limaEndTag				start='\[/'			end='\]'		contains=limaTagN,limaTagError
sy region	limaTag					start='\[[^/]'			end='\]'		contains=limaTagN,limaArg,limaTagError
sy match	limaTagN	contained		/\[\s*[-a-zA-Z0-9]\+/hs=s+1				contains=limaTagName
sy match	limaTagN	contained		/\[\/\s*[-a-zA-Z0-9]\+/hs=s+1				contains=limaTagName
sy match	limaTagError	contained		"[^\]]\["

" Allowed BB tag names
sy keyword	limaTagName	contained		i b u del url code quote math youtube

" Allowed arg names
sy keyword	limaArg		contained		inline actionscript3 as3 bash shell coldfusion cf
sy keyword	limaArg		contained		cpp c c# c-sharp csharp css delphi pascal diff patch
sy keyword	limaArg		contained		pas erl erlang groovy java jfx javafx js jscript
sy keyword	limaArg		contained		javascript perl pl php text plain py python ruby
sy keyword	limaArg		contained		rails ror rb sass scss scala sql vb vbnet xml xhtml
sy keyword	limaArg		contained		xslt html

sy cluster	limaTop					contains=@Spell,limaTag,limaEndTag,limaLink,limaCode

" Links
sy region	limaLink				start='\[url\]'			end='\[/url\]'me=e-6	contains=limaTag
sy region	limaLink				start='\[url \?=[^\[\]]\{-}\]'	end='\[/url\]'me=e-6	contains=@limaTop,limaTag

" Regions
sy region	limaBold				start='\[b\]'			end='\[/b\]'me=e-4	contains=@limaTop,limaBoldItalic,limaBoldUnderline
sy region	limaBoldItalic		contained	start='\[i\]'			end='\[/i\]'me=e-4	contains=@limaTop,limaBoldItalicUnderline
sy region	limaBoldItalicUnderline	contained	start='\[u\]'			end='\[/u\]'me=e-4	contains=@limaTop
sy region	limaBoldUnderline	contained	start='\[u\]'			end='\[/u\]'me=e-4	contains=@limaTop,limaBoldUnderlineItalic
sy region	limaBoldUnderlineItalic	contained	start='\[i\]'			end='\[/i\]'me=e-4	contains=@limaTop

sy region	limaItalic				start='\[i\]'			end='\[/i\]'me=e-4	contains=@limaTop,limaItalicBold,limaItalicUnderline
sy region	limaItalicBold		contained	start='\[b\]'			end='\[/b\]'me=e-4	contains=@limaTop,limaItalicBoldUnderline
sy region	limaItalicBoldUnderline	contained	start='\[u\]'			end='\[/u\]'me=e-4	contains=@limaTop
sy region	limaItalicUnderline	contained	start='\[u\]'			end='\[/u\]'me=e-4	contains=@limaTop,limaItalicUnderlineBold
sy region	limaItalicUnderlineBold	contained	start='\[b\]'			end='\[/b\]'me=e-4	contains=@limaTop

sy region	limaUnderline				start='\[u\]'			end='\[/u\]'me=e-4	contains=@limaTop,limaUnderlineBold,limaUnderlineItalic
sy region	limaUnderlineBold	contained	start='\[b\]'			end='\[/b\]'me=e-4	contains=@limaTop,limaUnderlineBoldItalic
sy region	limaUnderlineBoldItalic	contained	start='\[i\]'			end='\[/i\]'me=e-4	contains=@limaTop
sy region	limaUnderlineItalic	contained	start='\[i\]'			end='\[/i\]'me=e-4	contains=@limaTop,limaUnderlineItalicBold
sy region	limaUnderlineItalicBold	contained	start='\[b\]'			end='\[/b\]'me=e-4	contains=@limaTop

sy region	limaQuote	keepend			start='\[quote\]'		end='\[/quote\]'me=e-8	contains=@limaTop,limaBold,limaItalic,limaUnderline,limaMath,limaCode

" Code tag
sy match	limaCodeTag	contained		"\[code\]"						contains=limaTag
sy match	limaCodeTag	contained		"\[code \?=[^\[\]]\{-}\]"				contains=limaTag
sy region	limaCode	keepend			start='\[code\]'		end='\[/code\]'me=e-7	contains=limaCodeTag
sy region	limaCode	keepend			start='\[code \?=[^\[\]]\{-}\]'	end='\[/code\]'me=e-7	contains=limaCodeTag


"sy include @limaShell syntax/zsh.vim
"unlet b:current_syntax
"sy include @limaColdfusion syntax/cf.vim
"unlet b:current_syntax
"sy include @limaCpp syntax/cpp.vim
"unlet b:current_syntax
"sy include @limaC syntax/c.vim
"unlet b:current_syntax
"sy include @limaCs syntax/cs.vim
"unlet b:current_syntax
"sy include @limaCss syntax/css.vim
"unlet b:current_syntax
"sy include @limaPascal syntax/pascal.vim
"unlet b:current_syntax
"sy include @limaDiff syntax/diff.vim
"unlet b:current_syntax
"sy include @limaErlang syntax/erlang.vim
"unlet b:current_syntax
"sy include @limaGroovy syntax/groovy.vim
"unlet b:current_syntax
"sy include @limaJava syntax/java.vim
"unlet b:current_syntax
"sy include @limaJavascript syntax/javascript.vim
"unlet b:current_syntax
"sy include @limaPerl syntax/perl.vim
"unlet b:current_syntax
"sy include @limaPhp syntax/php.vim
"unlet b:current_syntax
"sy include @limaPython syntax/python.vim
"unlet b:current_syntax
"sy include @limaRuby syntax/ruby.vim
"unlet b:current_syntax
"sy include @limaSass syntax/sass.vim
"unlet b:current_syntax
"sy include @limaScss syntax/scss.vim
"unlet b:current_syntax
"sy include @limaSql syntax/sql.vim
"unlet b:current_syntax
"sy include @limaVb syntax/vb.vim
"unlet b:current_syntax
"sy include @limaXml syntax/xml.vim
"unlet b:current_syntax
"sy include @limaXhtml syntax/xhtml.vim
"unlet b:current_syntax
"sy include @limaHtml syntax/html.vim
"unlet b:current_syntax
"sy region	limaCode	keepend			start='\[code=\(bash\|shell\)\]' end='\[/code\]'me=e-7	contains=limaCodeTag,@limaShell
"sy region	limaCode	keepend			start='\[code=\(cf\|coldfusion\)\]' end='\[/code\]'me=e-7 contains=limaCodeTag,@limaColdfusion
"sy region	limaCode	keepend			start='\[code=cpp\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaCpp
"sy region	limaCode	keepend			start='\[code=c\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaC
"sy region	limaCode	keepend			start='\[code=\(c#\|c-sharp\|csharp\)\]' end='\[/code\]'me=e-7	contains=limaCodeTag,@limaCs
"sy region	limaCode	keepend			start='\[code=css\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaCss
"sy region	limaCode	keepend			start='\[code=\(pascal\|pas\)\]' end='\[/code\]'me=e-7	contains=limaCodeTag,@limaPascal
"sy region	limaCode	keepend			start='\[code=diff\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaDiff
"sy region	limaCode	keepend			start='\[code=\(erl\|erlang\)\]' end='\[/code\]'me=e-7	contains=limaCodeTag,@limaErlang
"sy region	limaCode	keepend			start='\[code=groovy\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaGroovy
"sy region	limaCode	keepend			start='\[code=java\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaJava
"sy region	limaCode	keepend			start='\[code=\(js\|jscript\|javascript\)\]' end='\[/code\]'me=e-7 contains=limaCodeTag,@limaJavascript
"sy region	limaCode	keepend			start='\[code=\(perl\|pl\)\]'	end='\[/code\]'me=e-7	contains=limaCodeTag,@limaPerl
"sy region	limaCode	keepend			start='\[code=php\]'		end='\[/code\]'me=e-7	contains=limaCodeTag,@limaPhp
sy region	limaCode	keepend			start='\[code=.\{-}\]'		end='\[/code\]'me=e-7	contains=limaCodeTag

" Math tag
sy include @TeX syntax/tex.vim
sy region	limaMath				start='\[math\]'		end='\[/math\]'me=e-7	contains=@texMathZoneGroup,limaTag

" Color mapping
if version < 508
	com! -nargs=+ HiLink hi link     <args>
else
	com! -nargs=+ HiLink hi def link <args>
endif

hi def htmlBold                term=bold                  cterm=bold                  gui=bold
hi def htmlBoldUnderline       term=bold,underline        cterm=bold,underline        gui=bold,underline
hi def htmlBoldItalic          term=bold,italic           cterm=bold,italic           gui=bold,italic
hi def htmlBoldUnderlineItalic term=bold,italic,underline cterm=bold,italic,underline gui=bold,italic,underline
hi def htmlUnderline           term=underline             cterm=underline             gui=underline
hi def htmlUnderlineItalic     term=italic,underline      cterm=italic,underline      gui=italic,underline
hi def htmlItalic              term=italic                cterm=italic                gui=italic

HiLink	limaTag				Function
HiLink	limaEndTag			Identifier
HiLink	limaArg				Type
HiLink	limaTagName			Keyword
HiLink	limaTagError			Error

HiLink	limaLink			Underlined
HiLink	limaCode			Constant

HiLink	limaBold			htmlBold
HiLink	limaBoldItalic			htmlBoldItalic
HiLink	limaBoldUnderline		htmlBoldUnderline
HiLink	limaBoldItalicUnderline		htmlBoldUnderlineItalic
HiLink	limaBoldUnderlineItalic		htmlBoldUnderlineItalic
HiLink	limaItalic			htmlItalic
HiLink	limaItalicBold			htmlBoldItalic
HiLink	limaItalicUnderline		htmlUnderlineItalic
HiLink	limaItalicBoldUnderline		htmlBoldUnderlineItalic
HiLink	limaItalicUnderlineBold		htmlBoldUnderlineItalic
HiLink	limaUnderline			htmlUnderline
HiLink	limaUnderlineBold		htmlBoldUnderline
HiLink	limaUnderlineItalic		htmlUnderlineItalic
HiLink	limaUnderlineItalicBold		htmlBoldUnderlineItalic
HiLink	limaUnderlineBoldItalic		htmlBoldUnderlineItalic

delcommand HiLink

let b:current_syntax = "limacity"

if main_syntax == "limacity"
	unlet main_syntax
endif

" vim:set ts=8 sw=8 noet:
