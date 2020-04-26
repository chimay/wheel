<!-- vim: set filetype=markdown: -->

Wheel ( https://github.com/chimay/wheel ) is a navigation plugin for
Vim and Neovim. It is buffer group oriented and makes abundant use of
special buffers, in which you can filter and select elements.

Wheel let you organize your buffers by creating as many buffer groups as
you need, add the buffers you want to it and quickly navigate between :

- Buffers of the same group
- Buffer groups

Note that :

- A location contains a name, a filename, as well as a line & column number
- A buffer group, in fact a location group, is called a circle
- A set of buffer groups, or a category, is called a torus (a circle of circles)
- The list of toruses is called the wheel

Wheel is designed to follow your workflow : you only add the files
you want, where you want. For instance, if you have a `organize` group
with agenda & todo files, you can quickly alternate them, or display
them in two windows. Then, if you suddenly got an idea to tune vim,
you switch to the `vim` group with your favorites configuration files in
it. Same process, to cycle, alternate or display the files. Over time,
your groups will grow and adapt to your style.

Features

- Add
  + Files from anywhere in the filesystem
  + A file in more than one group
  + file:line-1 and file:line-2 in the same group
- May be saved in wheel file
- Easy navigation
  + On demand loading of files
  + Switch to matching tab & window if available
  + Choose file, group or category in special buffer
    * Filter candidates
    * Folds matching wheel tree structure
    * Context menus
  + Auto |:lcd| to project root of current file
- Search files
  + MRU files not found in wheel
  + Using locate
  + Using find
- Search inside files
  + Grep on group files
  + Outline
    * Folds headers in group files (based on fold markers)
    * Markdown headers
    * Org mode headers
  + Tags
- Yank wheel using TextYankPost event
- Reorganizing elements
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
