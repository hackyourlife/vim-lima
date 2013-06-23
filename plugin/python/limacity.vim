"#######################################################################
" Copyright (C) 2013 hackyourlife.
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software Foundation,
" Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
"
" Config:	set variables in ~/.vimrc
"#######################################################################


if !has("python")
	finish
endif

" load limavim only once
if exists("loaded_limavim")
	finish
endif
let loaded_limavim = 1

command! -nargs=1 LimaOpen exec('py lima_thread_open(<f-args>)')
command! -nargs=0 LimaHome exec('py lima_home()')
command! -nargs=0 LimaBoards exec('py lima_boards()')
command! -nargs=1 LimaOpenPost exec('py lima_thread_by_post_id(<f-args>)')

if !exists("g:limacity_followkey")
	let g:limacity_followkey = '<F12>'
endif

if !exists("g:limacity_url")
	let g:limacity_url = 'https://limaapi.dauerstoned-clan.de/xmlrpc'
endif

if !exists("g:limacity_username")
	let g:limacity_username = ''
endif

if !exists("g:limacity_password")
	let g:limacity_password = ''
endif

if !exists("g:limacity_spell")
	let g:limacity_spell = 1
endif

function! g:lima_homepage_syntax()
	if has("syntax") && exists("g:syntax_on")
		syntax clear

		" current user
		syntax match limaUser /Benutzer: [-a-z0-9_]*$/

		" famous
		syntax match limaFamous /^Berühmt für 15 Minuten$/

		" newest posts header
		syntax match limaNewest /^Neueste.*$/

		" Thread
		syntax match limaThread "^[0-9]\+ ([ISC-]\{3})" contains=limaPostID,limaThreadFlags " nextgroup=limaThreadTitle skipwhite
		syntax match limaPostID "^[0-9]\+" contained
		syntax match limaThreadFlags "([ISC-]\{3})" contained contains=limaFlagImportant,limaFlagSticky,limaFlagClosed
		syntax match limaFlagImportant "I" contained
		syntax match limaFlagSticky "S" contained
		syntax match limaFlagClosed "C" contained
		"syntax match limaThreadTitle ".\{-}" contained nextgroup=limaThreadInfo skipwhite
		"syntax match limaThreadInfo "(.\{-}$" contained contains=limaThreadAuthor,limaThreadForum,limaThreadDate
		syntax match limaThreadAuthor "([-a-zA-Z0-9_]\+"hs=s+1 contained
		syntax match limaThreadDate "[0-9]\{2}:[0-9]\{2}, [0-9\.]\+)$"he=e-1 contained

		" to highlight some keywords
		syntax case ignore
		syntax match limaThreadKeywords "\(Technik und Elektronik\|PHP\|MySQL\|Netz\(werke\?\)\?\|Homepage\|\.\?htaccess\|Java\(script\)\?\|Python\|Linux\)"
		syntax match limaThreadBadKeywords "\(Spam-Forum\|Reallife\|Literatur und Kunst\|Beauty & Wellness\|Sport\)"
		syntax case match

		" color mapping
		highlight default link limaUser			Statement
		highlight default link limaFamous		Function
		highlight default link limaNewest		Function
		highlight default link limaPostID		Number
		highlight default link limaThreadFlags		Comment
		highlight default link limaFlagSticky		Todo
		highlight default link limaFlagImportant	Error
		highlight default link limaFlagClosed		Type
		"highlight default link limaThreadInfo		Comment
		highlight default link limaThreadAuthor		Statement
		highlight default link limaThreadDate		PreProc
		highlight default link limaThreadKeywords	Todo
		highlight default link limaThreadBadKeywords	Error
	endif
endfunction

function! g:lima_thread_post_caption(line)
	if has("syntax") && exists("g:syntax_on")
		exec "syntax region limaPostCaption start=/\\%" . a:line . "l/ end=/\\%" . (a:line + 1) . "l/ contains=limaPostID,limaPostInfo,limaPostUser"
	endif
endfunction

function! g:lima_thread_highlight()
	if has("syntax") && exists("g:syntax_on")
		syntax region limaThreadInfo start=/\%1l/ end=/\%4l/ contains=limaThreadLabel
		syntax match limaThreadLabel "^.\{-}:" contained

		syntax match limaPostID "^[0-9]\+" contained
		syntax match limaPostInfo "(.*)$" contained contains=limaPostInfoNumbers
		syntax match limaPostInfoNumbers "[0-9]\+ " contained
		syntax match limaPostStart "^[0-9]\: .* (.\{-})$" contained contains=limaPostUser
		syntax match limaPostUser "[-a-z0-9]\+ " contained contains=limaGoodUsers,limaBadUsers

		" color mappings
		highlight default link limaPostID		Number
		highlight default link limaPostInfo		Comment
		highlight default link limaPostInfoNumbers	Number
		highlight default link limaPostUser		Type
		highlight default link limaThreadLabel		PreProc
	endif
endfunction

function! g:lima_user_highlight()
	if has("syntax") && exists("g:syntax_on")
		" Modify the following lines to suit your needs
		syntax keyword limaBadUsers hpage php-test1
		syntax keyword limaGoodUsers fatfox hackyourlife bladehunter fatfreddy ggamee voloya tchab
		syntax keyword limaGoodUsers kochmarkus thomasba davidmuc burgi djfun lordoflima
		highlight default link limaBadUsers Error
		highlight default link limaGoodUsers Keyword
	endif
endfunction

function LimaThreadFoldText()
	let line = getline(v:foldstart)
	return v:folddashes . line
endfunction

python << EOF
# -*- coding: utf-8 -*-
import vim
import os.path
import sys

if sys.version_info[:2] < (2, 5):
	raise AssertionError('Vim must be compiled with Python 2.5 or higher; you have ' + sys.version)

# get the directory this script is in: the limaapi python module should be installed there.
scriptdir = os.path.join(os.path.dirname(vim.eval('expand("<sfile>")')), 'limacity')
sys.path.insert(0, scriptdir)

import json
import urllib
import urllib2
from pyquery import PyQuery as pq
from limaapi import LimaApi

FOLLOWKEY = vim.eval('g:limacity_followkey')

echomsg = lambda s: vim.command('echomsg "%s"' % s.encode('utf-8'))
echoerr = lambda s: vim.command('echoerr "%s"' % s.encode('utf-8'))
echonl = lambda: vim.command('echo "\n"')


lima = None

# all variables are in unicode; -> vim = utf-8
def vim_input(message = 'input', secret = False):
	vim.command('call inputsave()')
	vim.command("let user_input = %s('%s: ')" % (("inputsecret" if secret else "input"), message))
	vim.command('call inputrestore()')
	return vim.eval('user_input')

def lima_create_buffer(title):
	deleteBuffer = True if vim.current.buffer.name is None and \
			(vim.eval('&modified') == '0' or
			len(vim.current.buffer) == 1) else False

	bufnr = vim.eval('bufnr("%")')
	vim.command('new %s' % title.replace(' ', '\\ ').encode('utf-8'))
	if deleteBuffer:
		vim.command('bdelete %s' % bufnr)
	vim.command('setl modifiable')
	undolevels = vim.eval('&undolevels')
	vim.command('setl undolevels=-1')
	del vim.current.buffer[:]
	vim.command('let &undolevels = %s' % undolevels)
	vim.command('setl nomodified')
	vim.command('setl syntax=limacity')
	vim.command('setl buftype=acwrite')

def lima_set_temp_buffer():
	vim.command('setl buftype=nofile')
	vim.command('setl noswapfile')
	vim.command('setl bufhidden=delete')
	vim.command('setl nobuflisted')
	vim.command('setl nospell')

def lima_save():
	filename = vim.current.buffer.name
	start = filename.find('LIMA:')
	title = filename[start + 5:]
	echomsg('%s written' % title)
	vim.command('setl nomodified')

def lima_login():
	global lima
	if lima is None or not lima.isLoggedIn():
		lima = lima_do_login()
		if not lima:
			return False
	return True

def lima_do_login():
	url = vim.eval('g:limacity_url')
	username = vim.eval('g:limacity_username')
	password = vim.eval('g:limacity_password')

	if len(url) == 0:
		url = vim_input('api url')
	if len(username) == 0:
		username = vim_input('username')
	if len(password) == 0:
		password = vim_input('password', True)

	try:
		client = LimaApi(url)
		client.login(username, password)
	except Exception as e:
		echoerr('Could not log in: %s' % e)
		return None
	return client

def lima_thread_open(thread, page=0, perpage=100, reload=False):
	global lima
	if not lima_login(): return

	data = lima.getThread(thread, page, perpage)
	if reload:
		vim.command('setl modifiable')
		vim.current.buffer[:] = []
	else:
		lima_create_buffer('lima://%s/read' % thread)
		lima_set_temp_buffer()

	def format_bbcode(tree):
		text = u''
		if tree is None:
			return text
		tag_translation = { 'em' : 'i', 'u' : 'u', 'strong' : 'b', 'del' : 'del', 'blockquote' : 'quote' }
		for node in tree:
			if node.tag == 'text':
				text += node.text
			elif node.tag in ['em', 'u', 'strong', 'del', 'blockquote']:
				tag = tag_translation[node.tag]
				text += u'[%s]' % tag
				text += format_bbcode(node.children)
				text += u'[/%s]' % tag
			elif node.tag == 'link':
				text += u'[url=%s]' % node.url
				text += format_bbcode(node.children)
				text += u'[/url]'
			elif node.tag == 'goto':
				text += u'[url=%s]' % ('https://www.lima-city.de/thread/' + node.url if node.type == 'thread' else \
					u'https://www.lima-city.de/%s/action:jump/%s' % (node.type, node.id))
				text += format_bbcode(node.children)
				text += u'[/url]'
			elif node.tag == 'code':
				arg = 'inline' if node.display == 'inline' else node.language if not node.language is None else None
				content = format_bbcode(node.children)
				text += u'[code=%s]%s[/code]' % (arg, content) if not arg is None else u'[code]%s[/code]' % content
			elif node.tag == 'youtube':
				text += u'[youtube]https://youtu.be/%s[/youtube]' % node.video
			elif node.tag == 'math':
				text += u'[math]%s[/math]' % node.raw
			elif node.tag == 'img':
				text += node.alt
			elif node.tag == u'br':
				text += '\n'
		return text

	line = 5
	folds = []
	content = u'Thread:         %s\nForum:          %s\nKann antworten: %s\n\n' % (data.name, data.forum.name, "ja" if data.writable else "nein")
	for post in data.posts:
		content += u'%s: %s (%s, %s)\n' % (post.id, post.user.name, u'Gelöscht' if post.user.deleted else u'%s, %s Gulden' % (post.user.rank, post.user.gulden), post.date)
		bbcode = format_bbcode(post.content).strip()
		content += bbcode
		content += '\n\n\n'
		length = len(bbcode.splitlines()) + 2
		folds.append({'start':line, 'length':length})
		line += length + 1
	folds[len(folds) - 1]['length'] -= 2

	vim.current.buffer[:] = content.strip().encode('utf-8').splitlines()
	vim.command('setl filetype=limacity')
	vim.command('call g:lima_thread_highlight()')
	vim.command('call g:lima_user_highlight()')

	# create folds
	vim.command('setl foldtext=LimaThreadFoldText()')
	vim.command('setl foldmethod=manual')
	for fold in folds:
		vim.command('call g:lima_thread_post_caption(%d)' % fold['start'])
		vim.command('exec "%d,%dfold"' % (fold['start'], (fold['start'] + fold['length'])))

	vim.command('map <silent> <buffer> <F5> :py lima_thread_refresh("%s", %s, %s)<cr>' % (thread, page, perpage)) # allow refreshing
	vim.command('map <silent> <buffer> <C-R> :py lima_thread_refresh("%s", %s, %s)<cr>' % (thread, page, perpage)) # <C-R> = refresh
	vim.command('map <silent> <buffer> p :py lima_thread_write("%s")<cr>' % thread)
	vim.command('setl nomodifiable')

	# open last fold
	vim.command('normal G')
	vim.command('normal zo')

def lima_thread_refresh(thread, page, perpage):
	lima_thread_open(thread, page, perpage, True)

def lima_thread_write(thread):
	lima_create_buffer('lima://%s/post' % thread)
	undolevels = vim.eval('&undolevels')
	vim.command('setl undolevels=-1')
	vim.current.buffer[:] = []
	vim.command('let &undolevels = %s' % undolevels)
	vim.command('autocmd BufWriteCmd <buffer> py lima_thread_save("%s")' % thread)
	vim.command(':runtime ftplugin/limacity.vim')
	if vim.eval('g:limacity_spell'):
		vim.command('setl spell')
		vim.command('setl spelllang=de')
	vim.command('setl nomodified')

def lima_thread_save(thread):
	global lima
	if not lima_login(): return
	confirm = vim_input('Do you really want to post (yes/NO)?')
	if not confirm.lower() in ['y', 'yes']:
		return
	text = '\n'.join(vim.current.buffer)
	lima.postInThread(thread, text)
	echomsg('"%s" %dL, %dC posted' % (thread, len(vim.current.buffer), len(text)))
	vim.command('setl nomodified')

def lima_boards():
	global lima
	if not lima_login(): return
	lima_create_buffer('lima://boards')
	lima_set_temp_buffer()
	vim.current.buffer[:] = [ 'Foren auf lima-city', '' ]
	boards = lima.getBoards()
	for board in boards:
		vim.current.buffer.append('• ' + board.name)
	vim.current.buffer.append('\nDrücke <Enter> um das Forum zu öffnen.'.splitlines())
	vim.command('map <silent> <buffer> <Enter> :py lima_board_open()<cr>')
	vim.command('setl nomodified')
	vim.command('setl nomodifiable')

def lima_board_open():
	row = vim.current.window.cursor[0]
	column = vim.current.window.cursor[1]
	line = vim.current.buffer[row - 1]

def lima_home(refresh=False):
	global lima
	if not lima_login(): return

	if refresh:
		vim.command('setl modifiable')
	else:
		lima_create_buffer('lima://homepage')
		lima_set_temp_buffer()

	vim.current.buffer[:] = [ 'Lima-City (http://www.lima-city.de/), Benutzer: ' + lima.username, '' ]
	homepage = lima.getHomepage()
	modules = [ 'famous', 'newest' ]
	for module in modules:
		module = getattr(homepage, module)
		if module is None:
			continue
		vim.current.buffer.append([ module.name ])
		if module.type == 'newest':
			for thread in module.threads:
				flags = u'%s%s%s' % (
					'I' if thread.flags.important else '-',
					'S' if thread.flags.sticky else '-',
					'C' if thread.flags.closed else '-'
				)
				vim.current.buffer.append([ (u'%s (%s) %s (%s, %s, %s)' % (thread.postid, flags, thread.name, thread.user, thread.forum, thread.date)).encode('utf-8') ])
		elif module.type == 'famous':
			vim.current.buffer.append([
				(u'User:   %s (%s, %s Gulden, %s Sterne)' % (module.user.name, module.user.role, module.user.gulden, module.user.stars.count)).encode('utf-8'),
				(u'Gruppe: %s (%s Mitglieder)' % (module.group.name, module.group.members)).encode('utf-8'),
				(u'Domain: %s (Inhaber: %s)' % (module.domain.name, module.domain.owner)).encode('utf-8')
			])
		vim.current.buffer.append('')
	vim.current.buffer.append('Drücke <Enter> um den Thread anzusehen.'.splitlines())
	vim.command('map <silent> <buffer> <Enter> :py lima_thread_open_interactive()<cr>')
	vim.command('map <silent> <buffer> <F5> :py lima_home(True)<cr>') # allow refreshing
	vim.command('map <silent> <buffer> <C-R> :py lima_home(True)<cr>') # allow refreshing
	vim.command('setl filetype=limahome')
	vim.command('call g:lima_homepage_syntax()')
	vim.command('call g:lima_user_highlight()')
	vim.command('setl nomodified')
	vim.command('setl nomodifiable')

def lima_thread_open_interactive():
	global lima
	if not lima_login(): return
	row = vim.current.window.cursor[0]
	column = vim.current.window.cursor[1]
	line = vim.current.buffer[row - 1]
	wordtype = vim.eval('synIDattr(synID(line("."), 1, 1), "name")')
	if wordtype == 'limaPostID':
		postid = line.split()[0]
		lima_thread_by_post_id(postid)

def lima_thread_by_post_id(postid):
	global lima
	if not lima_login(): return
	data = lima.getPostThread(postid)
	lima_thread_open(data.name, data.page, data.perpage)
