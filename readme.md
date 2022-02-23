# bfx86

A Brainf*ck interpreter written in pure x86-64 Assembly.

## How to build?

You can only build on Linux.

1. Install `yasm`, `ld`, and `make` on your system. `ld` comes with the GCC toolchain, so if you have that installed, you should be good.
    Installing `yasm` (on Ubuntu):

    `$ sudo apt install yasm`

    Installing `ld` and `make` (on Ubuntu):

    `$ sudo apt install build-essential`

2. Run the makefile in this directory. This can be done by typing `make` in the terminal.

3. Run the output program with a .bf file as the argument. For example, if you had a file named helloworld.bf in the same directory as bfx86, you would run that file by entering `./bfx86 helloworld.bf` in the terminal.

4. Witness the glory of Brainf*ck being interpreted in pure Assembly on your machine.

## Why?

Why not?

## Any future plans for this?

Maybe.

## Credits and additional resources
- [Wikipedia](https://en.wikipedia.org/wiki/Brainfuck) article on Brainf*ck. It's incredible.
- [peterferrie/brainfuck](https://github.com/peterferrie/brainfuck) on GitHub for proving it's possible. Theirs is much smaller, but mine is done in a way that I understand. :)
- [c9x.me/x86](https://c9x.me/x86/) for providing an amazing reference for x86-64 instructions.