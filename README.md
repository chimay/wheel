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
+ [Examples](#examples)
	* [Display matching files in splits](#display-matching-files-in-splits)
	* [More](#more)
+ [Warning](#warning)
+ [Licence](#licence)

<!-- vim-markdown-toc -->
# Introduction
## What is it ?

Wheel is a :

- file group manager
- navigation plugin
- refactoring tool

for Vim and Neovim.

Our favorite editor has already plenty of nice navigation functions. Wheel
enhances their interface by using :

- intuitive completion with multi-pattern support for prompting functions
- dedicated buffers, in which you can filter and select elements, besides using
  the full power of your editor
- edit modes, that allow you to reflect your changes in a dedicated buffer to
  the original file(s)

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

The group manager is the core, but it goes far beyond that : you need a
quick navigation framework to travel in the wheel, and once it is there,
it’s easy to add new functionalities.

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
    * selection tools
    * preview
    * folds matching wheel tree structure
    * context menus
  + auto `:lcd` to project root of current file
  + history of wheel files
    * anywhere
    * in same group
    * in same category
  + signs displayed at wheel locations
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
- narrow
  + current file
  + all circle file with a pattern
- yank ring using TextYankPost event
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
  + layer ring in each dedicated buffer
- batch operations
- autogroup files by extension or directory
- save tabs & windows in minimal session file
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

## History

This project is inspired by :

- [torus](https://github.com/chimay/torus), a file group plugin for Emacs,
  itself inspired by [MTorus](https://www.emacswiki.org/emacs/MTorus)

- [ctrlspace](https://github.com/vim-ctrlspace/vim-ctrlspace), a workspace
  plugin for Vim

- [unite](https://github.com/Shougo/unite.vim) and its successor
  [denite](https://github.com/Shougo/denite.nvim), a search plugin for
  arbitrary sources

- [quickfix-reflector](https://github.com/stefandtw/quickfix-reflector.vim),
  for the grep edit mode

- [narrow](https://github.com/chrisbra/NrrwRgn), for the narrow dedicated buffers

## Prerequisites

Some functions assume a Unix-like OS, like Linux or BSD :

- async functions
- generation of a script to symlink or copy the wheel as a filesystem tree

Most of the plugin should work out of the box on other OSes, however. If
you encounter some problem, please let me know.

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

folders somewhere of the (neo)vim runtimepath, and it should work.

# Documentation
## Vim help

[Your guide](https://github.com/chimay/wheel/blob/master/doc/wheel.txt)
on the wheel tracks :

~~~vim
:help wheel.txt
~~~

## Wiki

A [wheel wiki](https://github.com/chimay/wheel/wiki) is also available.

It is recommended to read at least the
[step-by-step](https://github.com/chimay/wheel/wiki/step-by-step)
page, either in the wiki or in the `wheel.txt` file.

## In wheel menu

In the help submenu of the main menu (default map : `<M-w><M-m>`), you have
access to :

- the inline help (wheel.txt)
- the list of current wheel mappings
- the list of available plug mappings
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
  let g:wheel_config              = {}
  let g:wheel_config.maxim        = {}
  let g:wheel_config.display      = {}
  let g:wheel_config.display.sign = {}

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
  "let g:wheel_config.project_markers = '.project-root'
  " List of markers
  " The project dir is found as soon as one marker is found in it
  let g:wheel_config.project_markers = ['.git', '.project-root']
  " Locate database ; default one if left empty
  let g:wheel_config.locate_db = '~/index/locate/home.db'
  " Grep command : :grep or :vimpgrep
  let g:wheel_config.grep = 'grep'

  " Maximum number of elements in history
  let g:wheel_config.maxim.history = 50
  " Maximum number of elements in input history
  let g:wheel_config.maxim.input = 100

  " Maximum number of elements in mru
  let g:wheel_config.maxim.mru = 120

  " Maximum number of elements in yank ring
  let g:wheel_config.maxim.yanks = 300
  " Maximum size of elements in yank ring
  let g:wheel_config.maxim.yank_size = 3000

  " Maximum size of layer ring
  let g:wheel_config.maxim.layers = 10

  " Maximum number of tabs in layouts
  let g:wheel_config.maxim.tabs = 12
  " Maximum number of horizontal splits
  let g:wheel_config.maxim.horizontal = 3
  " Maximum number of vertical splits
  let g:wheel_config.maxim.vertical = 4

  " Wheel message : all in one-line or accept multi-line
  let g:wheel_config.display.message = 'one-line'
  " Filter prompt in dedicated buffers
  let g:wheel_config.display.prompt = 'wheel $ '
  " Selection marker in dedicated buffers
  let g:wheel_config.display.selection = '-> '
  " Sign text at wheel locations
  let g:wheel_config.display.sign.settings = { 'text' : '@' }

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

# Bindings

For a thorough discussion on bindings, see
[the bingings page](https://github.com/chimay/wheel/wiki/bindings)
in the wiki.

## Frequently used functions

Below are some bindings that you may find useful. They are included in
the level 10 mappings :

~~~vim
let nmap = 'nmap <silent>'
let vmap = 'vmap <silent>'
" Menus
exe nmap '<m-m>          <plug>(wheel-menu-main)'
exe nmap '<m-=>          <plug>(wheel-menu-meta)'
" Sync
exe nmap '<m-i>          <plug>(wheel-dashboard)'
exe nmap '<c-$>          <plug>(wheel-sync-down)'
exe nmap '<m-$>          <plug>(wheel-sync-up)'
" ---- navigate in the wheel
" --  next / previous
exe nmap '<m-pageup>   <plug>(wheel-previous-location)'
exe nmap '<m-pagedown> <plug>(wheel-next-location)'
exe nmap '<c-pageup>   <plug>(wheel-previous-circle)'
exe nmap '<c-pagedown> <plug>(wheel-next-circle)'
exe nmap '<s-pageup>   <plug>(wheel-previous-torus)'
exe nmap '<s-pagedown> <plug>(wheel-next-torus)'
" -- switch
exe nmap '<m-cr>        <plug>(wheel-prompt-location)'
exe nmap '<c-cr>        <plug>(wheel-prompt-circle)'
exe nmap '<s-cr>        <plug>(wheel-prompt-torus)'
exe nmap '<m-space>     <plug>(wheel-dedibuf-location)'
exe nmap '<c-space>     <plug>(wheel-dedibuf-circle)'
exe nmap '<s-space>     <plug>(wheel-dedibuf-torus)'
" -- index
exe nmap '<m-x>         <plug>(wheel-prompt-index)'
exe nmap '<m-s-x>       <plug>(wheel-dedibuf-index)'
exe nmap '<m-c-x>       <plug>(wheel-dedibuf-index-tree)'
" -- history
exe nmap '<m-home>      <plug>(wheel-history-newer)'
exe nmap '<m-end>       <plug>(wheel-history-older)'
exe nmap '<c-home>      <plug>(wheel-history-newer-in-circle)'
exe nmap '<c-end>       <plug>(wheel-history-older-in-circle)'
exe nmap '<s-home>      <plug>(wheel-history-newer-in-torus)'
exe nmap '<s-end>       <plug>(wheel-history-older-in-torus)'
exe nmap '<m-h>         <plug>(wheel-prompt-history)'
exe nmap '<m-c-h>       <plug>(wheel-dedibuf-history)'
" -- alternate
exe nmap '<c-^>          <plug>(wheel-alternate-anywhere)'
exe nmap '<m-^>          <plug>(wheel-alternate-same-circle)'
exe nmap '<m-c-^>        <plug>(wheel-alternate-same-torus-other-circle)'
" ---- navigate with vim native tools
" -- buffers
exe nmap '<m-b>          <plug>(wheel-prompt-buffers)'
exe nmap '<m-c-b>        <plug>(wheel-dedibuf-buffers)'
exe nmap '<m-s-b>        <plug>(wheel-dedibuf-buffers-all)'
" -- tabs & windows : visible buffers
exe nmap '<m-v>          <plug>(wheel-prompt-tabwin)'
exe nmap '<m-c-v>        <plug>(wheel-dedibuf-tabwins-tree)'
exe nmap '<m-s-v>        <plug>(wheel-dedibuf-tabwins)'
" -- (neo)vim lists
exe nmap "<m-'>          <plug>(wheel-prompt-marker)"
exe nmap "<m-k>          <plug>(wheel-prompt-marker)"
exe nmap '<m-j>          <plug>(wheel-prompt-jump)'
exe nmap '<m-,>          <plug>(wheel-prompt-change)'
exe nmap '<m-c>          <plug>(wheel-prompt-change)'
exe nmap '<m-t>          <plug>(wheel-prompt-tag)'
exe nmap "<m-c-k>        <plug>(wheel-dedibuf-markers)"
exe nmap '<m-c-j>        <plug>(wheel-dedibuf-jumps)'
exe nmap '<m-;>          <plug>(wheel-dedibuf-changes)'
exe nmap '<m-c-t>        <plug>(wheel-dedibuf-tags)'
" ---- organize the wheel
exe nmap '<m-insert>     <plug>(wheel-prompt-add-here)'
exe nmap '<m-del>        <plug>(wheel-prompt-delete-location)'
exe nmap '<m-r>          <plug>(wheel-dedibuf-reorganize)'
" ---- organize other things
exe nmap '<m-c-r>        <plug>(wheel-dedibuf-reorg-tabwins)'
" ---- refactoring
exe nmap '<m-c-g>        <plug>(wheel-dedibuf-grep-edit)'
exe nmap '<m-n>          <plug>(wheel-dedibuf-narrow-operator)'
exe vmap '<m-n>          <plug>(wheel-dedibuf-narrow)'
exe nmap '<m-c-n>        <plug>(wheel-dedibuf-narrow-circle)'
" ---- search
" -- files
exe nmap '<m-l>          <plug>(wheel-dedibuf-locate)'
exe nmap '<m-f>          <plug>(wheel-dedibuf-find)'
exe nmap '<m-c-f>        <plug>(wheel-dedibuf-async-find)'
exe nmap '<m-u>          <plug>(wheel-prompt-mru)'
exe nmap '<m-c-u>        <plug>(wheel-dedibuf-mru)'
" -- inside files
exe nmap '<m-o>          <plug>(wheel-prompt-occur)'
exe nmap '<m-c-o>        <plug>(wheel-dedibuf-occur)'
exe nmap '<m-g>          <plug>(wheel-dedibuf-grep)'
exe nmap '<m-s-o>        <plug>(wheel-dedibuf-outline)'
" ---- yank ring
exe nmap '<m-y>          <plug>(wheel-prompt-yank-list)'
exe nmap '<m-p>          <plug>(wheel-prompt-yank-plain)'
exe nmap '<m-c-y>        <plug>(wheel-dedibuf-yank-list)'
exe nmap '<m-c-p>        <plug>(wheel-dedibuf-yank-plain)'
" ---- undo list
exe nmap '<m-s-u>        <plug>(wheel-dedibuf-undo-list)'
" ---- ex or shell command output
exe nmap '<m-!>          <plug>(wheel-dedibuf-command)'
exe nmap '<m-&>          <plug>(wheel-dedibuf-async)'
" ---- dedicated buffers
exe nmap '<m-tab>        <plug>(wheel-mandala-add)'
exe nmap '<m-backspace>  <plug>(wheel-mandala-delete)'
exe nmap '<m-left>       <plug>(wheel-mandala-backward)'
exe nmap '<m-right>      <plug>(wheel-mandala-forward)'
exe nmap '<m-up>         <plug>(wheel-mandala-switch)'
" ---- layouts
exe nmap '<m-z>          <plug>(wheel-zoom)'
exe nmap '<c-up>         <plug>(wheel-rotate-counter-clockwise)'
exe nmap '<c-down>       <plug>(wheel-rotate-clockwise)'
~~~

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
