<!-- vim: set filetype=markdown: -->

# Work in progress

For now, it’s almost an empty shell.

# Introduction

Doughnut is a plugin for vim aimed at managing buffer groups.

In short, this plugin let you organize your buffers by creating as
many buffer groups as you need, add the buffers you want to it and
quickly navigate between :

  - Buffers of the same group

  - Buffer groups

Note that :

  - A location is a pair (filename . position)

  - A buffer group, in fact a location group, is called a circle

  - A set of buffer groups is called a torus (a circle of circles)

## History

This project is inspired by :

- [CtrlSpace](https://github.com/vim-ctrlspace/vim-ctrlspace), a similar
pluginfor Vim

- [Torus](https://github.com/chimay/torus), a similar plugin for Emacs,
itself inspired by MTorus
