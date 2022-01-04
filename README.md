<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

+ [Introduction](#introduction)
	* [What is it ?](#what-is-it-)
	* [What does it look like ?](#what-does-it-look-like-)
		- [Main menu](#main-menu)
		- [More screenshots](#more-screenshots)
	* [File groups & categories](#file-groups--categories)
		- [Why do you need three levels of grouping ?](#why-do-you-need-three-levels-of-grouping-)
		- [A wheel that follows you](#a-wheel-that-follows-you)
	* [Features](#features)
	* [History](#history)
	* [Prerequisites](#prerequisites)
+ [Installation](#installation)
	* [Using minpac](#using-minpac)
	* [Using vim-plug](#using-vim-plug)
	* [Plain](#plain)
+ [Documentation](#documentation)
	* [Vim help](#vim-help)
	* [Wiki](#wiki)
	* [In wheel menu](#in-wheel-menu)
+ [Configuration](#configuration)
	* [Wiki](#wiki-1)
	* [Example](#example)
+ [Bindings](#bindings)
	* [Frequently used functions](#frequently-used-functions)
+ [Step by Step](#step-by-step)
+ [Examples](#examples)
	* [Display matching files in splits](#display-matching-files-in-splits)
	* [More](#more)
+ [Warning](#warning)
+ [Licence](#licence)

<!-- vim-markdown-toc -->

# Introduction
## What is it ?

Wheel is a file group manager and navigation plugin for Vim and Neovim.

Our favorite editor has already plenty of nice navigation functions; Wheel
enhanced their interface by using :

- intuitive completion with multi-pattern support for prompting functions
- dedicated buffers, in which you can filter and select elements, besides using
  the full power of your editor

All is written in classical Vimscript.

## What does it look like ?
### Main menu

![Main menu](screencast/menu-main.gif)

### More screenshots

See the [screenshot page](screenshots.md).

## File groups & categories

Wheel let you organize your files by creating as many file groups as
you need, add the files you want to it and quickly navigate between :

- files of the same group
- file groups

Note that :

- a location contains a name, a filename, as well as a line & column number
- a file group, in fact a location group, is called a circle
- a set of file groups, or a category, is called a torus (a circle of circles)
- the list of toruses is called the wheel

### Why do you need three levels of grouping ?

At first glance, managing groups with circles in a torus seems to be
sufficient. But with time, the torus grows big, and a third level helps
you to organize your files by groups and categories:

- the wheel contains all the toruses
- each torus contains a category of files, e.g.:
  + configuration, development, publication
- each circle contains a project, e.g.:
  + emacs or vifm circles in configuration torus
  + shell or elisp in development torus
  + tea or art in publication torus

### A wheel that follows you

Wheel is designed to follow your workflow : you only add the files
you want, where you want. For instance, if you have a `organize` group
with agenda & todo files, you can quickly alternate them, or display
them in two windows. Then, if you suddenly got an idea to tune vim,
you switch to the `vim` group with your favorites configuration files in
it. Same process, to cycle, alternate or display the files. Over time,
your groups will grow and adapt to your style.

## Features

- add
  + files from anywhere in the filesystem
  + a file in more than one group
  + file:line-1 and file:line-2 in the same group
- may be saved in wheel file (recommended)
- on demand loading of files
  + no slowdown of (neo)vim start
- easy navigation
  + switch to matching tab & window if available
  + next / previous location, circle or torus
  + single or multi-pattern completion in prompting functions
  + choose file, group or category in dedicated buffer
    * filter candidates
    * folds matching wheel tree structure
    * context menus
  + auto `:lcd` to project root of current file
- search files
  + using locate
  + using find
  + MRU files not found in wheel
  + opened buffers
  + visible buffers in tabs & windows
- search inside files
  + grep on group files
    * navigate
    * edit mode : edit and propagate changes by writing the dedicated buffer
  + outline
    * folds headers in group files (based on fold markers)
    * markdown headers
    * org mode headers
  + tags
  + markers
  + jumps & changes lists
- yank wheel using TextYankPost event
  + paste before or after, linewise or characterwise
  + plain mode : each buffer line is a yanked line
  + list mode : each buffer line is a yank
- reorganizing
  + wheel elements
  + tabs & windows
- undo list
  + diff between last & chosen state
- command output in buffer
  + :ex or !shell command
  + async shell command
  + result can be filtered, as usual
- dedicated buffers stack to save your searches
  + layer stack in each dedicated buffer
- display files
  + split levels : torus, circle, location
  + split
    * vertical, golden vertical
    * horizontal, golden horizontal
    * main left, golden left
    * main top, golden top
    * grid
  + mix of above
    * circles on tabs, locations on split
    * toruses on tabs, circles on split
- save tabs & windows in minimal session file
- batch operations
- autogroup files by extension or directory

As you see, the group manager is the core, but it goes far beyond that :
you need a quick navigation framework to travel in the wheel, and once
it is there, it’s easy to add new functionalities.

UNIX’s philosophy is respected however, on a module level : each file in
`autoload/wheel` deals with a specific kind of problem, and do it well ;
the magic is when modules talk together.

## History

This project is inspired by :

- [ctrlspace](https://github.com/vim-ctrlspace/vim-ctrlspace), a workspace
  plugin for Vim

- [unite](https://github.com/Shougo/unite.vim) and its successor
  [denite](https://github.com/Shougo/denite.nvim), a search plugin for
  arbitrary sources

- [torus](https://github.com/chimay/torus), a similar plugin for Emacs,
  itself inspired by MTorus

- [quickfix-reflector](https://github.com/stefandtw/quickfix-reflector.vim),
  for the grep edit mode

## Prerequisites

Some functions assume a Unix-like OS, as linux or bsd.

# Installation
## Using minpac

Simply add this line to your initialisation file :

~~~vim
call minpac#add('chimay/wheel', { 'type' : 'start' })
~~~

and run `:PackUpdate` (see [the minpac readme](https://github.com/k-takata/minpac))
to install.

## Using vim-plug

The syntax should be similar with other git oriented plugin managers :

~~~vim
Plug 'chimay/wheel'
~~~

and run `:PlugInstall` to install.

## Plain

Just add the :

- plugin
- after
- autoload
- doc

folders in the matching runtime directories of (neo)vim, and it should
work.

# Documentation
## Vim help

[Your guide](https://github.com/chimay/wheel/blob/master/doc/wheel.txt)
on the wheel tracks :

~~~vim
:help wheel.txt
~~~

## Wiki

A [wheel wiki](https://github.com/chimay/wheel/wiki) is also available.

## In wheel menu

In the help submenu of the main menu (default map : `<M-w>m`), you have
access to :

- the inline help (wheel.txt)
- the list of current wheel mappings
- the list of available mappings
- the list of autocommands of your wheel group

# Configuration
## Wiki

For a thorough list of options, see
[the configuration page](https://github.com/chimay/wheel/wiki/configuration)
in the wiki.

## Example

Here is an example of configuration :

~~~vim
if ! exists("g:wheel_loaded")
  " Init
  let g:wheel_config={}
  let g:wheel_config.maxim={}

  " The file where toruses and circles will be stored and read
  let g:wheel_config.file = '~/.local/share/wheel/auto.vim'
  " Auto read wheel file on startup if > 0
  let g:wheel_config.autoread = 1
  " Auto write wheel file on exit if > 0
  let g:wheel_config.autowrite = 1
  " The file where session will be stored and read
  let g:wheel_config.session_file = '~/.local/share/wheel/session.vim'
  " Auto read session file on startup if > 0
  let g:wheel_config.autoread_session = 1
  " Auto write session file on exit if > 0
  let g:wheel_config.autowrite_session = 1
  " Number of backups for the wheel file
  let g:wheel_config.backups = 5
  " The bigger it is, the more mappings available
  let g:wheel_config.mappings = 10
  " Prefix for mappings
  let g:wheel_config.prefix = '<M-w>'
  " Auto cd to project root if > 0
  let g:wheel_config.cd_project = 1
  " Marker of project root
  "let g:wheel_config.project_markers = '.git'
  "let g:wheel_config.project_markers = '.racine-projet'
  " List of markers
  " The project dir is found as soon as one marker is found in it
  let g:wheel_config.project_markers = ['.git', '.racine-projet']
  " Locate database ; default one if left empty
  let g:wheel_config.locate_db = '~/racine/index/locate/racine.db'
  " Grep command : :grep or :vimpgrep
  let g:wheel_config.grep = 'grep'

  " Maximum number of elements in history
  let g:wheel_config.maxim.history = 50
  " Maximum number of elements in input history
  let g:wheel_config.maxim.input = 100

  " Maximum number of elements in mru
  let g:wheel_config.maxim.mru = 120

  " Maximum number of elements in yank wheel
  let g:wheel_config.maxim.yanks = 300
  " Maximum size of elements in yank wheel
  let g:wheel_config.maxim.yank_size = 3000

  " Maximum size of layer stack
  let g:wheel_config.maxim.layers = 10

  " Maximum number of tabs in layouts
  let g:wheel_config.maxim.tabs = 12
  " Maximum number of horizontal splits
  let g:wheel_config.maxim.horizontal = 3
  " Maximum number of vertical splits
  let g:wheel_config.maxim.vertical = 4

  let g:wheel_config.debug = 0
endif

augroup wheel
	autocmd!
	autocmd VimEnter * call wheel#void#init()
	autocmd VimLeave * call wheel#void#exit()
	autocmd User WheelAfterJump silent! normal! zCzO
	autocmd WinEnter * call wheel#projection#follow()
	"autocmd BufRead * call wheel#projection#follow()
	"autocmd BufEnter * call wheel#projection#follow()
	autocmd BufLeave * call wheel#vortex#update()
	autocmd BufRead * call wheel#attic#record()
	autocmd TextYankPost * call wheel#codex#add()
augroup END
~~~

as a starting point.

# Bindings
For a thorough list of bindings, see
[the bingings page](https://github.com/chimay/wheel/wiki/bindings)
in the wiki.

## Frequently used functions

Here are some bindings that you may find useful, beginning with the most
used functions :

~~~vim
" Menus
nmap <m-m>          <plug>(wheel-menu-main)
nmap <m-=>          <plug>(wheel-menu-meta)
" Add, Delete
nmap <m-insert>     <plug>(wheel-add-here)
nmap <m-del>        <plug>(wheel-delete-location)
" Next / Previous
nmap <c-pageup>     <plug>(wheel-previous-location)
nmap <c-pagedown>   <plug>(wheel-next-location)
nmap <c-home>       <plug>(wheel-previous-circle)
nmap <c-end>        <plug>(wheel-next-circle)
nmap <s-home>       <plug>(wheel-previous-torus)
nmap <s-end>        <plug>(wheel-next-torus)
" History
nmap <s-pageup>     <plug>(wheel-history-newer)
nmap <s-pagedown>   <plug>(wheel-history-older)
" Alternate
nmap <c-^>          <plug>(wheel-alternate-anywhere)
nmap <m-^>          <plug>(wheel-alternate-same-circle)
nmap <m-c-^>        <plug>(wheel-alternate-same-torus-other-circle)
" Switch prompt
nmap <m-cr>        <plug>(wheel-switch-location)
nmap <c-cr>        <plug>(wheel-switch-circle)
nmap <s-cr>        <plug>(wheel-switch-torus)
nmap <m-c-cr>      <plug>(wheel-switch-in-index)
" Navigation buffers
nmap <space>        <plug>(wheel-navigation-location)
nmap <c-space>      <plug>(wheel-navigation-circle)
nmap <s-space>      <plug>(wheel-navigation-torus)
nmap <m-x>          <plug>(wheel-tree)
nmap <m-c-x>        <plug>(wheel-index-locations)
nmap <m-h>          <plug>(wheel-history)
" Search for files
nmap <m-l>          <plug>(wheel-locate)
nmap <m-f>          <plug>(wheel-find)
nmap <m-c-f>        <plug>(wheel-async-find)
nmap <m-u>          <plug>(wheel-mru)
" Buffers
nmap <m-b>          <plug>(wheel-buffers)
" Tabs & windows : visible buffers
nmap <m-v>          <plug>(wheel-switch-tabwin)
nmap <m-c-v>        <plug>(wheel-tabwins-tree)
" Search inside files
nmap <m-s>          <plug>(wheel-occur)
nmap <m-g>          <plug>(wheel-grep)
nmap <m-o>          <plug>(wheel-outline)
" tags, labels
nmap <m-t>          <plug>(wheel-switch-tag)
nmap <m-l>          <plug>(wheel-tags)
nmap <m-k>          <plug>(wheel-markers)
nmap <m-j>          <plug>(wheel-jumps)
nmap <m-c>          <plug>(wheel-changes)
" Yank
nmap <m-y>          <plug>(wheel-yank-list)
nmap <m-p>          <plug>(wheel-yank-plain)
" Reshaping buffers
" wheel
nmap <m-r>          <plug>(wheel-reorganize)
" tabs & windows : visible buffers
nmap <m-c-r>        <plug>(wheel-reorg-tabwins)
" grep edit
nmap <m-c-g>        <plug>(wheel-grep-edit)
" Undo list
nmap <m-c-u>        <plug>(wheel-undo-list)
" Command
nmap <m-!>          <plug>(wheel-command)
nmap <m-&>          <plug>(wheel-async)
" Save (push) mandala buffer
nmap <m-tab>        <plug>(wheel-mandala-push)
" Remove (pop) mandala buffer
nmap <m-backspace>  <plug>(wheel-mandala-pop)
" Cycle mandala buffers
nmap <m-home>        <plug>(wheel-mandala-backward)
nmap <m-end>       <plug>(wheel-mandala-forward)
" Switch mandala buffers
nmap <m-space>      <plug>(wheel-mandala-switch)
" Layouts
nmap <m-z>          <plug>(wheel-zoom)
nmap <m-pageup>     <plug>(wheel-rotate-counter-clockwise)
nmap <m-pagedown>   <plug>(wheel-rotate-clockwise)
~~~

# Step by Step

See the
[wiki step-by-step page](https://github.com/chimay/wheel/wiki/step-by-step).

# Examples
## Display matching files in splits

- `<M-w><space>` to launch the location navigator
- `i` to go to insert mode
- enter the pattern you want
  + e.g. `\.vim$` if all your vim locations end with `.vim`
- `<enter>` to validate the pattern
- `*` to select all the visible (filtered) locations
- `v` to open all selected locations in vertical splits

## More

More information is available in the
[wiki examples page](https://github.com/chimay/wheel/wiki/examples).

# Warning

Despite abundant testing, some bugs might remain, so be careful.

# Licence

MIT
