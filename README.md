<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
	* [Goal](#goal)
		* [Why do you need three levels of grouping ?](#why-do-you-need-three-levels-of-grouping-)
		* [A wheel that follows you](#a-wheel-that-follows-you)
	* [Features](#features)
	* [History](#history)
* [Installation](#installation)
	* [Using minpac](#using-minpac)
* [Configuration](#configuration)
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
* [TODO](#todo)
* [Licence](#licence)

<!-- vim-markdown-toc -->

# Introduction

## Goal

Wheel is a plugin for Vim or Neovim aimed at managing buffer groups.

In short, this plugin let you organize your buffers by creating as many
buffer groups as you need, add the buffers you want to it and quickly
navigate between :

- Buffers of the same group - Buffer groups

Note that :

- A location contains a name, a filename, as well as a line & column number
- A buffer group, in fact a location group, is called a circle
- A set of buffer groups, or a category, is called a torus (a circle of circles)
- The list of toruses is called the wheel

### Why do you need three levels of grouping ?

At first glance, managing groups with circles in a torus seems to be
sufficient. But with time, the torus grows big, and a third level helps
you to organize your files by groups and categories:

  - The wheel contains all the toruses - Each torus contains a category
  of files, e.g.:
    + configuration, development, publication
  - Each circle contains a project, e.g.:
    + emacs or vifm circles in configuration torus + shell or elisp in
    development torus + tea or art in publication torus

### A wheel that follows you

Wheel helps you to organize your files in groups that you create
yourself, following your workflow. You only add the files you want,
where you want. For instance, if you have a "organize" group with agenda
& todo files, you can quickly alternate them, or display them in two
windows. Then, if you suddenly got an idea to tune vim, you switch to the
"vim" group with your favorites configuration files in it. Same process,
to cycle, alternate or display the files. Over time, your groups will
grow and adapt to your style.

## Features

- Add
  + Files from anywhere in the filesystem
  + A file in more than one group
  + file:line-1 and file:line-2 in the same group
- Easy navigation
  + On demand loading of files
  + Jump to matching tab & window if available
  + Choose file, group or category in special buffer
    * Filter candidates
	* Folding matching wheel tree structure
  + Auto `:lcd` to project root of current file
- May be saved in wheel file
- Reordering elements
- Moving elements
- Display files
  + 1 location per tab
  + 1 circle per tab
  + 1 torus per tab
  + split : grid, main left, etc
  + Mix of above
- Autogroup
- Batch operations

## History

This project is inspired by :

- [CtrlSpace](https://github.com/vim-ctrlspace/vim-ctrlspace), a similar
plugin for Vim

- [Torus](https://github.com/chimay/torus), a similar plugin for Emacs,
itself inspired by MTorus

# Installation

## Using minpac

Simply add this line to your initialisation file :

```vim
call minpac#add('chimay/wheel', { 'type' : 'start' })
```

and it’s done.

# Configuration

Here is an example of configuration :

```vim
" Initialize config dict
let g:wheel_config={}
" Auto read torus file on startup if > 0
let g:wheel_config.autoread = 1
" Auto write torus file on exit if > 0
let g:wheel_config.autowrite = 1
" The file where toruses and circles will be stored and read
let g:wheel_config.file = '~/.local/share/wheel/auto.vim'
" The bigger it is, the more mappings available
let g:wheel_config.mappings = 2
" Prefix for mappings
"let g:wheel_config.prefix = '<M-w>'
" Number of backups for the wheel file
let g:wheel_config.backups = 3
" Auto cd to project root if > 0
let g:wheel_config.cd_project = 1
" Marker of project root
"let g:wheel_config.project_markers = '.git'
" List of markers: the project dir is found as soon as one marker is found in it
let g:wheel_config.project_markers = ['.git', '.my-project-root']
" Maximum number of elements in history
let g:wheel_config.max_history = 50
" Autocommands executed after jumping to a location
autocmd User WheelAfterJump norm zMzx
```

as a starting point.

# Step by Step

## Documentation

Your guide on the wheel tracks :

```vim
 :help wheel.txt
 ```

## Prefix

In the following discussion, I assume that you have kept the default
mapping prefix :

```vim
g:wheel_config.prefix = '<M-w>'
```

Just replace it by your prefix if you’ve changed it.

## One map to ring them all

To get an overview of the Wheel, I suggest you take a look at the main
menu. Press `<M-w>m` and a new buffer will appear, listing the actions
you can perform. Insert mode is used to filter the lines. Press enter
in normal mode to trigger an action (if you know what you’re doing),
or `q` to quit the menu.

If you prefer the meta menu leading you to thematic sub-menus, you can
launch it with `<M-w>=`.

## Mnemonic

Most mappings respect the following convention :

- prefix + `letter`     : location operation
- prefix + `<C-letter>` : circle operation
- prefix + `<S-letter>` : location operation

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

## Moving around

### Cycling

You can cycle the files of a circle with `<M-w><Left>` and
`<M-w><Right>`. These are often used bindings, so I suggest you map them
to a more convient key, like `<C-PageUp>` and `<C-PageDown>`

To cycle the circles, use `<M-w><C-left>` and `<M-w><C-right>`. These are
often used bindings, so I suggest you map them to a more convient key,
like `<C-Home>` and `<C-End>`

To cycle the toruses, use `<M-w><S-left>` and `<M-w><S-right>`. These are
often used bindings, so I suggest you map them to a more convient key,
like `<S-Home>` and `<S-End>`

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

# TODO

- copy / moving things
  + location to circle
  + circle to torus
  + restructuring buffer ?
- layout
  + tab & split
  + split : grid, main left, etc
- autogroup
- grep & sync wheel with current file

# Licence

MIT
