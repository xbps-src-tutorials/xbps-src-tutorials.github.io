# Xbps-src packaging tutorial

**This tutorial is up to date as of February 27, 2024**

This tutorial will guide you through packaging using `xbps-src` for inclusion
in [void-packages](https://github.com/void-linux/void-packages) repository or
for personal use.

### Prerequisites
- use Void Linux (this is not a hard requirement, there are ways to build XBPS
  packages from foreign distros, but this is outside the scope of this tutorial)
- basic knowledge of Git
- basic knowledge of GitHub for contributing (have an account, know how to make
  a fork, know how to make a pull request)
- basics of CLI
- knowledge of the build system of the packaged program is preferable
- knowledge of libraries (what's a static/dynamic library, why are they
  important, what's a SONAME etc.) is useful
- knowing what is a patch, how to make one and how to apply one is preferable
  (they are used in this article, but shouldn't be necessary in more normal use)

### Non-prerequisites
This tutorial assumes no prior knowledge of packaging systems.

---

## Introduction
`xbps-src` is a simple but capable build system. It is one of Void Linux's major
strengths, but its official documentation can be difficult to understand for
those who do not have experience with build systems. This tutorial aims to
bridge that gap.

I try to cover the basics. Feel free to skip some sections. But don't skip too
much. This tutorial is written to be read from beginning to the end.

This tutorial is divided into three sections: packaging
[`j4-dmenu-desktop`](packaging-j4-dmenu-desktop.md), [`bat`](packaging-bat.md)
and [`oniguruma`](packaging-oniguruma.md). Packaging
[`j4-dmenu-desktop`](packaging-j4-dmenu-desktop.md) showcases basic concepts of
`xbps-src` and [`bat`](packaging-bat.md) and
[`oniguruma`](packaging-oniguruma.md) show additional concepts that couldn't be
shown on `j4-dmenu-desktop`.

All three of these are already packaged in Void Linux. They are also all
compiled. You should still be able to follow this tutorial for programs &
libraries which aren't compiled, but you should pay less attention to sections
discussing cross compilation and the difference between `hostmakedepends` and
`makedepends`.

Contributing the packages to
[`void-packages`](https://github.com/void-linux/void-packages) is described in
[Contributing](contributing.md).

## Paths
If not said otherwise, relative paths are relative to the directory the
[`void-packages`](https://github.com/void-linux/void-packages) repository
resides in.

## Tabs
`mdBook` automatically converts tabs to spaces in code blocks. `xbps-src`
indents templates with tabs. You'll have to convert 4 spaces to tabs manually
when copying from code blocks in this tutorial.

### Official documentation
I will try to update this tutorial as appropriate, but the official
documentation will always contain more up-to-date info. The official
documentation includes:

- [void-packages
README](https://github.com/void-linux/void-packages/blob/master/README.md),
which explains setting up the masterdir and some more exotic configurations of `xbps-src`.
- [**the
Manual**](https://github.com/void-linux/void-packages/blob/master/Manual.md),
which contains everything there is to know about `xbps-src`
- [CONTRIBUTING](https://github.com/void-linux/void-packages/blob/master/CONTRIBUTING.md),
which contains useful info about contributing packages to `void-packages` like
commit message format requirements, **package requirements** (we'll come back to
this soon) and more

The [Manual](https://github.com/void-linux/void-packages/blob/master/Manual.md)
is more akin to a reference manual, but the first few sections briefly explain
the basics of `xbps-src`.

### IRC
If you are unsure about some aspect of `xbps-src` or your template is failing
and you do not know why, you can ask around in `#voidlinux` or `#xbps` Libera
Chat channels.

The channel consists mainly of volunteers. Do not expect people there to package
complicated programs for you at your will.

When asking there, do **not** paste error logs or templates directly to the
channel. You will likely be temporarily banned for this. Use a paste site
instead. You can use <https://bpa.st/>, <https://0x0.st/>,
<https://termbin.com/> or some other paste site. Use of <https://pastebin.com/>
specifically is discouraged.

### Disclaimer
I, [meator](https://github.com/meator), am not a Void Linux member. I don't
have write privileges to any of the official Void Linux repositories nor can I
merge pull requests.
