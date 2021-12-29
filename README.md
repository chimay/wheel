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
+ [Configuration](#configuration)
	* [Wiki](#wiki-1)
	* [Example](#example)
+ [Bindings](#bindings)
	* [Wiki](#wiki-2)
	* [List of available mappings](#list-of-available-mappings)
	* [Frequently used functions](#frequently-used-functions)
+ [Step by Step](#step-by-step)
	* [Prefix](#prefix)
	* [One map to ring them all](#one-map-to-ring-them-all)
	* [Mnemonic](#mnemonic)
	* [First Circles](#first-circles)
	* [More](#more)
+ [Examples](#examples)
	* [Display some locations in tabs](#display-some-locations-in-tabs)
	* [Display matching files in splits](#display-matching-files-in-splits)
	* [More](#more-1)
+ [Warning](#warning)
+ [Licence](#licence)

<!-- vim-markdown-toc -->

# Introduction
## What is it ?

Wheel is a navigation plugin written in classical Vimscript, to remain
compatible with both Vim and Neovim. It is file group oriented and makes
abundant use of prompt completion and dedicated buffers, in which you
can filter and select elements.

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
~~~

as a starting point.

# Bindings
## Wiki

For a thorough list of bindings, see
[the bingings page](https://github.com/chimay/wheel/wiki/bindings)
in the wiki.

## List of available mappings

To display the list of available plug mappings, press `<M-w>:`,
then answer :

~~~vim
map <Plug>(wheel-
~~~

to the prompt. You can then browse the plug wheel maps in a dedicated
wheel buffer.

To see mapped keys, you can also use `<M-w>:`, and answer :

~~~vim
map <M-w>
~~~

to the prompt.

## Frequently used functions

Here are some bindings that you may find useful, beginning with the most
used functions :

~~~vim
nmap <m-m>        <plug>(wheel-menu-main)
nmap <m-=>        <plug>(wheel-menu-meta)
" Add, Delete
nmap <m-insert>   <plug>(wheel-add-here)
nmap <m-del>      <plug>(wheel-delete-location)
" Next / Previous
nmap <c-pageup>   <plug>(wheel-previous-location)
nmap <c-pagedown> <plug>(wheel-next-location)
nmap <c-home>     <plug>(wheel-previous-circle)
nmap <c-end>      <plug>(wheel-next-circle)
nmap <s-home>     <plug>(wheel-previous-torus)
nmap <s-end>      <plug>(wheel-next-torus)
" Alternate
nmap <c-^>        <plug>(wheel-alternate-anywhere)
nmap <m-^>        <plug>(wheel-alternate-same-circle)'
nmap <m-c-^>      <plug>(wheel-alternate-same-torus-other-circle)'
" Navigation in dedicated buffers
nmap <space>      <plug>(wheel-navigation-location)
nmap <c-space>    <plug>(wheel-navigation-circle)
nmap <s-space>    <plug>(wheel-navigation-torus)
nmap <m-x>        <plug>(wheel-tree)
nmap <m-h>        <plug>(wheel-history)
" Search for files
nmap <m-u>          <plug>(wheel-mru)
nmap <m-l>          <plug>(wheel-locate)
nmap <m-f>          <plug>(wheel-find)
" Buffers
nmap <m-b>          <plug>(wheel-buffers)
" Tabs & windows : visible buffers in tree mode
nmap <m-v>          <plug>(wheel-tabwins-tree)
" Search inside files
nmap <m-s>          <plug>(wheel-occur)
nmap <m-g>          <plug>(wheel-grep)
nmap <m-o>          <plug>(wheel-outline)
nmap <m-t>          <plug>(wheel-tags)
nmap <m-j>          <plug>(wheel-jumps)
nmap <m-c>          <plug>(wheel-changes)
" Yank
nmap <m-y>          <plug>(wheel-yank-list)
nmap <m-p>          <plug>(wheel-yank-plain)
" Reorganize the wheel : toruses, circles and locations
nmap <m-r>          <plug>(wheel-reorganize)
" Reorganize tabs & windows
nmap <m-c-r>        <plug>(wheel-reorg-tabwins)
" Grep in edit mode
nmap <m-c-g>        <plug>(wheel-grep-edit)
" Command output in dedicated buffer
nmap <m-!>          <plug>(wheel-command)
nmap <m-&>          <plug>(wheel-async)
" Save (push) mandala (dedicated buffer)
nmap <m-Tab>        <plug>(wheel-mandala-push)
" Remove (pop) mandala
nmap <m-Backspace>  <plug>(wheel-mandala-pop)
" Cycle mandala buffers
nmap <m-space>      <plug>(wheel-mandala-cycle)
~~~

# Step by Step
## Prefix

In the following discussion, I assume that you have kept the default
mapping prefix :

~~~vim
let g:wheel_config.prefix = '<M-w>'
~~~

Just replace it by your prefix if you’ve changed it.

## One map to ring them all

To get an overview of the Wheel, I suggest you take a look at the main
menu. Press `<M-w>m` and a new window will appear, listing the actions
you can perform. Insert mode is used to filter the lines. Press enter
in normal mode to trigger an action (if you know what you’re doing),
or `q` to quit the menu.

If you prefer the meta menu leading you to thematic sub-menus, you can
launch it with `<M-w>=`.

## Mnemonic

Most mappings respect the following convention :

- prefix + `letter`     : location operation
- prefix + `<C-letter>` : circle operation
- prefix + `<S-letter>` : torus operation
- prefix + `<M-letter>` : alternative operation

## First Circles

Let’s say we have the files `Juice`, `Tea`, `Coffee` and we want to
group them. So, we go `Juice` and type `<M-w>a` to add a location to
the wheel. If no torus is present in the wheel, it will create it and
ask for a name. Let’s say we name it `Food`. If no group (no circle)
is found in the torus, it will be created and prompt for a name. Let’s
say we choose `Drinks`. Finally, we are asked to choose a name for our
location. A completion is available : if we press `<Tab>`, we can choose
between different flavours of the current filename :

- without extension
- with extension
- relative path
- absolute path

In this case, we simply choose `Juice`, and our location is added to
the group.

Then, we go to `Tea` and type `<M-w>a` again. This time, it will just
ask us if we want to keep the default location name. Press enter, and
`Tea` is added to the `Drinks` group.

Same process with `Coffee`. We now have a circle `Drink` containing
three files.

If you want to create another circle, let’s say `Fruits`, simply launch
`<M-w><C-a>`, and answer `Fruits` to the prompt. You can then add the
files `Apple`, `Pear` and `Orange` to it. You can even also add `Juice`:
a file can be added to more than one circle.

Now, suppose that in the `Juice` file, you have a Pineapple
and a Mango sections, and you want to compare them. Just go to
the Pineapple section, and use `<M-w>a`. It will add the location
`Juice:pineapple-line:pineapple-col` to the current circle. Then, go to
the Mango section, and do the same. The `Juice:mango-line:mango-col`
will also be added to the circle. You can then easily alternate both,
or display them in split windows.

If you want to create another torus, let’s say `Books`, simply launch
`<M-w><S-a>`, and answer `Books` to the prompt.

What happens if you have a lot of files ? Let's say the `novel`
folder, located in the current directory, contains dozen of novels
in plain text format. You can add all of them at once with the
`add_glob` function. Press `<M-w>*` and wheel will ask you to enter a
glob pattern. You can answer `novels/*` to add all files in there. If
there are more levels of subdirs and you want to include all of them,
you can enter `novels/**/*` instead. Then, it will ask if you want to
add the files in a new circle. You can answer yes and call this circle
`Novels`. And voilà, your new `Novels` group contain all the files in
the `novels` folder.

## More

More information is available in the
[wiki step-by-step page](https://github.com/chimay/wheel/wiki/step-by-step).

# Examples
## Display some locations in tabs

Just press `<M-w><space>` to launch the location navigator, select the
locations you want and press `t`

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
