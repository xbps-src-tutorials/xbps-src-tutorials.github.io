<!-- WARNING: Relative links aren't used on this page and this page only. All
other pages use relative links as expected. This is because of
https://github.com/rust-lang/mdBook/issues/2341 -->

# Xbps-src packaging tutorial

**This tutorial is up to date as of March 4, 2024**

This tutorial will guide you through packaging using `xbps-src` for inclusion
in [void-packages](https://github.com/void-linux/void-packages) repository or
for personal use.

**Prerequisites**

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
  (they are used in [packaging j4-dmenu-desktop](/packaging/j4-dmenu-desktop.md)
  section of this tutorial, but shouldn't be necessary in more normal use)

**Non-prerequisites**

This tutorial assumes no prior knowledge of packaging systems.

---

## Introduction
`xbps-src` is a simple but capable build system. It is one of Void Linux's major
strengths, but its official documentation can be difficult to understand for
those who do not have experience with build systems. This tutorial aims to
bridge that gap.

I try to cover the basics. Feel free to skip some sections. But don't skip too
much. This tutorial is written to be read from beginning to the end.

This tutorial is divided into four sections: packaging
[`j4-dmenu-desktop`](/packaging/j4-dmenu-desktop.md),
[`bat`](/packaging/bat.md), [`oniguruma`](/packaging/oniguruma.md) and
[`rofimoji`](/packaging/rofimoji.md).  Packaging
[`j4-dmenu-desktop`](/packaging/j4-dmenu-desktop.md) showcases basic concepts of
`xbps-src` and [`bat`](/packaging/bat.md),
[`oniguruma`](/packaging/oniguruma.md) and [`rofimoji`](/packaging/rofimoji.md)
show additional concepts that couldn't be shown on `j4-dmenu-desktop`.

All four of these are already packaged in Void Linux. The first three are
compiled programs, [`rofimoji`](/packaging/rofimoji.md) is not.

Contributing the packages to
[`void-packages`](https://github.com/void-linux/void-packages) is described in
[Contributing](/packaging/contributing.md).

### Paths
If not said otherwise, relative paths are relative to the directory the
[`void-packages`](https://github.com/void-linux/void-packages) repository
resides in.

### Tabs
`mdBook` [automatically converts tabs to spaces in code
blocks](https://github.com/rust-lang/mdBook/issues/1686). `xbps-src` indents
templates with tabs. You'll have to convert 4 spaces to tabs manually when
copying from code blocks in this tutorial.

### Extended logs
Some logs in this tutorial are cut. You can expand them by clicking on the eye
icon on the upper right corner of a code sample. The button will appear when
you'll hover over the code block.

```hidelines=~
~content
~content
~content
This isn't everything in the log!
~content
~content
~content
```

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

### Obsolescence of this tutorial
I chose to package the latest versions of the programs I'm showcasing at the
time of writing this tutorial. But `j4-dmenu-desktop`, `bat`, `oniguruma` and
`rofimoji` might have newer versions available by the time you read this,
rendering the packages I'm showcasing obsolete.

There's nothing wrong with packaging an older version of a package, although
outdated packages are unlikely to be accepted into the official Void
repositories. If any of these packages have a version greater than that
mentioned in the tutorial, it is left as an exercise for the reader to update
them. The process is the same.

The tutorial focuses on the process of packaging, the packaged programs and
libraries themselves "aren't that important" here.

### IRC
If you are unsure about some aspect of `xbps-src` or your template is failing
and you do not know why, you can ask around in `#voidlinux` or `#xbps` Libera
Chat channels.

The channel consists mainly of volunteers. Do not expect people there to package
complicated programs for you at your will.

When asking there, do **not** paste error logs or templates directly to the
channel. You will likely be kicked for this. Use a paste site instead. You can
use <https://bpa.st/>, <https://0x0.st/>, <https://termbin.com/> or some other
paste site.

It is often useful to pipe the output of a command directly to a paste site.
Some paste sites like <https://0x0.st/> and <https://termbin.com/> support it.

To paste a file to 0x0, run this:

```
curl -F'file=@yourfile.png' https://0x0.st
```

To paste the output of a command to 0x0, run this:

```
command | curl -F'file=@-' https://0x0.st
```

### Disclaimer
I, [meator](https://github.com/meator), am not a Void Linux member. I don't
have write privileges to any of the official Void Linux repositories nor can I
merge pull requests.
