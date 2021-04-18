<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
	* [What does it look like ?](#what-does-it-look-like-)
		* [Main menu](#main-menu)
		* [More screenshots](#more-screenshots)
	* [File groups & categories](#file-groups--categories)
		* [Why do you need three levels of grouping ?](#why-do-you-need-three-levels-of-grouping-)
		* [A wheel that follows you](#a-wheel-that-follows-you)
	* [Features](#features)
	* [History](#history)
* [Installation](#installation)
	* [Using minpac](#using-minpac)
	* [Using vim-plug](#using-vim-plug)
* [Configuration](#configuration)
	* [Bindings](#bindings)
* [Step by Step](#step-by-step)
	* [Documentation](#documentation)
	* [One map to ring them all](#one-map-to-ring-them-all)
	* [Mnemonic](#mnemonic)
	* [First Circles](#first-circles)
	* [Moving around](#moving-around)
		* [Cycling](#cycling)
		* [Switch using completion](#switch-using-completion)
		* [Switch using a special buffer](#switch-using-a-special-buffer)
	* [Square the Circle](#square-the-circle)
	* [Special buffers](#special-buffers)
		* [Wrapping up things](#wrapping-up-things)
		* [Filtering](#filtering)
		* [Input history](#input-history)
		* [Action](#action)
		* [Select entries](#select-entries)
		* [Reload](#reload)
	* [Menus](#menus)
		* [Action](#action-1)
		* [Main menu](#main-menu-1)
		* [Meta menu](#meta-menu)
	* [Context menus](#context-menus)
	* [Layer stack](#layer-stack)
	* [Special buffers stack](#special-buffers-stack)
* [Examples](#examples)
	* [Display some locations in tabs](#display-some-locations-in-tabs)
	* [Display matching files in splits](#display-matching-files-in-splits)
	* [Add a tab with a similar file](#add-a-tab-with-a-similar-file)
	* [Search and replace](#search-and-replace)
* [Warning](#warning)
* [Licence](#licence)

<!-- vim-markdown-toc -->

# Introduction

Wheel is a navigation plugin for Vim and Neovim. It is file group
oriented and makes abundant use of special buffers, in which you can
filter and select elements.

## What does it look like ?

### Main menu

![Main menu](screencast/menu-main.gif)

### More screenshots

[It’s here](screenshots.md)

## File groups & categories

Wheel let you organize your files by creating as many file groups as
you need, add the files you want to it and quickly navigate between :

- Files of the same group
- File groups

Note that :

- A location contains a name, a filename, as well as a line & column number
- A file group, in fact a location group, is called a circle
- A set of file groups, or a category, is called a torus (a circle of circles)
- The list of toruses is called the wheel

### Why do you need three levels of grouping ?

At first glance, managing groups with circles in a torus seems to be
sufficient. But with time, the torus grows big, and a third level helps
you to organize your files by groups and categories:

- The wheel contains all the toruses
- Each torus contains a category of files, e.g.:
  + configuration, development, publication
- Each circle contains a project, e.g.:
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

- Add
  + Files from anywhere in the filesystem
  + A file in more than one group
  + file:line-1 and file:line-2 in the same group
- May be saved in wheel file (recommended)
- On demand loading of files
  + No slowdown of (neo)vim start
- Easy navigation
  + Switch to matching tab & window if available
  + Next / Previous location, circle or torus
  + Choose file, group or category in special buffer
    * Filter candidates
    * Folds matching wheel tree structure
    * Context menus
  + Auto |:lcd| to project root of current file
- Search files
  + Opened buffers
  + Visible buffers in tabs & wins
  + MRU files not found in wheel
  + Using locate
  + Using find
- Search inside files
  + Grep on group files
    * Navigate
    * Edit buffer and propagate changes with :cdo
  + Outline
    * Folds headers in group files (based on fold markers)
    * Markdown headers
    * Org mode headers
  + Tags
  + Jumps & changes lists
- Command output in buffer
  + :ex or !shell command
  + Async shell command
- Yank wheel using TextYankPost event
- Reorganizing
  + Wheel elements
  + Tabs & windows
- Special buffers stack to save your searches
- Display files
  + Split levels : torus, circle, location
  + Split
    * vertical, golden vertical
    * horizontal, golden horizontal
    * main left, golden left
    * main top, golden top
    * grid
  + Mix of above
    * circles on tabs, locations on split
    * toruses on tabs, circles on split
- Batch operations
- Autogroup files by extension or directory

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


# Installation

## Using minpac

Simply add this line to your initialisation file :

```vim
call minpac#add('chimay/wheel', { 'type' : 'start' })
```

and run `:PackUpdate` (see [the minpac readme](https://github.com/k-takata/minpac))
to install.

## Using vim-plug

The syntax should be similar with other git oriented plugin managers :

```vim
Plug 'chimay/wheel'
```

and run `:PlugInstall` to install.

# Configuration

Here is an example of configuration :

```vim
if ! exists("g:wheel_loaded")

  " Init
  let g:wheel_config={}
  let g:wheel_config.maxim={}

  " The file where toruses and circles will be stored and read
  let g:wheel_config.file = '~/.local/share/wheel/auto.vim'
  " Auto read torus file on startup if > 0
  let g:wheel_config.autoread = 1
  " Auto write torus file on exit if > 0
  let g:wheel_config.autowrite = 1
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

  " Maximum number of tabs in layouts
  let g:wheel_config.maxim.tabs = 12
  " Maximum number of horizontal splits
  let g:wheel_config.maxim.horizontal = 3
  " Maximum number of vertical splits
  let g:wheel_config.maxim.vertical = 4

  " random ideas
  nmap <m-cr> <plug>(wheel-switch-location)
  nmap <c-cr> <plug>(wheel-switch-circle)
  nmap <s-cr> <plug>(wheel-switch-torus)

endif
```

as a starting point.

## Bindings

Here are some bindings that you may find useful, beginning with the most
used functions :

```vim
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
    nmap <d-^>        <plug>(wheel-alternate-same-torus-other-circle)
    " Navigation special buffers
    nmap <space>      <plug>(wheel-navigation-location)
    nmap <c-space>    <plug>(wheel-navigation-circle)
    nmap <s-space>    <plug>(wheel-navigation-torus)
    nmap <m-x>        <plug>(wheel-tree)
    nmap <m-h>        <plug>(wheel-history)
    " Opened files
    nmap <m-b>          <plug>(wheel-opened-files)
    " Tabs & windows : visible buffers in tree mode
    nmap <m-v>          <plug>(wheel-tabwins-tree)
    " Reorganize tabs & windows
    nmap <m-c-v>        <plug>(wheel-reorg-tabwins)
    " Search for files
    nmap <m-u>          <plug>(wheel-mru)
    nmap <m-l>          <plug>(wheel-locate)
    nmap <m-f>          <plug>(wheel-find)
    " Yank
    nmap <m-y>          <plug>(wheel-yank-list)
    nmap <m-p>          <plug>(wheel-yank-plain)
    " Search inside files
    nmap <m-s>          <plug>(wheel-occur)
    nmap <m-g>          <plug>(wheel-grep)
    nmap <m-o>          <plug>(wheel-outline)
    nmap <m-t>          <plug>(wheel-tags)
    nmap <m-j>          <plug>(wheel-jumps)
    nmap <m-c>          <plug>(wheel-changes)
    " Save (push) mandala (special buffer)
    nmap <m-Tab>        <plug>(wheel-buffer-push)
    " Remove (pop) mandala
    nmap <m-Backspace>  <plug>(wheel-buffer-pop)
    " Cycle mandala buffers
    nmap <m-space>      <plug>(wheel-buffer-cycle)
    " Command
    nmap <m-!>          <plug>(wheel-command)
    nmap <m-&>          <plug>(wheel-async)
    " Reshaping mandala buffer
    nmap <m-r>          <plug>(wheel-reorganize)
```

# Step by Step

## Documentation

[Your guide](https://github.com/chimay/wheel/blob/master/doc/wheel.txt)
on the wheel tracks :

```vim
 :help wheel.txt
 ```

## Prefix

In the following discussion, I assume that you have kept the default
mapping prefix :

```vim
let g:wheel_config.prefix = '<M-w>'
```

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
group them. So, we go `Juice` and type `<M-w>a` to add a location to the
wheel. If no torus is present in the wheel, it will create it and ask
for a name. Let’s say we name it `Food`. If no group (no circle) is
found in the torus, it will be created and prompt for a name. Let’s say
we choose `Drinks`. Finally, our file `Juice` is added to the group. Its
name is the filename without extension by default.

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

## Moving around

### Cycling

You can cycle the files of a circle with `<M-w><Left>` and
`<M-w><Right>`. These are often used bindings, so I suggest you map them
to more convenient keys, like `<C-PageUp>` and `<C-PageDown>`

To cycle the circles, use `<M-w><C-Left>` and `<M-w><C-Right>`. You can
also map them to more convenient keys, like `<C-Home>` and `<C-End>`.

To cycle the toruses, use `<M-w><S-Left>` and `<M-w><S-Right>` or
map them to `<S-Home>` and `<S-End>`.

### Switch using completion

You can also switch location by completion with `<M-w><CR>`.

You can also switch circle by completion with `<M-w><C-CR>`.

You can also switch torus by completion with `<M-w><S-CR>`.

### Switch using a special buffer

You can also switch location by chosing it in a special buffer. The
default mapping is `<M-w><Space>`. Pressing enter on a line will switch
to the matching location. Going to insert mode will allow you to filter
the lines with one or more words.

To choose a given circle in a special buffer, use `<M-w><C-space>`.

To choose a given torus in a special buffer, use `<M-w><S-space>`.

## Square the Circle

Over time, the number of circles will grow. Completion is great, but
if you just want to alternate the two last circles in history, you’ll
probably prefer `<M-w>^`.

If you press `<M-w><C-^>`, you can choose the alternate mode in a menu :

- Alternate anywhere
- Alternate in the same circle
- Alternate in the same torus
- Alternate in another circle
- Alternate in another torus
- Alternate in same torus but another circle

A common case is to alternate two files in the same circle, and two
circles in the same torus. So, you have the square :

 Alternate    | File 1	        | File 2
--------------|-----------------|-----------------
Circle Drinks | Juice           | Tea
Circle Fruits | Apple           | Pear

at your fingertips.

## Special buffers

Special buffers allow you to perform Wheel operations intuitively, using
full power of your editor : search, yank, paste, completion, and so on.

The available actions depend on the buffer type :

- Menu buffers allow you to launch a wheel function
- Navigation buffers allow you to switch to a :
  + location, circle or torus
  + MRU file, locate file
  + grep result
  + and so on
- Reordering buffers allow you to reorder locations, circles or toruses
- Reorganize buffer allows you fine grain operations
  + Move, copy or delete locations, circles and toruses, using folds
  + Change locations settings like name, line, col
  + Be sure you know what you’re doing
- Reorganize tabs and windows

### Wrapping up things

In normal mode, the keys `j`/`k` and `<up>`/`<down>` wrap the buffer :

- If on the first line, `k` or `<up>` will go to the last line
- If on the last line, `j` or `<down>` will go to the first line

### Filtering

In most special buffers, the first line is left empty : it is used as
an input line to filter the buffer. You can go to insert mode and filter
the elements with each word you enter on the input (first) line. Typing
`<space>`, `<esc>` or `<enter>` will update the candidates. Note that `<C-c>`
is not mapped, in case you need to go to normal mode without triggering
the filter function.

A space between two words is a logical and. So, `one two` will
display lines containing both `one` and `two`.

A pipe "|" in the middle of a word is a logical or. So, `one|two` will
display lines containing `one` or `two`.

A bang "!" beginning a filtering word is a logical not : all lines matching
this word will be removed from the buffer.

### Input history

An input history is available in insert mode. You can insert the
previous/next input with `<Up>`/`<Down>` or `<M-p>`/`<M-n>`.

The keys `<PageUp>`/`PageDown` or `<M-r>`/`<M-s>` will insert the
previous/next input matching the beginning of the inserted line, until
the cursor.

### Action

The main keys are :

- `<enter>` : trigger the default action, close the special buffer
- `g<enter>` : trigger the default action, leave the special buffer opened

### Select entries

Some special buffers will act on selected entries. You can hit :

- `<space>` to toggle the selection of a line
- `&` to invert the selection of all visible lines
- `*` to select all visible lines
- `|` to clear the selection of all visible lines

### Reload

Press `r` and the special buffer will reload its content.

Available on most special buffers.

## Menus

Each menu has its own dedicated special buffer. You can filter the menu
lines by entering words in insert mode.

### Action

In menu buffers, `<tab>` is a synonym for `<enter>` : trigger action.

Since there is no need to select multiple elements, `<space>` is a
shortcut for `g<enter>` : launch action and leave the menu opened.

### Main menu

The main menu is triggered with `<M-w>m` by default. From there, you
can launch the action you want by pressing `<enter>` on its line. Same
thing for `g<enter>`, but it will leave the special buffer opened.

The available actions are grouped by themes and folded. Just open a fold to
access its content.

### Meta menu

Press `<M-w>=` to open the meta menu : each line in this buffer will
launch a sub-menu. Each sub-menu holds the actions of the same category :

- Add a new element to the wheel
- Rename an element
- Delete an element
- Alternate last two elements
- Display elements in tabs
- Display elements in windows
- Display elements in tabs & windows
- Reorganize elements
- Navigation
- Search in files
- Run a command and collect its output
- Paste from yank wheel

In these sub-menus, you can use the keys :

- `<enter>`             : launch the action on the cursor line
- `g<enter>`, `<space>`   : launch action and leave the menu opened
- `<backspace>`         : leads you back to the meta menu

## Context menus

Some special buffers have context menu support. In that case, pressing
`<tab>` will open a menu where you can choose the action you want to
apply to the selected or cursor line(s).

If you change your mind and wish to come back, just press `<backspace>`.

## Layer stack

Each time you launch a wheel function involving a special buffer, a new
associated layer is added to a stack local to the buffer. You can :

- go back to the previous layer (and associated wheel function) by pressing `H`
- go forward to the next layer by pressing `L`
- destroy current layer and go back to the previous one by pressing `<backspace>`

## Special buffers stack

Wheel manages a special buffers stack. You can :

- Save your current special buffer with `<M-w><Tab>`
- Cycle the special buffers with `<M-w>@` (left) or `<M-w><M-@>` (right)
- Remove the current special buffer with `<M-w><Backspace>`

This way, you can save a special buffer in case you need it later.

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

## Add a tab with a similar file

- press `<M-w>W` to launch the tabs & windows organizer
- copy the line with the tab you want to duplicate
  + with closed fold, to take the files in it
- paste it where you want
- open the fold of the new tab
- modify the filename in it to match the file you want to edit
  + you can even use `<C-x><C-f>` to use vim file completion
- apply your changes with `:write`

## Search and replace

Let's say you want to refactory some shell scripts, and replace
`old_var_name` by `new_var_name`.

The first thing to do is to create a group that contains all of your
scripts. To do that, first create a torus named e.g. `quickfix`. Then,
add all the script files with `<M-w>*`. The routine will ask you the
glob pattern ; you can type `**/*.sh` if all your scripts have the same
`sh` extension. After that, you will be asked if you want to create a
new circle. Answer yes, and call this circle `shell`.

Now that you have your group ready, you can start the search with
`<M-w><M-g>`. It will open the grep special buffer. Hit tab, and launch
the edit mode. You are now in a buffer where you can edit and propagate
your changes. So, we use the classic `:%s/old_var_name/new_var_name/g`
to replace all the occurences of the old var name. Then, just *:write*
the buffer to apply these changes to all your shell scripts.

Want to go back to previous state ? You can undo your substitution in
the special buffer, and write again.

You can of course reuse the `shell` group for later refactoring.

# Warning

Despite abundant testing, some bugs might remain, so be careful.

# Licence

MIT
