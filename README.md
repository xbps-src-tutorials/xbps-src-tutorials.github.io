# Xbps-src tutorials
This is a collection of tutorials describing the `xbps-src` package build system
of Void Linux. It is made using [mdBook](https://rust-lang.github.io/mdBook/).

## Building this book
### Dependencies
This book requires [`mdBook`](https://github.com/rust-lang/mdBook),
[`mdbook-toc`](https://github.com/badboy/mdbook-toc) and
[`mdbook-admonish`](https://github.com/tommilligan/mdbook-admonish).

You can use

```
sudo xbps-install mdBook mdbook-toc
```

to install the dependencies on Void Linux. Note that `mdbook-admonish` isn't
currently packaged on Void Linux. You can download its executable in
<https://github.com/tommilligan/mdbook-admonish/releases/latest>. You'll have to
extract the appropriate archive and put the executable into a directory in
`$PATH`.

### Build process
You mustn't build this book with raw `mdbook`. This repo provides a `book.sh`
script which handles book building. See `book.sh -h` for more info about the
script.

You can build this book with

```
./book.sh build
```

## Releases
[Releases](https://github.com/xbps-src-tutorials/xbps-src-tutorials.github.io/releases/latest)
of this tutorial are available for offline reading. They include a prebuilt
book.

If you want the zipfile of the latest website deployment, go to
<https://github.com/xbps-src-tutorials/xbps-src-tutorials.github.io/actions>,
select the top workflow run, click on the `build` job and click on the `Upload
artifact` action. It should contain a link to a zipfile at the bottom of it.

## FAQ
### What's up with meator.github.io/xbps-src-tutorials/?
This is the original URL the website was hosted on. It has been replaced by
xbps-src-tutorials.github.io. The old URL is still functional, but it redirects
to the correct website now. If you want to know more, you can look at the old
repo: https://github.com/meator/xbps-src-tutorials

### Will you change the URL ever again?
No. <https://xbps-src-tutorials.github.io/> should be the final URL for xbps-src
tutorials.

### What's the release schedule of GitHub releases?
There is none! I will make a release whenever I feel like it or it I'll be asked
to do so.

### Why did you choose a program with half broken build system which doesn't even build without patches as your first example usage of xbps-src?
I believe it is useful to showcase `xbps-src`'s capabilities on a real-world
example. It lets me showcase a variety of features of `xbps-src` that aren't
commonly used in "normal" templates (but are still needed from time to time).

I, meator, also happen to be a co-maintainer of
[j4-dmenu-desktop](https://github.com/enkore/j4-dmenu-desktop). I am familiar
with its build system, which enables me to create a comprehensive tutorial on
the subject.

_j4-dmenu-desktop is also in my opinion a really cool program, so I wanted to
spread the word a bit._ But I chose it mainly for practical reasons.

### Why are you teaching people to use xbps-src wrong in the first half of packaging j4-dmenu-desktop?
The "naïve" approach of simply copying the build instructions one would normally
use when building the program to the template is pretty relatable. This is how
packaging systems with less abstraction like the AUR do it (but don't quote me
on that, I don't have much experience with the AUR).

By showing how to package programs wrong, I can showcase why are the "correct"
approaches better and what advantages do they have.

### Why mdBook?
mdBook is already used in [void-docs](https://github.com/void-linux/void-docs),
so Void Linux users are likely to be familiar with it. It has all the features
one would expect: it has nice theming support (not just white/black theme),
themes can be changed explicitly (it doesn't depend solely on
[prefers-color-scheme](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme)),
it has a simple interface for both readers and developers of the book and it
renders well on phones.

It also has print support, but that isn't a priority.

### What are the limitations of mdBook?
mdBook isn't really designed for long winded articles. It has lack of support
for table of contents inside a single page. This is partly fixed by
`mdbook-toc`, but the reader has to go to the beginning of the page to access
the TOC. A collapsible sidebar with TOC for example would be nicer.

mdBook [doesn't support copying blocks which use tabs for
indentation](https://github.com/rust-lang/mdBook/issues/1686). Tabs are
converted to spaces even when it's indented by tabs in markdown.

mdBook simplicity can be a double-edged sword. It lacks nice to have features
like trimming the last newline when copying a code block using the button or
[differentiating external
links](https://github.com/rust-lang/mdBook/issues/2326).

These things could probably be implemented by modifying the mdBook theme and
writing some custom Javascript. I don't have much experience with that, but
contributions are welcome!

### Can this tutorial be ported to something else than mdBook?
The tutorial is written pretty much in pure Markdown. The exceptions are the
usage of admonish (which shouldn't be difficult to replace) and the mdBook's
`{{#include}}` mechanism.

If some other system would provide better features, poring this tutorial to it
shouldn't be that difficult.

## Troubleshooting
### The book doesn't build! I'm getting a mdbook_admonish error!
The following error

```
[2024-03-04T22:54:06Z ERROR mdbook_admonish] Fatal error: ERROR:
      Incompatible assets installed: required mdbook-admonish assets version '^3.0.0', but did not find a version.
      Please run `mdbook-admonish install` to update installed assets.
      For more information, see: https://github.com/tommilligan/mdbook-admonish#semantic-versioning
[2024-03-04T22:54:06Z ERROR mdbook_admonish]   - ERROR:
      Incompatible assets installed: required mdbook-admonish assets version '^3.0.0', but did not find a version.
      Please run `mdbook-admonish install` to update installed assets.
      For more information, see: https://github.com/tommilligan/mdbook-admonish#semantic-versioning
2024-03-04 23:54:06 [ERROR] (mdbook::utils): Error: The "admonish" preprocessor exited unsuccessfully with exit status: 1 status
```

is caused by [not using `book.sh`](#build-process).
